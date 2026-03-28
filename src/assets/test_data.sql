

INSERT INTO owners 
    (name, email)
VALUES 
    ('Alice', 'alice@example.com'),
    ('Bob', 'bob@example.com');

INSERT INTO locations 
    (description, addressLine1, city, stateProvince, postalCode, countryCode)
VALUES 
    ('Home', '123 Main St', 'Anytown', 'Anystate', '12345', 'USA');

INSERT INTO authors 
    (firstName, lastName)
VALUES 
    ('Martin', 'Kleppmann'),
    ('Trevor', 'Hastie'),
    ('Robert', 'Tibshirani'),
    ('Jerome', 'Friedman'),
    (null, 'Lastname');

INSERT INTO focuses 
    (name, description)
VALUES 
    ('data science', 'Books focused on data science, machine learning, and related topics.'),
    ('philosophy', 'Books focused on philosophy, ethics, and related topics.'),
    ('economics', 'Books focused on economics, finance, and related topics.'),
    ('statistics', 'Books focused on statistics, probability, and related topics.');

INSERT INTO skills
    (name, description)
VALUES
    ('programming', 'Books focused on programming languages, software development, and related topics.'),
    ('critical thinking', 'Books focused on critical thinking, logic, and related topics.'),
    ('communication', 'Books focused on communication skills, writing, and related topics.'),
    ('problem-solving', 'Books focused on problem-solving techniques, puzzles, and related topics.');

INSERT INTO books 
    (title, subtitle, isbn13, publisher, publicationYear, edition, genreId, languageCode, pageCount, currentPage, focusId, locationId, ownerId, bookFormat, readingStatus, startDate, planningStatus) 
VALUES 
    ('Designing Data-Intensive Applications', 'The Big Ideas Behind Reliable, Scalable, and Maintainable Systems', '978-1-449-37332-0', 'O''Reilly Media', 2017, 1, 1, 'en', 552, 10, 1, 1, 1, 'hardcover', 'in progress', '2026-03-27', 'planned'),
    ('The Elements of Statistical Learning', 'Data Mining, Inference, and Prediction', '978-0-387-84858-7', 'Springer', 2009, 2, 1, 'en', 698, 0, 4, 1, 1, 'hardcover', 'unread', null, 'unplanned');

INSERT INTO bookSkills 
    (bookId, skillId)
VALUES 
    (1, 1), -- Designing Data-Intensive Applications is focused on programming
    (1, 4), -- Designing Data-Intensive Applications is focused on problem-solving
    (2, 2), -- The Elements of Statistical Learning is focused on critical thinking
    (2, 4); -- The Elements of Statistical Learning is focused on problem-solving

INSERT INTO bookAuthors 
    (bookId, authorId, authorOrder, role)
VALUES
    (1, 1, 1, 'author'), -- Designing Data-Intensive Applications is authored by Martin Kleppmann
    (2, 2, 1, 'author'), -- The Elements of Statistical Learning is authored by Trevor Hastie
    (2, 3, 2, 'author'), -- The Elements of Statistical Learning is authored by Robert Tibshirani
    (2, 4, 3, 'author'); -- The Elements of Statistical Learning is authored by Jerome Friedman

INSERT INTO structuredReadingPlans
    (bookId, startDate, targetEndDate, totalPages) 
VALUES 
    (1, '2026-03-26', '2026-05-20', 552),
    (2, '2026-05-21', '2026-07-29', 698);

INSERT INTO structuredReadingSessionActuals 
    (structuredReadingPlanId, sessionDate, startPage, endPage, minutesRead)
VALUES 
    (1, '2026-03-26', 1, 10, 30);

INSERT INTO readingNotes 
    (content, pageStart, chapter, noteType)
VALUES  
    ('This book is great!', 1, 1, 'comment');

INSERT INTO structuredReadingSessionNotes 
    (structuredReadingSessionId, readingNoteId)
VALUES 
    (1, 1);

INSERT INTO structuredReadingSessionPlans
    (structuredReadingPlanId, sessionDate, startPage, endPage, isFinalSession)
VALUES 
	(1, '2026-03-26', 1, 10, 0),
	(1, '2026-03-27', 11, 20, 0),
	(1, '2026-03-28', 21, 30, 0),
	(1, '2026-03-29', 31, 40, 0),
	(1, '2026-03-30', 41, 50, 0),
	(1, '2026-03-31', 51, 60, 0),
	(1, '2026-04-01', 61, 70, 0),
	(1, '2026-04-02', 71, 80, 0),
	(1, '2026-04-03', 81, 90, 0),
	(1, '2026-04-04', 91, 100, 0),
	(1, '2026-04-05', 101, 110, 0),
	(1, '2026-04-06', 111, 120, 0),
	(1, '2026-04-07', 121, 130, 0),
	(1, '2026-04-08', 131, 140, 0),
	(1, '2026-04-09', 141, 150, 0),
	(1, '2026-04-10', 151, 160, 0),
	(1, '2026-04-11', 161, 170, 0),
	(1, '2026-04-12', 171, 180, 0),
	(1, '2026-04-13', 181, 190, 0),
	(1, '2026-04-14', 191, 200, 0),
	(1, '2026-04-15', 201, 210, 0),
	(1, '2026-04-16', 211, 220, 0),
	(1, '2026-04-17', 221, 230, 0),
	(1, '2026-04-18', 231, 240, 0),
	(1, '2026-04-19', 241, 250, 0),
	(1, '2026-04-20', 251, 260, 0),
	(1, '2026-04-21', 261, 270, 0),
	(1, '2026-04-22', 271, 280, 0),
	(1, '2026-04-23', 281, 290, 0),
	(1, '2026-04-24', 291, 300, 0),
	(1, '2026-04-25', 301, 310, 0),
	(1, '2026-04-26', 311, 320, 0),
	(1, '2026-04-27', 321, 330, 0),
	(1, '2026-04-28', 331, 340, 0),
	(1, '2026-04-29', 341, 350, 0),
	(1, '2026-04-30', 351, 360, 0),
	(1, '2026-05-01', 361, 370, 0),
	(1, '2026-05-02', 371, 380, 0),
	(1, '2026-05-03', 381, 390, 0),
	(1, '2026-05-04', 391, 400, 0),
	(1, '2026-05-05', 401, 410, 0),
	(1, '2026-05-06', 411, 420, 0),
	(1, '2026-05-07', 421, 430, 0),
	(1, '2026-05-08', 431, 440, 0),
	(1, '2026-05-09', 441, 450, 0),
	(1, '2026-05-10', 451, 460, 0),
	(1, '2026-05-11', 461, 470, 0),
	(1, '2026-05-12', 471, 480, 0),
	(1, '2026-05-13', 481, 490, 0),
	(1, '2026-05-14', 491, 500, 0),
	(1, '2026-05-15', 501, 510, 0),
	(1, '2026-05-16', 511, 520, 0),
	(1, '2026-05-17', 521, 530, 0),
	(1, '2026-05-18', 531, 540, 0),
	(1, '2026-05-19', 541, 552, 1);
