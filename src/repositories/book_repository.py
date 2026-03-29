import sqlite3

from src.domain.entities.book import Book
from src.domain.interfaces.book_repository_interface import BookRepositoryInterface
from src.repositories.sqlite_repository import SQLiteRepository

class BookRepository(BookRepositoryInterface, SQLiteRepository):

    def add(self, book: Book) -> int:

        conn = self._get_conn()
        cursor = conn.execute(
            '''
            INSERT INTO books (
                title,
                subtitle,
                isbn10,
                isbn13,
                publisher,
                publicationYear,
                edition,
                genreId,
                subGenre, 
                languageCode, 
                pageCount, 
                currentPage, 
                focusId, 
                locationId, 
                ownerId, 
                bookFormat, 
                readingStatus, 
                startDate, 
                endDate, 
                abandonedDate, 
                planningStatus, 
                isProgressive, 
                ratingOverall
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            (
                book.title,
                book.subtitle,
                book.isbn10,
                book.isbn13,
                book.publisher,
                book.publication_year,
                book.edition,
                book.genre_id,
                book.sub_genre, 
                book.language_code, 
                book.page_count, 
                book.current_page,
                book.focus_id, 
                book.location_id, 
                book.owner_id, 
                book.book_format, 
                book.reading_status, 
                book.start_date, 
                book.end_date, 
                book.abandoned_date, 
                book.planning_status, 
                book.is_progressive, 
                book.rating_overall
            )
        )

        conn.commit()

        return int(cursor.lastrowid)

    def get_by_id(self, book_id: int) -> Book | None:
        conn = self._get_conn()
        row = conn.execute(
            '''
            SELECT
                id,
                title,
                subtitle,
                isbn10,
                isbn13,
                publisher,
                publicationYear AS publisher_year,
                edition,
                genreId AS genre_id,
                subGenre AS sub_genre, 
                languageCode AS language_code, 
                pageCount AS page_count, 
                currentPage AS current_page, 
                percentComplete AS percent_complete, 
                focusId AS focus_id, 
                locationId AS location_id, 
                ownerId AS owner_id, 
                bookFormat AS book_format, 
                readingStatus AS reading_status, 
                startDate AS start_date, 
                endDate AS end_date, 
                abandonedDate AS abandoned_date, 
                planningStatus AS planning_status, 
                isProgressive AS is_progressive, 
                ratingOverall AS rating_overall,
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                isArchived AS is_archived
            FROM books
            WHERE id = ?
            ''',
            (book_id,),
        ).fetchone()

        conn.commit()

        if row is None:
            return None

        return Book(**dict(row))

    def get_by_title(self, title: str) -> Book:
        '''Gets by title'''

        conn = self._get_conn()
        row = conn.execute(
                '''
                SELECT
                    id,
                    title,
                    subtitle,
                    isbn10,
                    isbn13,
                    publisher,
                    publicationYear AS publisher_year,
                    edition,
                    genreId AS genre_id,
                    subGenre AS sub_genre, 
                    languageCode AS language_code, 
                    pageCount AS page_count, 
                    currentPage AS current_page, 
                    percentComplete AS percent_complete, 
                    focusId AS focus_id, 
                    locationId AS location_id, 
                    ownerId AS owner_id, 
                    bookFormat AS book_format, 
                    readingStatus AS reading_status, 
                    startDate AS start_date, 
                    endDate AS end_date, 
                    abandonedDate AS abandoned_date, 
                    planningStatus AS planning_status, 
                    isProgressive AS is_progressive, 
                    ratingOverall AS rating_overall
                FROM books
                WHERE title = ?
                ORDER BY edition DESC 
                LIMIT 1
                ''',
                (title,),
            ).fetchone()

        if row is None:
            return None

        return Book(**dict(row))

    def list_all(self) -> list[Book]:
        conn = self._get_conn()
        rows = conn.execute(
                '''
                SELECT
                    id,
                    title,
                    subtitle,
                    isbn10,
                    isbn13,
                    publisher,
                    publicationYear AS publisher_year,
                    edition,
                    genreId AS genre_id,
                    subGenre AS sub_genre, 
                    languageCode AS language_code, 
                    pageCount AS page_count, 
                    currentPage AS current_page, 
                    percentComplete AS percent_complete, 
                    focusId AS focus_id, 
                    locationId AS location_id, 
                    ownerId AS owner_id, 
                    bookFormat AS book_format, 
                    readingStatus AS reading_status, 
                    startDate AS start_date, 
                    endDate AS end_date, 
                    abandonedDate AS abandoned_date, 
                    planningStatus AS planning_status, 
                    isProgressive AS is_progressive, 
                    ratingOverall AS rating_overall
                FROM books
                ''',
            ).fetchall()

        return [Book(**dict(row)) for row in rows]

    def update(self, book: Book) -> None:
        if book.id is None:
            raise ValueError('book.id is required for update')

        conn = self._get_conn()
        conn.execute(
            '''
            UPDATE books
            SET
                title = ?,
                subtitle = ?,
                isbn10 = ?,
                isbn13 = ?,
                publisher = ?,
                publicationYear = ?,
                edition = ?,
                genreId = ?,
                subGenre = ?, 
                languageCode = ?, 
                pageCount = ?, 
                currentPage = ?, 
                focusId = ?, 
                locationId = ?, 
                ownerId = ?, 
                bookFormat = ?, 
                readingStatus = ?, 
                startDate = ?, 
                endDate = ?, 
                abandonedDate = ?, 
                planningStatus = ?, 
                isProgressive = ?, 
                ratingOverall = ?,
                updatedAt = CURRENT_TIMESTAMP
            WHERE id = ?
            ''',
            (
                book.title,
                book.subtitle,
                book.isbn10,
                book.isbn13,
                book.publisher,
                book.publication_year,
                book.edition,
                book.genre_id,
                book.sub_genre, 
                book.language_code, 
                book.page_count, 
                book.current_page, 
                book.focus_id, 
                book.location_id, 
                book.owner_id, 
                book.book_format, 
                book.reading_status, 
                book.start_date, 
                book.end_date, 
                book.abandoned_date, 
                book.planning_status, 
                book.is_progressive, 
                book.rating_overall,
                book.id
            ),
        )
        conn.commit()

    def delete(self, book_id: int) -> None:

        conn = self._get_conn()
        conn.execute(
            'UPDATE books SET isArchived = ? WHERE id = ?'
            (1, book_id),
        )
        self.conn.commit()