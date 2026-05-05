from __future__ import annotations

from datetime import datetime
from pathlib import Path

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator

DAG_DIR = Path(__file__).resolve().parent
SQL_DIR = DAG_DIR / "sql"


def sql_file(name: str) -> str:
    return (SQL_DIR / name).read_text(encoding="utf-8")


default_args = {
    "owner": "data-platform",
    "retries": 1,
}


with DAG(
    dag_id="daily_sales_report",
    default_args=default_args,
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
    tags=["ecommerce", "etl", "warehouse"],
) as daily_sales_report:
    create_schema = PostgresOperator(
        task_id="create_warehouse_schema",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("warehouse_schema.sql"),
    )

    refresh_warehouse = PostgresOperator(
        task_id="refresh_warehouse",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("refresh_warehouse.sql"),
    )

    build_report = PostgresOperator(
        task_id="build_daily_sales_report",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("daily_sales_report.sql"),
    )

    create_schema >> refresh_warehouse >> build_report


with DAG(
    dag_id="product_performance_report",
    default_args=default_args,
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
    tags=["ecommerce", "etl", "warehouse"],
) as product_performance_report:
    create_schema = PostgresOperator(
        task_id="create_warehouse_schema",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("warehouse_schema.sql"),
    )

    refresh_warehouse = PostgresOperator(
        task_id="refresh_warehouse",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("refresh_warehouse.sql"),
    )

    build_report = PostgresOperator(
        task_id="build_product_performance_report",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("product_performance_report.sql"),
    )

    create_schema >> refresh_warehouse >> build_report


with DAG(
    dag_id="failed_payment_report",
    default_args=default_args,
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
    tags=["ecommerce", "etl", "warehouse"],
) as failed_payment_report:
    create_schema = PostgresOperator(
        task_id="create_warehouse_schema",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("warehouse_schema.sql"),
    )

    refresh_warehouse = PostgresOperator(
        task_id="refresh_warehouse",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("refresh_warehouse.sql"),
    )

    build_report = PostgresOperator(
        task_id="build_failed_payment_report",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("failed_payment_report.sql"),
    )

    create_schema >> refresh_warehouse >> build_report


with DAG(
    dag_id="customer_order_summary",
    default_args=default_args,
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
    tags=["ecommerce", "etl", "warehouse"],
) as customer_order_summary:
    create_schema = PostgresOperator(
        task_id="create_warehouse_schema",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("warehouse_schema.sql"),
    )

    refresh_warehouse = PostgresOperator(
        task_id="refresh_warehouse",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("refresh_warehouse.sql"),
    )

    build_report = PostgresOperator(
        task_id="build_customer_order_summary",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("customer_order_summary.sql"),
    )

    create_schema >> refresh_warehouse >> build_report


with DAG(
    dag_id="security_audit_report",
    default_args=default_args,
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
    tags=["ecommerce", "etl", "warehouse"],
) as security_audit_report:
    create_schema = PostgresOperator(
        task_id="create_warehouse_schema",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("warehouse_schema.sql"),
    )

    refresh_warehouse = PostgresOperator(
        task_id="refresh_warehouse",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("refresh_warehouse.sql"),
    )

    build_report = PostgresOperator(
        task_id="build_security_audit_report",
        postgres_conn_id="ecommerce_postgres",
        sql=sql_file("security_audit_report.sql"),
    )

    create_schema >> refresh_warehouse >> build_report
