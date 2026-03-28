# reading_log

## Use Cases
1. Document every book in my library
3. Set up a reading plan to read my books. 
4. Plan for which books (and what pages) to read. 
5. Document my reading notes. 
6. Record actual vs. planned reading. (I planned on reading 10 pages of book X yesterday and today. I failed to read yesterday but read 20 pages today).
7. Add research notes. 
8. Track questions I have in my reading. 
9. Questions shall be linked to a specific page in a specific book. 
10. 
11. Track book status: unread, in progress, completed, abandoned, paused.
12. Record start date, finish date, and reread history.
13. Track actual reading sessions separately from planned reading.
14. Compare planned vs actual reading by day, week, and book.
15. Attach notes to a book, chapter, page, or page range.
16. Tag notes and questions by topic.
17. Mark questions as resolved or unresolved.
18. Store quotes with exact page references.
19. Organize books into reading lists or research projects.
20. Track ownership, format, and physical location of each book.
21. Track current page and estimated completion date.
22. Record missed reading goals and reschedule them.
23. Track time spent reading in addition to pages read.
24. Generate summaries of reading progress and notes over time.

### Library management use cases:

1. Track ownership status: owned, borrowed, lent out, wish list, sold, donated, unknown.
2. Track physical location: office shelf, bedroom, Kindle, storage box, unknown, 
3. Track format: hardcover, paperback, ebook, audiobook, PDF, other. 
4. Track edition metadata: publisher, publication year, edition, language, total pages.
5. Track source/acquisition: bought from, date purchased, price paid, gift, library checkout, other. [implement later]

### Reading progress use cases:
1. Track start date, finish date, abandon date, reread date, planned date.
2. Track current page and percent complete.
3. Track reading status more precisely: unread, in progress, completed, abandoned, paused, planned.
4. Track multiple reading sessions per day, not just one daily total.
5. Track time spent reading in addition to pages read.
6. Track rereads separately from first reads.
7. Track each session's start page, finish page, and total pages.

### Planning use cases:
1. Create reading plan based on start date and number of pages. 
2. Automatically plan for 10 pages per session. 
3. Automatically plan for 1 session per day. 
4. Lump extra pages into the last session. The last session shall be minimum 10 pages but less than 21 pages to finish the book and allowing a new book to start in the next session on page 1. 
5. Track the original plan to read/finish a book. 
6. Reschedule, by pushing the finish date, when sessions are missed. (retain all previous schedules).
7. Track original plan schedule and which shedule I am on (for that book). 
8. Track whether the actual schedule aligns with the planned schedule. To be aligned, it must have the same finish date.

### Note-taking and research use cases:
1. Attach notes to a book, chapter, page, or page range.
2. Tag notes by topic, such as philosophy, economics, ontology, or quote.
3. Distinguish note types: summary, question, quote, research note, action item, vocabulary.
4. Link questions to later answers.
5. Mark notes or questions as unresolved, resolved, or worth revisiting.
6. Store quotations with page references.
7. Cross-reference one note to another note, even across different books.

### Analysis and review use cases:
1. Rate books overall and optionally by dimensions such as clarity, usefulness, difficulty, enjoyment.
2. Record whether a book was worth rereading or recommending.
3. Track themes or subjects across books.
4. Generate weekly or monthly reading summaries.
5. See which books generate the most questions or notes.
6. Measure reading pace by book or genre.
7. Estimate finish dates based on recent pace.

### Research-workflow use cases:
1. Track books that are relevant to a larger project, topic, or paper.
2. Group books into reading lists, such as “quantum computing,” “Plato,” or “behavioral economics.”
3. Track follow-up tasks created by reading, such as “look up paper,” “write summary,” or “test idea in code.”
4. Capture bibliographic references for later citation.
5. Track concepts encountered and where they first appeared.

### Integrity and audit use cases that matter for SQLite design:
1. Preserve history when plans change instead of overwriting old plans.
2. Prevent impossible states, such as page 500 in a 320-page book.
3. Ensure notes tied to a page always reference a valid book and valid page range.
4. Support transactional updates, such as logging a session and updating progress atomically.
5. Keep soft-deleted or archived records instead of fully deleting them.



As a **reader** I want to schedule a book to read. This involves providing the book information, number of pages, and planned start date. I need to see a timeline of each day from the start date to the day when the book is finished and know what page I am starting that day and what page I am finishing. Normally, I would start a book on page 1 and read 10 pages. I would read ten pages per day. So day two, I would start on page 11 and finish page 20. If the book has a number of pages not evenly divided by 10 (e.g. 261 pages), then the remainder will get lumped into the last day. 

As a **reader** I need to track my actual progress along with any notes. The application should plan each day's reading. I want to track what page I started on and what page I finished on each day along with the total number of pages I read that day. The actual should also include any notes I type up from that day. 

As a **library owner** I want to document all the books in my library. This includes tracking the book title and other metadata. I also need to track the reading status (unread, read, planned, etc). 