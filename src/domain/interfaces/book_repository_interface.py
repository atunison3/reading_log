from abc import ABC, abstractmethod
from datetime import datetime

from src.domain.entities.book import Book


class BookRepositoryInterface(ABC):
    @abstractmethod
    def add(self, book: Book) -> Book:
        raise NotImplementedError

    @abstractmethod
    def get_by_id(self, book_id: int) -> Book | None:
        raise NotImplementedError

    @abstractmethod
    def get_by_title(self, title: str) -> Book:
        raise NotImplementedError

    @abstractmethod
    def list_all(self) -> list[Book]:
        raise NotImplementedError

    @abstractmethod
    def update(self, book: Book) -> Book:
        raise NotImplementedError

    @abstractmethod
    def delete(self, book_id: int) -> None:
        raise NotImplementedError