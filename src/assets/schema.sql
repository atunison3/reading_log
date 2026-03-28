CREATE TABLE languageCodes (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
) STRICT;

INSERT INTO languageCodes (code, name) VALUES
    ('en', 'English'),
    ('fr', 'French'),
    ('de', 'German'),
    ('es', 'Spanish'),
    ('th', 'Thai');


CREATE TABLE genres (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
) STRICT;

INSERT INTO genres 
    (name) 
VALUES
    ('non-fiction'),
    ('fiction'),
    ('reference'),
    ('children'),
    ('young-adult');


CREATE TABLE books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    subtitle TEXT,
    isbn10 TEXT UNIQUE,
    isbn13 TEXT UNIQUE,
    publisher TEXT,
    publicationYear INTEGER CHECK (publicationYear BETWEEN -5000 AND 3000),
    edition TEXT,
    genreId TEXT,
    subGenre TEXT,
    languageCode TEXT,
    pageCount INTEGER DEFAULT 1
        CHECK (pageCount IS NULL OR pageCount > 0),
    currentPage INTEGER NOT NULL DEFAULT 0 
        CHECK (currentPage >= 0)
        CHECK (currentPage <= pageCount), -- Can't be on a page beyond the end of the book
    percentComplete REAL GENERATED ALWAYS AS (
        CASE 
            WHEN pageCount IS NULL OR pageCount = 0 THEN 0
            ELSE (currentPage * 1.0 / pageCount)
        END
    ) STORED,
    focusId INTEGER,
    locationId INTEGER,
    ownerId INTEGER,
    bookFormat TEXT CHECK (bookFormat IN ('hardcover', 'paperback', 'ebook', 'audiobook', 'pdf', 'other')),
    
    -- Tracking status -- 
    readingStatus TEXT NOT NULL DEFAULT 'unread'
        CHECK (readingStatus IN (
            'unread',
            'in progress',
            'completed',
            'abandoned',
            'paused'
        ))
        CHECK (NOT readingStatus = 'completed' OR currentPage = pageCount) -- If status is completed, current page must be equal to total pages
        CHECK (NOT readingStatus = 'unread' OR currentPage = 0), -- If status is unread, current page must be 0
    startDate TEXT -- ISO date (YYYY-MM-DD)
        CHECK (startDate IS NULL OR startDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    endDate TEXT -- ISO date (YYYY-MM-DD)
        CHECK (endDate IS NULL OR endDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]')
        CHECK (endDate IS NULL OR startDate IS NOT NULL) -- Can't have an end date without a start date
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
    isProgressive INTEGER NOT NULL DEFAULT 0
        CHECK (isProgressive IN (0, 1)),
    
    -- Tracking ratings/reviews --
    ratingOverall REAL 
        CHECK (ratingOverall IS NULL OR ratingOverall BETWEEN 0 AND 5)
        CHECK (ratingOverall IS NULL OR readingStatus IN ('completed', 'abandoned')), -- Only allow a rating if the book has been completed or abandoned
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0 CHECK (isArchived IN (0, 1)),
    FOREIGN KEY (locationId) REFERENCES locations(id) ON DELETE SET NULL,
    FOREIGN KEY (ownerId) REFERENCES owners(id) ON DELETE SET NULL,
    FOREIGN KEY (focusId) REFERENCES focuses(id) ON DELETE SET NULL,
    FOREIGN KEY (languageCode) REFERENCES languageCodes(code),
    FOREIGN KEY (genreId) REFERENCES genres(id)
) STRICT;


CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT GENERATED ALWAYS AS (
        lastName ||
        CASE 
            WHEN firstName IS NULL OR firstName = '' THEN ''
            ELSE ', ' || firstName
        END ||
        CASE 
            WHEN middleName IS NULL OR middleName = '' THEN ''
            ELSE ' ' || middleName
        END
    ) STORED
        CHECK (name != '')
        UNIQUE,
    firstName TEXT,
    middleName TEXT,
    lastName TEXT NOT NULL,
    birthYear INTEGER CHECK (birthYear IS NULL OR birthYear BETWEEN 0 AND 3000),
    deathYear INTEGER CHECK (deathYear IS NULL OR deathYear BETWEEN 0 AND 3000),
    nationality TEXT,
    languageCode TEXT,
    openlibrary_id TEXT UNIQUE,
    goodreads_id TEXT UNIQUE,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0 CHECK (isArchived IN (0,1))
) STRICT;


CREATE TABLE structuredReadingPlans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bookId INTEGER NOT NULL,
    startDate TEXT NOT NULL
        CHECK (startDate IS NULL OR startDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),              -- ISO date (YYYY-MM-DD)
    targetEndDate TEXT NOT NULL
        CHECK (targetEndDate IS NULL OR targetEndDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    
    -- Snapshot of book at planning time
    totalPages INTEGER NOT NULL
        CHECK (totalPages > 0),
    totalSessions INTEGER GENERATED ALWAYS AS (
        CAST(totalPages / 10 AS INTEGER)
    ) STORED,
    planStatus TEXT NOT NULL DEFAULT 'planned'
        CHECK (planStatus IN ('planned', 'active', 'completed', 'abandoned', 'superseded')),
    planVersion INTEGER NOT NULL DEFAULT 1
        CHECK (planVersion > 0),
    previousPlanId INTEGER
        CHECK (previousPlanId IS NULL OR previousPlanId != id) -- Can't reference itself as previous plan
        CHECK (previousPlanId IS NULL OR planVersion > 1), -- If there's a previous plan, this must be version 2 or higher
    isCurrent INTEGER NOT NULL DEFAULT 1
        CHECK (isCurrent IN (0, 1)),
    focusId INTEGER,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1)),
    FOREIGN KEY (bookId) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (previousPlanId) REFERENCES structuredReadingPlans(id),
    FOREIGN KEY (focusId) REFERENCES focuses(id)
) STRICT;


CREATE TABLE structuredReadingSessionPlans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    structuredReadingPlanId INTEGER NOT NULL,
    sessionDate TEXT NOT NULL
        CHECK (sessionDate IS NULL OR sessionDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),  -- ISO date (YYYY-MM-DD)
    startPage INTEGER NOT NULL
        CHECK (startPage > 0),
    endPage INTEGER NOT NULL
        CHECK (endPage >= startPage),
    pagesPlanned INTEGER NOT NULL
        GENERATED ALWAYS AS (endPage - startPage + 1) STORED, -- Derived but useful for validation/debugging
    isFinalSession INTEGER NOT NULL DEFAULT 0
        CHECK (isFinalSession IN (0,1)),     -- Optional flag to simplify constraints/logic
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (structuredReadingPlanId) REFERENCES structuredReadingPlans(id) ON DELETE CASCADE
) STRICT;


CREATE TABLE structuredReadingSessionActuals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    structuredReadingPlanId INTEGER NOT NULL,
    sessionDate TEXT NOT NULL
        CHECK (sessionDate IS NULL OR sessionDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),  -- ISO date (YYYY-MM-DD)
    startPage INTEGER NOT NULL
        CHECK (startPage > 0),
    endPage INTEGER NOT NULL
        CHECK (endPage >= startPage),
    pagesActual INTEGER NOT NULL
        GENERATED ALWAYS AS (endPage - startPage + 1) STORED, -- Derived but useful for validation/debugging
    isFinalSession INTEGER NOT NULL DEFAULT 0
        CHECK (isFinalSession IN (0,1)),
    minutesRead INTEGER CHECK (minutesRead > 0),
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (structuredReadingPlanId) REFERENCES structuredReadingPlans(id) ON DELETE CASCADE
) STRICT;


CREATE TABLE unstructuredReadingPlans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bookId INTEGER NOT NULL,
    startDate TEXT NOT NULL
        CHECK (startDate IS NULL OR startDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),              -- ISO date (YYYY-MM-DD)
    targetEndDate TEXT NOT NULL
        CHECK (targetEndDate IS NULL OR targetEndDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    -- Snapshot of book at planning time
    totalPages INTEGER NOT NULL
        CHECK (totalPages > 0),
    totalSessions INTEGER GENERATED ALWAYS AS (
        CAST(totalPages / 10 AS INTEGER)
    ) STORED,
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


CREATE TABLE unstructuredReadingSessionActuals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    unstructuredReadingPlanId INTEGER NOT NULL,
    sessionDate TEXT NOT NULL
        CHECK (sessionDate IS NULL OR sessionDate GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),  -- ISO date (YYYY-MM-DD)
    startPage INTEGER NOT NULL
        CHECK (startPage > 0),
    endPage INTEGER NOT NULL
        CHECK (endPage >= startPage),
    pagesActual INTEGER NOT NULL
        GENERATED ALWAYS AS (endPage - startPage + 1) STORED,
    isFinalSession INTEGER NOT NULL DEFAULT 0
        CHECK (isFinalSession IN (0,1)),
    minutesRead INTEGER CHECK (minutesRead > 0),
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1)),
    FOREIGN KEY (unstructuredReadingPlanId) REFERENCES structuredReadingPlans(id) ON DELETE CASCADE
) STRICT;


CREATE TABLE bookAuthors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bookId INTEGER NOT NULL,
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
        ),
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
        CHECK (name != '')
        CHECK (LOWER(name) = name), -- Enforce lowercase for consistency
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
        CHECK (name != '')
        CHECK (LOWER(name) = name), -- Enforce lowercase for consistency
    description TEXT,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isArchived INTEGER NOT NULL DEFAULT 0
        CHECK (isArchived IN (0, 1))
) STRICT;


CREATE TABLE readingNotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    content TEXT NOT NULL,
    pageStart INTEGER 
        CHECK (pageStart IS NULL OR pageStart > 0),
    pageEnd INTEGER
        CHECK (pageEnd IS NULL OR pageEnd >= pageStart),
    chapter INTEGER CHECK (chapter IS NULL OR chapter > 0),
    noteType TEXT CHECK (noteType IN ('summary', 'question', 'quote', 'research note', 'action item', 'vocabulary', 'comment', 'other')),
    tags TEXT, -- Comma-separated list of tags (e.g., "philosophy
    isQuestion INTEGER NOT NULL DEFAULT 0
        CHECK (isQuestion IN (0, 1)),
    isAnswered INTEGER NOT NULL DEFAULT 0
        CHECK (isAnswered IN (0, 1))
        CHECK (NOT (isQuestion = 0 AND isAnswered = 1)), -- Can't be marked as answered if it's not a question
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










