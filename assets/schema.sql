CREATE TABLE books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    subtitle TEXT,
    isbn10 TEXT UNIQUE,
    isbn13 TEXT UNIQUE,
    publisher TEXT,
    publicationYear INTEGER CHECK (publicationYear BETWEEN -5000 AND 3000),
    edition TEXT,
    genre TEXT
    languageCode TEXT,
    pageCount INTEGER 
        CHECK (pageCount IS NULL OR pageCount > 0),
    currentPage INTEGER NOT NULL DEFAULT 0 
        CHECK (currentPage >= 0)
        CHECK (currentPage <= pageCount), -- Can't be on a page beyond the end of the book
    percentComplete REAL NOT NULL DEFAULT 0 OR (currentPage * 100.0 / pageCount) 
        CHECK (percentComplete >= 0 AND percentComplete <= 100),
    description TEXT,
    subject TEXT,
    focusId INTEGER,
    locationId INTEGER,
    ownerId INTEGER,
    format TEXT CHECK (format IN ('hardcover', 'paperback', 'ebook', 'audiobook', 'PDF', 'other')),
    
    -- Tracking status -- 
    readingStatus TEXT NOT NULL DEFAULT 'unread'
        CHECK (readingStatus IN (
            'unread',
            'in progress',
            'completed',
            'abandoned',
            'paused'
        )), 
    startDate TEXT -- ISO date (YYYY-MM-DD)
        CHECK (startDate IS NULL OR startDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    endDate TEXT -- ISO date (YYYY-MM-DD)
        CHECK (endDate IS NULL OR endDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
        CHECK (endDate IS NULL OR startDate IS NOT NULL), -- Can't have an end date without a start date
        CHECK (endDate IS NULL OR endDate >= startDate), -- End date can't be before start date
    abandonedDate TEXT -- ISO date (YYYY-MM-DD)
        CHECK (abandonedDate IS NULL OR abandonedDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]')
        CHECK (abandonedDate IS NULL OR startDate IS NOT NULL) -- Can't have an abandoned date without a start date
        CHECK (abandonedDate IS NULL OR abandonedDate >= startDate) -- Abandoned date can't be before start date
        CHECK (abandonedDate IS NULL OR readingStatus = 'abandoned'), -- If there's an abandoned date, the status must be 'abandoned'
    
    -- Tracking planning efforts -- 
    planningStatus TEXT NOT NULL DEFAULT 'unplanned'
        CHECK (planningStatus IN (
            'unplanned',
            'planned',
            'completed',
            'abandoned'
        )),
    isProgressive
    
    -- Tracking ratings/reviews --
    ratingOverall REAL 
        CHECK (ratingOverall IS NULL OR ratingOverall BETWEEN 0 AND 5)
        CHECK (ratingOverall IS NULL OR readingStatus IN ('completed', 'abandoned')), -- Only allow a rating if the book has been completed or abandoned
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0 CHECK (isArchived IN (0, 1))
    FOREIGN KEY (locationId) REFERENCES locations(id) ON DELETE SET NULL,
    FOREIGN KEY (ownerId) REFERENCES owners(id) ON DELETE SET NULL,
    FOREIGN KEY (planId) REFERENCES readingPlan(id) ON DELETE SET NULL,
    FOREIGN KEY (focusId) REFERENCES focuses(id) ON DELETE SET NULL
) STRICT;

CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Display name (canonical)
    name TEXT NOT NULL,

    -- Optional structured components (useful but not required)
    firstName TEXT,
    middleName TEXT,
    lastName TEXT,

    -- Optional metadata
    birthYear INTEGER CHECK (birthYear IS NULL OR birthYear BETWEEN 0 AND 3000),
    deathYear INTEGER CHECK (deathYear IS NULL OR deathYear BETWEEN 0 AND 3000),

    nationality TEXT,
    languageCode TEXT,
    -- External identifiers (optional but useful if you ever sync data)
    openlibrary_id TEXT UNIQUE,
    goodreads_id TEXT UNIQUE,

    -- Free-form notes about the author
    notes TEXT,

    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    isArchived INTEGER NOT NULL DEFAULT 0 CHECK (isArchived IN (0,1))
) STRICT;

CREATE TABLE structuredReadingPlans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bookId INTEGER NOT NULL,
    startDate TEXT NOT NULL
        CHECK (startDate IS NULL OR startDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),              -- ISO date (YYYY-MM-DD)
    targetEndDate TEXT NOT NULL,
        CHECK (targetEndDate IS NULL OR targetEndDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    -- Snapshot of book at planning time
    totalPages INTEGER NOT NULL
        CHECK (totalPages > 0),
    totalSessions INTEGER NOT NULL
        CHECK (totalSessions > 0),
        CHECK (totalPages >= 10),
        CHECK (totalPages BETWEEN (10 * totalSessions) AND (10 * totalSessions + 9)),
    planStatus TEXT NOT NULL DEFAULT 'planned'
        CHECK (planStatus IN ('planned', 'active', 'completed', 'abandoned', 'superseded')),
    planVersion INTEGER NOT NULL DEFAULT 1
        CHECK (planVersion > 0),
    previousPlanId INTEGER
        CHECK (previousPlanId IS NULL OR previousPlanId != id) -- Can't reference itself as previous plan
        CHECK (previousPlanId IS NULL OR planVersion > 1), -- If there's a previous plan, this must be version 2 or higher
    isCurrent INTEGER NOT NULL DEFAULT 1
        CHECK (isCurrent IN (0, 1)),
    notes TEXT,
    focusId INTEGER
        CHECK (planFocusId IS NULL OR planFocusId IN (SELECT id FROM focuses)),
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1)),
    FOREIGN KEY (bookId) REFERENCES books(id) ON DELETE CASCADE
    FOREIGN KEY (previousPlanId) REFERENCES structuredReadingPlan(id),
    FOREIGN KEY (focusId) REFERENCES focuses(id)
) STRICT;

CREATE TABLE structuredReadingSessionPlans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    structuredReadingPlanId INTEGER NOT NULL,
    sessionNumber INTEGER NOT NULL
        CHECK (sessionNumber > 0),  -- Order within the plan (1, 2, 3, …)
    sessionDate TEXT NOT NULL
        CHECK (sessionDate IS NULL OR sessionDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),  -- ISO date (YYYY-MM-DD)
    startPage INTEGER NOT NULL
        CHECK (startPage > 0),
    endPage INTEGER NOT NULL
        CHECK (endPage >= startPage),
    pagesPlanned INTEGER NOT NULL
        DEFAULT (endPage - startPage + 1), -- Derived but useful for validation/debugging
    isFinalSession INTEGER NOT NULL DEFAULT 0
        CHECK (isFinalSession IN (0,1)),     -- Optional flag to simplify constraints/logic
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (structuredReadingPlanId) REFERENCES structuredReadingPlan(id) ON DELETE CASCADE
) STRICT

CREATE TABLE structuredReadingSessionActuals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    structuredReadingPlanId INTEGER NOT NULL,
    sessionNumber INTEGER NOT NULL
        CHECK (sessionNumber > 0),
    sessionDate TEXT NOT NULL
        CHECK (sessionDate IS NULL OR sessionDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),  -- ISO date (YYYY-MM-DD)
    startPage INTEGER NOT NULL
        CHECK (startPage > 0),
    endPage INTEGER NOT NULL
        CHECK (endPage >= startPage),
    pagesActual INTEGER NOT NULL
        DEFAULT (endPage - startPage + 1),
    isFinalSession INTEGER NOT NULL DEFAULT 0
        CHECK (isFinalSession IN (0,1)),
    minutesRead INTEGER CHECK (minutesRead > 0),
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (structuredReadingPlanId) REFERENCES structuredReadingPlan(id) ON DELETE CASCADE
) STRICT;

CREATE TABLE unstructuredReadingPlan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bookId INTEGER NOT NULL,
    startDate TEXT NOT NULL
        CHECK (startDate IS NULL OR startDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),              -- ISO date (YYYY-MM-DD)
    targetEndDate TEXT NOT NULL
        CHECK (targetEndDate IS NULL OR targetEndDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    -- Snapshot of book at planning time
    totalPages INTEGER NOT NULL
        CHECK (totalPages > 0),
    totalSessions INTEGER NOT NULL
        CHECK (totalSessions > 0),
        CHECK (totalPages >= 10),
        CHECK (totalPages BETWEEN (10 * totalSessions) AND (10 * totalSessions + 9)),
    planStatus TEXT NOT NULL DEFAULT 'planned'
        CHECK (planStatus IN ('planned', 'active', 'completed', 'abandoned', 'superseded')),
    planVersion INTEGER NOT NULL DEFAULT 1
        CHECK (planVersion > 0),
    previousPlanId INTEGER
        CHECK (previousPlanId IS NULL OR previousPlanId != id) -- Can't reference itself as previous plan
        CHECK (previousPlanId IS NULL OR planVersion > 1), -- If there's a previous plan, this must be version 2 or higher
    isCurrent INTEGER NOT NULL DEFAULT 1
        CHECK (isCurrent IN (0, 1)),
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1)),
    FOREIGN KEY (bookId) REFERENCES books(id) ON DELETE CASCADE
    FOREIGN KEY (previousPlanId) REFERENCES structuredReadingPlan(id)
) STRICT;

CREATE TABLE unstructuredSessionActuals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    unstructuredReadingPlanId INTEGER NOT NULL,
    sessionNumber INTEGER NOT NULL 
        DEFAULT 1 OR (SELECT COALESCE(MAX(sessionNumber), 0) + 1 FROM unstructuredSessionActuals WHERE unstructuredReadingPlanId = new.unstructuredReadingPlanId)
        CHECK (sessionNumber > 0),
    sessionDate TEXT NOT NULL
        CHECK (sessionDate IS NULL OR sessionDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),  -- ISO date (YYYY-MM-DD)
    startPage INTEGER NOT NULL
        CHECK (startPage > 0),
    endPage INTEGER NOT NULL
        CHECK (endPage >= startPage),
    pagesActual INTEGER NOT NULL
        DEFAULT (endPage - startPage + 1),
    isFinalSession INTEGER NOT NULL DEFAULT 0
        CHECK (isFinalSession IN (0,1)),
    minutesRead INTEGER CHECK (minutesRead > 0),
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1)),
    FOREIGN KEY (unstructuredReadingPlanId) REFERENCES structuredReadingPlan(id) ON DELETE CASCADE
) STRICT;

CREATE TABLE bookAuthors (
    bookId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    authorId INTEGER NOT NULL,
    authorOrder INTEGER NOT NULL DEFAULT 1
        CHECK (authorOrder > 0),
    role TEXT DEFAULT 'author'
        CHECK (role IN ('author', 'editor', 'translator', 'contributor', 'other')),
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bookId) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (authorId) REFERENCES authors(id) ON DELETE CASCADE
) STRICT;

CREATE TABLE locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT NOT NULL,
    addressLine1 TEXT,
    addressLine2 TEXT,
    city TEXT,
    stateProvince TEXT,
    postalCode TEXT
        CHECK (
            postalCode IS NULL OR
            postalCode GLOB '[0-9][0-9][0-9][0-9][0-9]' OR
            postalCode GLOB '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
        )
    countryCode TEXT,
    foreignAddress TEXT,
    isEbook INTEGER NOT NULL DEFAULT 0
        CHECK (isEbook IN (0, 1)),
    driveLocation TEXT,
    applicationName TEXT,
    notes TEXT,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1)),
    UNIQUE(description)
) STRICT;

CREATE TABLE owners (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    notes TEXT,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1)),
    UNIQUE(name)
) STRICT;

CREATE TABLE skills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
        CHECK (name != ''),
        CHECK (name lower() = name), -- Enforce lowercase for consistency
    description TEXT,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1))
) STRICT;

CREATE TABLE bookSkills (
    bookId INTEGER NOT NULL,
    skillId INTEGER NOT NULL,
    PRIMARY KEY (bookId, skillId),
    FOREIGN KEY (bookId) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (skillId) REFERENCES skills(id) ON DELETE CASCADE
) STRICT;

CREATE TABLE structuredReadingPlanSkills (
    structuredReadingPlanId INTEGER NOT NULL,
    skillId INTEGER NOT NULL,
    PRIMARY KEY (structuredReadingPlanId, skillId),
    FOREIGN KEY (structuredReadingPlanId) REFERENCES structuredReadingPlan(id) ON DELETE CASCADE,
    FOREIGN KEY (skillId) REFERENCES skills(id) ON DELETE CASCADE
) STRICT;

CREATE TABLE focuses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
        CHECK (name != ''),
        CHECK (name lower() = name), -- Enforce lowercase for consistency
    description TEXT,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1))
) STRICT;

CREATE TABLE readingNotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    content TEXT NOT NULL,
    pageStart INTEGER CHECK (pageStart IS NULL OR pageStart > 0),
    pageEnd INTEGER DEFAULT pageStart CHECK (pageEnd IS NULL OR pageEnd >= pageStart),
    chapter INTEGER CHECK (chapter IS NULL OR chapter > 0),
    noteType TEXT CHECK (noteType IN ('summary', 'question', 'quote', 'research note', 'action item', 'vocabulary', 'other')),
    tags TEXT, -- Comma-separated list of tags (e.g., "philosophy
    isQuestion INTEGER NOT NULL DEFAULT 0
        CHECK (isQuestion IN (0, 1)),
    isAnswered INTEGER NOT NULL DEFAULT 0
        CHECK (isAnswered IN (0, 1))
        CHECK !(isQuestion = 0 AND isAnswered = 1), -- Can't be marked as answered if it's not a question
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1))
) STRICT;

CREATE TABLE structuredReadingSessionNotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    structuredReadingSessionId INTEGER NOT NULL,
    readingNoteId INTEGER NOT NULL,
    FOREIGN KEY (structuredReadingSessionId) REFERENCES structuredReadingSessionActuals(id) ON DELETE CASCADE,
    FOREIGN KEY (readingNoteId) REFERENCES readingNotes(id) ON DELETE CASCADE
) STRICT;

CREATE TABLE unstructuredReadingSessionNotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    unstructuredReadingSessionId INTEGER NOT NULL,
    readingNoteId INTEGER NOT NULL,
    FOREIGN KEY (unstructuredReadingSessionId) REFERENCES unstructuredSessionActuals(id) ON DELETE CASCADE,
    FOREIGN KEY (readingNoteId) REFERENCES readingNotes(id) ON DELETE CASCADE
) STRICT;







