from __future__ import annotations

from src.domain.base_entity import BaseEntity




class Book(BaseEntity):
    title: str
    subtitle: str | None = None
    isbn10: str | None = None
    isbn13: str | None = None
    publisher: str | None = None
    publicationYear: int | None = None
    edition: str | None = None
    genreId: int | None = None
    subGenre: str | None = None
    languageCode: str | None = None
    pageCount: int = 1
    currentPage: int = 0
    percentComplete: float = 0.0
    focusId: int | None = None
    locationId: int | None = None
    ownerId: int | None = None
    bookFormat: str | None = None

    readingStatus: str = 'unread'
    startDate: date | None = None
    endDate: date | None = None
    abandonedDate: date | None = None

    planningStatus: str = 'unplanned'
    isProgressive: int = 0

    ratingOverall: float | None = None

    @field_validator('publicationYear')
    @classmethod
    def validate_publication_year(cls, value: int | None) -> int | None:
        return cls.validate_publication_year_value(value)