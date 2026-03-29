from abc import ABC, abstractmethod

from src.domain.entities.author import Author


class AuthorRepositoryInterface(ABC):
    @abstractmethod
    def add(self, author: Author) -> int:
        raise NotImplementedError

    @abstractmethod
    def get_by_id(self, author_id: int) -> Author | None:
        raise NotImplementedError

    @abstractmethod
    def get_by_name(self, author_name: str) -> Author | None:
        raise NotImplementedError

    @abstractmethod
    def list_all(self) -> list[Author]:
        raise NotImplementedError

    @abstractmethod
    def update(self, author: Author) -> None:
        raise NotImplementedError

    @abstractmethod
    def delete(self, author_id: int) -> None:
        raise NotImplementedError
