import sqlite3

from src.domain.entities import BookAuthor
from src.domain.interfaces import BookAuthorRepositoryInterface
from src.repositories.sqlite_repository import SQLiteRepository


class BookAuthorRepository(BookAuthorRepositoryInterface, SQLiteRepository):

    def add(self, book_author: BookAuthor) -> int:

        conn = self._get_conn()
        cursor = conn.execute(
            """
            INSERT INTO bookAuthors (
                bookId, 
                authorId, 
                authorOrder, 
                role
            )
            VALUES (?, ?, ?, ?)
            """,
            (
                book_author.book_id,
                book_author.author_id,
                book_author.author_order,
                book_author.role,
            ),
        )

        conn.commit()

        return int(cursor.lastrowid)

    def get_by_id(self, book_author_id: int) -> BookAuthor | None:

        conn = self._get_conn()
        row = conn.execute(
            """
            SELECT
                id, 
                bookId AS book_id, 
                authorId AS author_id, 
                authorOrder AS author_order, 
                role, 
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                is_archived AS is_archived
            FROM bookAuthors
            WHERE id = ?
            """,
            (book_author_id,),
        ).fetchone()

        if row is None:
            return None

        return BookAuthor(**dict(row))

    def get_by_book_id(self, book_id: int) -> list[BookAuthor] | None:

        conn = self._get_conn()
        rows = conn.execute(
            """
            SELECT
                id, 
                bookId AS book_id, 
                authorId AS author_id, 
                authorOrder AS author_order, 
                role, 
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                isArchived AS is_archived
            FROM bookAuthors
            WHERE bookId = ?
            ORDER BY authorOrder
            """,
            (book_id,),
        ).fetchall()

        if rows is None:
            return [None]

        return [BookAuthor(**dict(row)) for row in rows]

    def list_all(self) -> list[BookAuthor]:

        conn = self._get_conn()
        rows = conn.execute(
            """
            SELECT
                id, 
                bookId AS book_id, 
                authorId AS author_id, 
                authorOrder AS author_order, 
                role, 
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                is_archived AS is_archived
            FROM authors
            ORDER BY bookId, authorOrder
            """
        ).fetchall()

        return [BookAuthor(**dict(row)) for row in rows]

    def update(self, book_author: BookAuthor) -> None:
        if author.id is None:
            raise ValueError("author.id is required for update")

        conn = self._get_conn()
        conn.execute(
            """
            UPDATE bookAuthors
            SET
                bookId = ?,
                authorId = ?,
                authorOrder = ?,
                role = ?,
                updatedAt = CURRENT_TIMESTAMP
            WHERE id = ?
            """,
            (
                author.book_id,
                author.authorId,
                author.authorOrder,
                author.role,
                author.id,
            ),
        )
        conn.commit()

    def delete(self, book_author_id: int) -> None:

        conn = self._get_conn()
        conn.execute(
            "DELETE FROM bookAuthors WHERE id = ?",
            (book_author_id,),
        )
        conn.commit()
