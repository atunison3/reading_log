import os
import sqlite3 
import unittest 
from datetime import date, timedelta
from pathlib import Path 
from sqlite3 import Connection

from src.domain.entities import Book, Author, BookAuthor
# from src.repositories.author_repository import AuthorRepository
# from src.repositories.book_repository import BookRepository 
from src.repositories import AuthorRepository, BookAuthorRepository, BookRepository
# from src.repositories.book_author_repository import BookAuthorRepository 

BASE_DIR = Path(__file__).resolve().parent.parent
SCHEMA_PATH = BASE_DIR / 'src' / 'assets' / 'schema.sql'
TEST_DATA_PATH = BASE_DIR / 'src' / 'assets' / 'test_data.sql'

class TestReadingDatabase(unittest.TestCase):
    '''Database integration tests using sqlite3 and an in-memory database.'''

    @classmethod
    def setUpClass(cls) -> None:
        try:
            os.remove('test_database.db')
        except:
            pass
        conn = sqlite3.connect('test_database.db')
        conn.row_factory = sqlite3.Row
        conn.execute('PRAGMA foreign_keys = ON;')
        cls._load_schema(conn)
        cls._load_data(conn)
        conn.close()
        
    @classmethod
    def tearDownClass(cls) -> None:
        try:
            os.remove('test_database.db')
        except:
            pass

    @classmethod
    def _load_schema(cls, conn: Connection) -> None:
        schema_sql = SCHEMA_PATH.read_text(encoding='utf-8')
        conn.executescript(schema_sql)

    @classmethod
    def _load_data(cls, conn: Connection) -> None:
        test_data_sql = TEST_DATA_PATH.read_text(encoding='utf-8')
        conn.executescript(test_data_sql)

    def test_01_book_repository(self):
        '''Test the book repository'''

        book_repository = BookRepository('test_database.db')
        
        book = Book(
            title = 'Fundamentals of Data Engineering', 
            subtitle = 'Plan and Build Robust Data Systems', 
            isbn10 = 1098108302, 
            isbn13 = 9781098108304
        )

        book.id = book_repository.add(book)
        self.assertEqual(book.id, 3)

        book.edition = 1
        book.publisher = 'O\'Reilly Media'
        book.publication_year = 2022
        book.page_count = 447
        book.current_page = 0
        book_repository.update(book)

        books = book_repository.list_all()
        self.assertEqual(len(books), 3)

        book = book_repository.get_by_title('The Elements of Statistical Learning')
        self.assertEqual(book.id, 2)

        book = book_repository.get_by_id(3)
        self.assertEqual(book.title, 'Fundamentals of Data Engineering')

        self.assertEqual(book.end_date, None)
        start_date = date(2026, 1, 1)
        end_date = start_date + timedelta(days=44)
        book.start_date = start_date
        book.end_date = end_date
        book_repository.update(book)
        book = book_repository.get_by_id(book.id)
        self.assertEqual(book.end_date, end_date)

        author_repository = AuthorRepository('test_database.db')
        authors = author_repository.list_all()
        authors.sort(key = lambda x: x.name)
        print()
        for author in authors:
            print(author)
        print()
        self.assertEqual(len(authors), 5)

        # Test adding an author
        author = Author(
            first_name = 'Joe',
            last_name = 'Reis'
        )
        author.id = author_repository.add(author)
        self.assertEqual(author.id, 6)






        


