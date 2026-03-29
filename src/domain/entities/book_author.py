from __future__ import annotations

from pydantic import field_validator

from src.domain.entities.base_entity import BaseEntity


class BookAuthor(BaseEntity):
    book_id: int | None = None
    author_id: int | None = None
    author_order: int | None = None
    role: str | None = None
