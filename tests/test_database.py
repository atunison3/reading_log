import sqlite3
import unittest
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
SCHEMA_PATH = BASE_DIR / "src" / "assets" / "schema.sql"
TEST_DATA_PATH = BASE_DIR / "src" / "assets" / "test_data.sql"


class TestReadingDatabase(unittest.TestCase):
    """Database integration tests using sqlite3 and an in-memory database."""

    @classmethod
    def setUpClass(cls) -> None:
        cls.conn = sqlite3.connect(":memory:")
        cls.conn.row_factory = sqlite3.Row
        cls.conn.execute("PRAGMA foreign_keys = ON;")
        cls._load_schema()
        cls._load_data()

    @classmethod
    def tearDownClass(cls) -> None:
        cls.conn.close()

    @classmethod
    def _load_schema(cls) -> None:
        schema_sql = SCHEMA_PATH.read_text(encoding="utf-8")
        cls.conn.executescript(schema_sql)

    @classmethod
    def _load_data(cls) -> None:
        test_data_sql = TEST_DATA_PATH.read_text(encoding="utf-8")
        cls.conn.executescript(test_data_sql)

    def test_01_schema_created(self):
        """Test that the database schema is created successfully."""
        cursor = self.conn.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = [row["name"] for row in cursor.fetchall()]
        tables.sort()

        expected_tables = [
            "languageCodes",
            "genres",
            "books",
            "authors",
            "structuredReadingPlans",
            "structuredReadingSessionPlans",
            "structuredReadingSessionActuals",
            "unstructuredReadingPlans",
            "unstructuredReadingSessionActuals",
            "bookAuthors",
            "locations",
            "owners",
            "skills",
            "bookSkills",
            "structuredReadingPlanSkills",
            "focuses",
            "readingNotes",
            "structuredReadingSessionNotes",
            "unstructuredReadingSessionNotes",
            "sqlite_sequence",
        ]
        expected_tables.sort()

        self.assertEqual(tables, expected_tables)

    def test_02_data_inserted(self):
        """Test that the test data is inserted successfully."""
        cursor = self.conn.execute("SELECT * FROM books;")
        books = cursor.fetchall()
        self.assertEqual(len(books), 2)

        # Check the percentCompletion generator
        cursor = self.conn.execute("SELECT * FROM books;")
        data = cursor.fetchall()
        self.assertAlmostEqual(data[0]["percentComplete"], 0.018, 3)
        self.assertEqual(data[1]["percentComplete"], 0)

        # Check the author.title GENERATED Function
        cursor = self.conn.execute("SELECT * FROM authors")
        data = cursor.fetchall()
        self.assertEqual(data[0]["name"], "Kleppmann, Martin")
        self.assertEqual(data[4]["name"], "Lastname")

        # Check the structuredReadingPlans.totalSessions
        cursor = self.conn.execute("SELECT * FROM structuredReadingPlans")
        data = cursor.fetchall()
        self.assertEqual(data[0]["totalSessions"], 55)

        # Check the pages planned generator
        cursor = self.conn.execute(
            """
                SELECT pagesPlanned 
                FROM structuredReadingSessionPlans 
                WHERE id = ?
            """,
            (10,),
        )
        pages_planned = cursor.fetchone()
        self.assertEqual(pages_planned["pagesPlanned"], 10)


if __name__ == "__main__":
    unittest.main()
