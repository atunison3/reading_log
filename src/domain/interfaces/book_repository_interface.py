from abc import ABC, abstractmethod
from datetime import datetime

from src.domain.book import Book


class BookRepositoryInterface(ABC):
    @abstractmethod
    def create_book(self, book: Book) -> Book:
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
    def archive(self, book_id: int) -> None:
        raise NotImplementedError