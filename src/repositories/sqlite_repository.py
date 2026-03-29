import sqlite3

from datetime import date
from sqlite3 import Connection

from src.domain.entities.base_entity import BaseEntity


class SQLiteRepository:
    def __init__(self, db_path: str) -> None:
        self.db_path = db_path

    @staticmethod
    def adapt_date(value: date) -> str:
        """Serialize date to yyyy-mm-dd string."""
        return value.isoformat()

    def _get_conn(self) -> Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row

        return conn

    def _update_entity(self, obj: BaseEntity, data: dict) -> BaseEntity:
        """Configure the returning data into the base entity."""
        return obj.model_copy(update=data)


sqlite3.register_adapter(date, SQLiteRepository.adapt_date)
