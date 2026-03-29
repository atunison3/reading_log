from abc import ABC, abstractmethod
from datetime import datetime

from src.domain.entities.book_author import BookAuthor


class BookAuthorRepositoryInterface(ABC):
    @abstractmethod
    def add(self, book_author: BookAuthor) -> BookAuthor:
        raise NotImplementedError

    @abstractmethod
    def get_by_id(self, book_author_id: int) -> BookAuthor | None:
        raise NotImplementedError

    @abstractmethod
    def get_by_book_id(self, book_id: int) -> list[BookAuthor]:
        raise NotImplementedError

    @abstractmethod
    def update(self, book_author: BookAuthor) -> BookAuthor:
        raise NotImplementedError

    @abstractmethod
    def delete(self, book_author_id: int) -> None:
        raise NotImplementedError
