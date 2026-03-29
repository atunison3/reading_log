import sqlite3

from src.domain.entities import StructuredReadingPlan
from src.domain.interfaces import StructuredReadingPlanRepositoryInterface
from src.repositories.sqlite_repository import SQLiteRepository


class StructuredReadingPlanRepository(
    StructuredReadingPlanRepositoryInterface, SQLiteRepository
):

    def add(self, structured_reading_plan: StructuredReadingPlan) -> int:

        conn = self._get_conn()
        cursor = conn.execute(
            """
            INSERT INTO structuredReadingPlans (
                bookId, 
                startDate, 
                targetEndDate, 
                totalPages, 
                planStatus, 
                planVersion, 
                previousPlanId, 
                isCurrent, 
                focusId
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                structured_reading_plan.book_id,
                structured_reading_plan.start_date,
                structured_reading_plan.target_end_date,
                structured_reading_plan.total_pages,
                structured_reading_plan.plan_status,
                structured_reading_plan.plan_version,
                structured_reading_plan.previous_plan_id,
                structured_reading_plan.is_current,
                structured_reading_plan.focus_id,
            ),
        )

        conn.commit()

        return int(cursor.lastrowid)

    def get_by_id(self, _id: int) -> StructuredReadingPlan | None:
        conn = self._get_conn()
        row = conn.execute(
            """
            SELECT
                id,
                createdAt AS created_at, 
                updatedAt AS updated_at, 
                isArchived AS is_archived,
                bookId AS book_id, 
                startDate AS start_date, 
                targetEndDate AS target_end_date, 
                totalPages AS total_pages, 
                totalSessions AS total_sessions, 
                planStatus AS plan_status, 
                planVersion AS plan_version, 
                previousPlanId AS previousPlanId, 
                isCurrent AS is_current, 
                focusId AS focus_id
            FROM structuredReadingPlans
            WHERE id = ?
            """,
            (_id,),
        ).fetchone()

        conn.commit()

        if row is None:
            return None

        return StructuredReadingPlan(**dict(row))

    def list_all(self) -> list[StructuredReadingPlan]:
        conn = self._get_conn()
        rows = conn.execute(
            """
                SELECT
                    id,
                    createdAt AS created_at, 
                    updatedAt AS updated_at, 
                    isArchived AS is_archived,
                    bookId AS book_id, 
                    startDate AS start_date, 
                    targetEndDate AS target_end_date, 
                    totalPages AS total_pages, 
                    totalSessions AS total_sessions, 
                    planStatus AS plan_status, 
                    planVersion AS plan_version, 
                    previousPlanId AS previousPlanId, 
                    isCurrent AS is_current, 
                    focusId AS focus_id
                FROM structuredReadingPlans
                """,
        ).fetchall()

        return [StructuredReadingPlan(**dict(row)) for row in rows]

    def update(self, structured_reading_plan: StructuredReadingPlan) -> None:
        if structured_reading_plan.id is None:
            raise ValueError("structured_reading_plan.id is required for update")

        conn = self._get_conn()
        conn.execute(
            """
            UPDATE books
            SET
                bookId = ?, 
                startDate = ?, 
                targetEndDate = ?, 
                totalPages = ?, 
                planStatus = ?, 
                planVersion = ?, 
                previousPlanId = ?, 
                isCurrent = ?, 
                focusId = ?
                updatedAt = CURRENT_TIMESTAMP
            WHERE id = ?
            """,
            (
                structured_reading_plan.book_id,
                structured_reading_plan.start_date,
                structured_reading_plan.target_end_date,
                structured_reading_plan.total_pages,
                structured_reading_plan.plan_status,
                structured_reading_plan.plan_version,
                structured_reading_plan.previous_plan_id,
                structured_reading_plan.is_current,
                structured_reading_plan.focus_id,
            ),
        )
        conn.commit()

    def delete(self, _id: int) -> None:

        conn = self._get_conn()
        conn.execute(
            "UPDATE structured_reading_plans SET isArchived = ? WHERE id = ?"(1, _id),
        )
        self.conn.commit()
