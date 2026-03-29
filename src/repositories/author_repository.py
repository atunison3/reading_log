import sqlite3

from src.domain.entities import Author
from src.domain.interfaces.author_repository_interface import AuthorRepositoryInterface
from src.repositories.sqlite_repository import SQLiteRepository

class AuthorRepository(AuthorRepositoryInterface, SQLiteRepository):

    def add(self, author: Author) -> int:

        conn = self._get_conn()
        cursor = conn.execute(
            '''
            INSERT INTO authors (
                firstName,
                middleName,
                lastName,
                birthYear,
                deathYear,
                nationality,
                openlibraryId,
                goodreadsId
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            (
                author.first_name,
                author.middle_name,
                author.last_name,
                author.birth_year,
                author.death_year,
                author.nationality,
                author.openlibrary_id,
                author.goodreads_id
            ),
        )

        conn.commit()

        return int(cursor.lastrowid)

    def get_by_id(self, author_id: int) -> Author | None:

        conn = self._get_conn()
        row = conn.execute(
            '''
            SELECT
                id, 
                name, 
                firstName AS first_name, 
                middleName AS middle_name, 
                lastName AS last_name, 
                birthYear AS birth_year, 
                deathYear AS death_year, 
                nationality, 
                openlibraryId AS openlibrary_id, 
                goodreadsId AS goodreads_id, 
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                isArchived AS is_archived
            FROM authors
            WHERE id = ?
            ''',
            (author_id,),
        ).fetchone()

        if row is None:
            return None

        return Author(**dict(row))

    def get_by_name(self, author_name: int) -> Author | None:

        conn = self._get_conn()
        row = conn.execute(
            '''
            SELECT
                id, 
                name, 
                firstName AS first_name, 
                middleName AS middle_name, 
                lastName AS last_name, 
                birthYear AS birth_year, 
                deathYear AS death_year, 
                nationality, 
                openlibraryId AS openlibrary_id, 
                goodreadsId AS goodreads_id, 
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                isArchived AS is_archived
            FROM authors
            WHERE name = ?
            ''',
            (author_name,),
        ).fetchone()

        if row is None:
            return None

        return Author(**dict(row))

    def list_all(self) -> list[Author]:

        conn = self._get_conn()
        rows = conn.execute(
            '''
            SELECT
                id, 
                name, 
                firstName AS first_name, 
                middleName AS middle_name, 
                lastName AS last_name, 
                birthYear AS birth_year, 
                deathYear AS death_year, 
                nationality, 
                openlibraryId AS openlibrary_id, 
                goodreadsId AS goodreads_id, 
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                isArchived AS is_archived
            FROM authors
            ORDER BY name
            '''
        ).fetchall()

        return [Author(**dict(row)) for row in rows]

    def update(self, author: Author) -> None:
        if author.id is None:
            raise ValueError('author.id is required for update')

        conn = self._get_conn()
        conn.execute(
            '''
            UPDATE authors
            SET
                firstName = ?,
                middleName = ?,
                lastName = ?,
                birthYear = ?,
                deathYear = ?,
                nationality = ?,
                openlibraryId = ?,
                goodreadsId = ?,
                updatedAt = CURRENT_TIMESTAMP
            WHERE id = ?
            ''',
            (
                author.first_name,
                author.middle_name,
                author.last_name,
                author.birth_year,
                author.death_year,
                author.nationality,
                author.openlibrary_id,
                author.goodreads_id,
                author.id,
            ),
        )
        conn.commit()

    def delete(self, author_id: int) -> None:

        conn = self._get_conn()
        conn.execute(
            'UPDATE Authors SET isArchived = ? WHERE id = ?',
            (1, author_id,),
        )
        conn.commit()