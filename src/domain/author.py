from __future__ import annotations

from datetime import datetime

from pydantic import field_validator

from src.domain.base_entity import BaseEntity


class Author(BaseEntity):
    firstName: str | None = None
    middleName: str | None = None
    lastName: str
    name: str | None = None  # generated in DB, optional in model

    birthYear: int | None = None
    deathYear: int | None = None
    nationality: str | None = None
    languageCode: str | None = None

    openlibrary_id: str | None = None
    goodreads_id: str | None = None

    createdAt: datetime | None = None
    updatedAt: datetime | None = None
    isArchived: int = 0

    @field_validator('birthYear', 'deathYear')
    @classmethod
    def validate_years(cls, value: int | None) -> int | None:
        if value is None:
            return value
        if not (0 <= value <= 3000):
            raise ValueError('year must be between 0 and 3000')
        return value

    @field_validator('lastName')
    @classmethod
    def validate_last_name(cls, value: str) -> str:
        if not value or not value.strip():
            raise ValueError('lastName cannot be empty')
        return value.strip()

    @field_validator('firstName', 'middleName')
    @classmethod
    def normalize_names(cls, value: str | None) -> str | None:
        if value is None:
            return value
        return value.strip() or None
