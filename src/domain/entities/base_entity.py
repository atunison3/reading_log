from datetime import datetime
from pydantic import BaseModel, ConfigDict, field_validator


class BaseEntity(BaseModel):
    model_config = ConfigDict(validate_assignment=True)

    id: int | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    is_archived: bool = False

    @field_validator("is_archived")
    @classmethod
    def validate_is_archived(cls, value: int) -> int:
        if value not in (0, 1):
            raise ValueError("is_archived must be 0 or 1")
        return value

    @classmethod
    def validate_publication_year_value(cls, value: int | None) -> int | None:
        if value is None:
            return value
        if not 0 <= value <= 2100:
            raise ValueError("publicationYear must be between 0 and 2100")
        return value
