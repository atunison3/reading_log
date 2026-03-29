from abc import ABC, abstractmethod
from datetime import datetime

from src.domain.entities import StructuredReadingPlan


class StructuredReadingPlanRepositoryInterface(ABC):
    @abstractmethod
    def add(
        self, strucutred_reading_plan: StructuredReadingPlan
    ) -> StructuredReadingPlan:
        raise NotImplementedError

    @abstractmethod
    def get_by_id(self, _id: int) -> StructuredReadingPlan | None:
        raise NotImplementedError

    @abstractmethod
    def list_all(self) -> list[StructuredReadingPlan]:
        raise NotImplementedError

    @abstractmethod
    def update(
        self, structured_reading_plan: StructuredReadingPlan
    ) -> StructuredReadingPlan:
        raise NotImplementedError

    @abstractmethod
    def delete(self, _id: int) -> None:
        raise NotImplementedError
