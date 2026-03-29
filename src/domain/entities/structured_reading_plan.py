from __future__ import annotations
from datetime import date
from pydantic import field_validator

from src.domain.entities.base_entity import BaseEntity


class StructuredReadingPlan(BaseEntity):
    book_id: int
    start_date: date | None = None
    target_end_date: date | None = None
    total_pages: int
    total_sessions: int | None = None
    plan_status: str
    plan_version: int | None = None
    previous_plan_id: int | None = None
    is_current: bool | None = None
    focus_id: int | None = None
