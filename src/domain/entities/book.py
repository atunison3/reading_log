from __future__ import annotations
from datetime import date
from pydantic import field_validator

from src.domain.entities.base_entity import BaseEntity


class Book(BaseEntity):
    title: str
    subtitle: str | None = None
    isbn10: int | None = None
    isbn13: int | None = None
    publisher: str | None = None
    publication_year: int | None = None
    edition: int | None = None
    genre_id: int | None = None
    sub_genre: str | None = None
    language_code: str | None = None

    page_count: int = 1
    current_page: int = 0
    percent_complete: float = 0.0

    focus_id: int | None = None
    location_id: int | None = None
    owner_id: int | None = None
    book_format: str | None = None

    reading_status: str = "unread"
    start_date: date | None = None
    end_date: date | None = None
    abandoned_date: date | None = None
    planning_status: str = "unplanned"
    is_progressive: bool | None = True

    rating_overall: float | None = None

    def __str__(self):
        return f"{self.title}"

    @field_validator("publication_year")
    @classmethod
    def validate_publication_year(cls, value: int | None) -> int | None:
        return cls.validate_publication_year_value(value)
