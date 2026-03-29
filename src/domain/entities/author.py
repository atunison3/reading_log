from __future__ import annotations

from datetime import datetime

from pydantic import field_validator

from src.domain.entities.base_entity import BaseEntity


class Author(BaseEntity):
    first_name: str | None = None
    middle_name: str | None = None
    last_name: str
    name: str | None = None  # generated in DB, optional in model
    birth_year: int | None = None
    death_year: int | None = None
    nationality: str | None = None
    openlibrary_id: str | None = None
    goodreads_id: str | None = None

    @field_validator('birth_year', 'death_year')
    @classmethod
    def validate_years(cls, value: int | None) -> int | None:
        if value is None:
            return value
        if not (0 <= value <= 3000):
            raise ValueError('year must be between 0 and 3000')
        return value

    @field_validator('last_name')
    @classmethod
    def validate_last_name(cls, value: str) -> str:
        if not value or not value.strip():
            raise ValueError('lastName cannot be empty')
        return value.strip()

    @field_validator('first_name', 'middle_name')
    @classmethod
    def normalize_names(cls, value: str | None) -> str | None:
        if value is None:
            return value
        return value.strip() or None

    def __str__(self):
        return self.name 

    def __repr__(self):
        return self.name
