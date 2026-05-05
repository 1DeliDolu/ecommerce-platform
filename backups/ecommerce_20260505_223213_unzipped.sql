--
-- PostgreSQL database dump
--

\restrict 6eUgHkO7PZTDvJRhTOhWHfx6WpbpNWPA6rrqdKziwQ5Y85Rdhymh8sV0g73Mgr0

-- Dumped from database version 17.9 (Debian 17.9-1.pgdg12+1)
-- Dumped by pg_dump version 17.9 (Debian 17.9-1.pgdg12+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dw; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA dw;


--
-- Name: reports; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA reports;


--
-- Name: staging; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA staging;


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dim_customer; Type: TABLE; Schema: dw; Owner: -
--

CREATE TABLE dw.dim_customer (
    customer_key bigint NOT NULL,
    email character varying(255) NOT NULL
);


--
-- Name: dim_customer_customer_key_seq; Type: SEQUENCE; Schema: dw; Owner: -
--

CREATE SEQUENCE dw.dim_customer_customer_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dim_customer_customer_key_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: -
--

ALTER SEQUENCE dw.dim_customer_customer_key_seq OWNED BY dw.dim_customer.customer_key;


--
-- Name: dim_date; Type: TABLE; Schema: dw; Owner: -
--

CREATE TABLE dw.dim_date (
    date_key date NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    day integer NOT NULL
);


--
-- Name: dim_product; Type: TABLE; Schema: dw; Owner: -
--

CREATE TABLE dw.dim_product (
    product_key bigint NOT NULL,
    product_id bigint NOT NULL,
    name character varying(160),
    slug character varying(180),
    category_id bigint,
    current_price numeric(12,2),
    status character varying(20)
);


--
-- Name: dim_product_product_key_seq; Type: SEQUENCE; Schema: dw; Owner: -
--

CREATE SEQUENCE dw.dim_product_product_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dim_product_product_key_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: -
--

ALTER SEQUENCE dw.dim_product_product_key_seq OWNED BY dw.dim_product.product_key;


--
-- Name: fact_inventory; Type: TABLE; Schema: dw; Owner: -
--

CREATE TABLE dw.fact_inventory (
    product_id bigint NOT NULL,
    product_key bigint,
    stock_quantity integer,
    snapshot_date date
);


--
-- Name: fact_orders; Type: TABLE; Schema: dw; Owner: -
--

CREATE TABLE dw.fact_orders (
    order_id bigint NOT NULL,
    order_number character varying(255),
    customer_key bigint,
    date_key date,
    status character varying(40),
    subtotal numeric(12,2),
    shipping_cost numeric(12,2),
    tax numeric(12,2),
    total_amount numeric(12,2),
    item_count integer
);


--
-- Name: fact_payments; Type: TABLE; Schema: dw; Owner: -
--

CREATE TABLE dw.fact_payments (
    payment_reference character varying(255) NOT NULL,
    order_id bigint,
    date_key date,
    payment_method character varying(255),
    status character varying(40),
    amount numeric(12,2)
);


--
-- Name: ab_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: ab_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_permission_id_seq OWNED BY public.ab_permission.id;


--
-- Name: ab_permission_view; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);


--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_permission_view_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_permission_view_id_seq OWNED BY public.ab_permission_view.id;


--
-- Name: ab_permission_view_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);


--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_permission_view_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_permission_view_role_id_seq OWNED BY public.ab_permission_view_role.id;


--
-- Name: ab_register_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_register_user (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    username character varying(512) NOT NULL,
    password character varying(256),
    email character varying(512) NOT NULL,
    registration_date timestamp without time zone,
    registration_hash character varying(256)
);


--
-- Name: ab_register_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_register_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_register_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_register_user_id_seq OWNED BY public.ab_register_user.id;


--
-- Name: ab_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


--
-- Name: ab_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_role_id_seq OWNED BY public.ab_role.id;


--
-- Name: ab_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_user (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    username character varying(512) NOT NULL,
    password character varying(256),
    active boolean,
    email character varying(512) NOT NULL,
    last_login timestamp without time zone,
    login_count integer,
    fail_login_count integer,
    created_on timestamp without time zone,
    changed_on timestamp without time zone,
    created_by_fk integer,
    changed_by_fk integer
);


--
-- Name: ab_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_user_id_seq OWNED BY public.ab_user.id;


--
-- Name: ab_user_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);


--
-- Name: ab_user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_user_role_id_seq OWNED BY public.ab_user_role.id;


--
-- Name: ab_view_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_view_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_view_menu_id_seq OWNED BY public.ab_view_menu.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: app_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_user (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    email character varying(255) NOT NULL,
    enabled boolean NOT NULL,
    full_name character varying(255),
    password_hash character varying(255) NOT NULL,
    permissions character varying(2000),
    role character varying(255) NOT NULL,
    failed_login_attempts integer DEFAULT 0 NOT NULL,
    locked_until timestamp with time zone
);


--
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.app_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    actor_user_id bigint,
    actor_email character varying(255),
    action character varying(120) NOT NULL,
    resource_type character varying(120) NOT NULL,
    resource_id character varying(120),
    ip_address character varying(64),
    user_agent character varying(500),
    details text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: callback_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.callback_request (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    priority_weight integer NOT NULL,
    callback_data json NOT NULL,
    callback_type character varying(20) NOT NULL,
    processor_subdir character varying(2000)
);


--
-- Name: callback_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.callback_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: callback_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.callback_request_id_seq OWNED BY public.callback_request.id;


--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_items (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    quantity integer NOT NULL,
    updated_at timestamp(6) without time zone,
    user_email character varying(255) NOT NULL,
    product_id bigint NOT NULL
);


--
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.cart_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.cart_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category (
    id bigint NOT NULL,
    created_at date NOT NULL,
    description character varying(1000),
    name character varying(120) NOT NULL,
    product_count integer NOT NULL,
    slug character varying(140) NOT NULL,
    status character varying(20) NOT NULL,
    CONSTRAINT category_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.category ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: connection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.connection (
    id integer NOT NULL,
    conn_id character varying(250) NOT NULL,
    conn_type character varying(500) NOT NULL,
    description text,
    host character varying(500),
    schema character varying(500),
    login text,
    password text,
    port integer,
    is_encrypted boolean,
    is_extra_encrypted boolean,
    extra text
);


--
-- Name: connection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.connection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: connection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.connection_id_seq OWNED BY public.connection.id;


--
-- Name: customer_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_order_items (
    id bigint NOT NULL,
    line_total numeric(12,2) NOT NULL,
    product_name character varying(255) NOT NULL,
    product_slug character varying(255) NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    order_id bigint NOT NULL,
    product_id bigint NOT NULL
);


--
-- Name: customer_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.customer_order_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.customer_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customer_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_orders (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    order_number character varying(255) NOT NULL,
    payment_method character varying(255) NOT NULL,
    payment_reference character varying(255) NOT NULL,
    shipping_city character varying(255) NOT NULL,
    shipping_cost numeric(12,2) NOT NULL,
    shipping_country character varying(255) NOT NULL,
    shipping_email character varying(255) NOT NULL,
    shipping_full_name character varying(255) NOT NULL,
    shipping_phone character varying(255) NOT NULL,
    shipping_postal_code character varying(255) NOT NULL,
    shipping_street character varying(255) NOT NULL,
    status character varying(20) NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    tax numeric(12,2) NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    user_email character varying(255) NOT NULL,
    CONSTRAINT customer_orders_status_check CHECK (((status)::text = ANY ((ARRAY['CREATED'::character varying, 'PAID'::character varying, 'PAYMENT_FAILED'::character varying, 'CANCELLED'::character varying, 'SHIPPED'::character varying, 'DELIVERED'::character varying])::text[])))
);


--
-- Name: customer_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.customer_orders ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.customer_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: dag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag (
    dag_id character varying(250) NOT NULL,
    root_dag_id character varying(250),
    is_paused boolean,
    is_subdag boolean,
    is_active boolean,
    last_parsed_time timestamp with time zone,
    last_pickled timestamp with time zone,
    last_expired timestamp with time zone,
    scheduler_lock boolean,
    pickle_id integer,
    fileloc character varying(2000),
    processor_subdir character varying(2000),
    owners character varying(2000),
    dag_display_name character varying(2000),
    description text,
    default_view character varying(25),
    schedule_interval text,
    timetable_description character varying(1000),
    dataset_expression json,
    max_active_tasks integer NOT NULL,
    max_active_runs integer,
    max_consecutive_failed_dag_runs integer NOT NULL,
    has_task_concurrency_limits boolean NOT NULL,
    has_import_errors boolean DEFAULT false,
    next_dagrun timestamp with time zone,
    next_dagrun_data_interval_start timestamp with time zone,
    next_dagrun_data_interval_end timestamp with time zone,
    next_dagrun_create_after timestamp with time zone
);


--
-- Name: dag_code; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_code (
    fileloc_hash bigint NOT NULL,
    fileloc character varying(2000) NOT NULL,
    last_updated timestamp with time zone NOT NULL,
    source_code text NOT NULL
);


--
-- Name: dag_owner_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_owner_attributes (
    dag_id character varying(250) NOT NULL,
    owner character varying(500) NOT NULL,
    link character varying(500) NOT NULL
);


--
-- Name: dag_pickle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_pickle (
    id integer NOT NULL,
    pickle bytea,
    created_dttm timestamp with time zone,
    pickle_hash bigint
);


--
-- Name: dag_pickle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dag_pickle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dag_pickle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dag_pickle_id_seq OWNED BY public.dag_pickle.id;


--
-- Name: dag_priority_parsing_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_priority_parsing_request (
    id character varying(32) NOT NULL,
    fileloc character varying(2000) NOT NULL
);


--
-- Name: dag_run; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_run (
    id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    queued_at timestamp with time zone,
    execution_date timestamp with time zone NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    state character varying(50),
    run_id character varying(250) NOT NULL,
    creating_job_id integer,
    external_trigger boolean,
    run_type character varying(50) NOT NULL,
    conf bytea,
    data_interval_start timestamp with time zone,
    data_interval_end timestamp with time zone,
    last_scheduling_decision timestamp with time zone,
    dag_hash character varying(32),
    log_template_id integer,
    updated_at timestamp with time zone,
    clear_number integer DEFAULT 0 NOT NULL
);


--
-- Name: dag_run_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dag_run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dag_run_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dag_run_id_seq OWNED BY public.dag_run.id;


--
-- Name: dag_run_note; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_run_note (
    user_id integer,
    dag_run_id integer NOT NULL,
    content character varying(1000),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: dag_schedule_dataset_alias_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_schedule_dataset_alias_reference (
    alias_id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: dag_schedule_dataset_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_schedule_dataset_reference (
    dataset_id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: dag_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_tag (
    name character varying(100) NOT NULL,
    dag_id character varying(250) NOT NULL
);


--
-- Name: dag_warning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dag_warning (
    dag_id character varying(250) NOT NULL,
    warning_type character varying(50) NOT NULL,
    message text NOT NULL,
    "timestamp" timestamp with time zone NOT NULL
);


--
-- Name: dagrun_dataset_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dagrun_dataset_event (
    dag_run_id integer NOT NULL,
    event_id integer NOT NULL
);


--
-- Name: dataset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset (
    id integer NOT NULL,
    uri character varying(3000) NOT NULL,
    extra json NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    is_orphaned boolean DEFAULT false NOT NULL
);


--
-- Name: dataset_alias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset_alias (
    id integer NOT NULL,
    name character varying(3000) NOT NULL
);


--
-- Name: dataset_alias_dataset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset_alias_dataset (
    alias_id integer NOT NULL,
    dataset_id integer NOT NULL
);


--
-- Name: dataset_alias_dataset_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset_alias_dataset_event (
    alias_id integer NOT NULL,
    event_id integer NOT NULL
);


--
-- Name: dataset_alias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dataset_alias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dataset_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dataset_alias_id_seq OWNED BY public.dataset_alias.id;


--
-- Name: dataset_dag_run_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset_dag_run_queue (
    dataset_id integer NOT NULL,
    target_dag_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: dataset_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset_event (
    id integer NOT NULL,
    dataset_id integer NOT NULL,
    extra json NOT NULL,
    source_task_id character varying(250),
    source_dag_id character varying(250),
    source_run_id character varying(250),
    source_map_index integer DEFAULT '-1'::integer,
    "timestamp" timestamp with time zone NOT NULL
);


--
-- Name: dataset_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dataset_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dataset_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dataset_event_id_seq OWNED BY public.dataset_event.id;


--
-- Name: dataset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dataset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dataset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dataset_id_seq OWNED BY public.dataset.id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


--
-- Name: import_error; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_error (
    id integer NOT NULL,
    "timestamp" timestamp with time zone,
    filename character varying(1024),
    stacktrace text,
    processor_subdir character varying(2000)
);


--
-- Name: import_error_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.import_error_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.import_error_id_seq OWNED BY public.import_error.id;


--
-- Name: job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job (
    id integer NOT NULL,
    dag_id character varying(250),
    state character varying(20),
    job_type character varying(30),
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    latest_heartbeat timestamp with time zone,
    executor_class character varying(500),
    hostname character varying(500),
    unixname character varying(1000)
);


--
-- Name: job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_id_seq OWNED BY public.job.id;


--
-- Name: log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log (
    id integer NOT NULL,
    dttm timestamp with time zone,
    dag_id character varying(250),
    task_id character varying(250),
    map_index integer,
    event character varying(60),
    execution_date timestamp with time zone,
    run_id character varying(250),
    owner character varying(500),
    owner_display_name character varying(500),
    extra text,
    try_number integer
);


--
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- Name: log_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log_template (
    id integer NOT NULL,
    filename text NOT NULL,
    elasticsearch_id text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: log_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_template_id_seq OWNED BY public.log_template.id;


--
-- Name: login_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_attempts (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    success boolean NOT NULL,
    ip_address character varying(64),
    user_agent character varying(500),
    failure_code character varying(120),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: login_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.login_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: login_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.login_attempts_id_seq OWNED BY public.login_attempts.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    payment_reference character varying(255) NOT NULL,
    method character varying(50) NOT NULL,
    status character varying(50) NOT NULL,
    amount numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_payments_amount CHECK ((amount >= (0)::numeric))
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    name character varying(120) NOT NULL,
    description character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
    id bigint NOT NULL,
    content_type character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    file_size bigint NOT NULL,
    image_order integer NOT NULL,
    original_file_name character varying(255) NOT NULL,
    primary_image boolean NOT NULL,
    relative_path character varying(600) NOT NULL,
    stored_file_name character varying(255) NOT NULL,
    product_id bigint NOT NULL
);


--
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product_images ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description character varying(2000),
    name character varying(160) NOT NULL,
    price numeric(12,2) NOT NULL,
    slug character varying(180) NOT NULL,
    status character varying(20) NOT NULL,
    stock_quantity integer NOT NULL,
    updated_at timestamp(6) without time zone,
    category_id bigint NOT NULL,
    CONSTRAINT products_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.products ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token_hash character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: rendered_task_instance_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rendered_task_instance_fields (
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    rendered_fields json NOT NULL,
    k8s_pod_yaml json
);


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: serialized_dag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.serialized_dag (
    dag_id character varying(250) NOT NULL,
    fileloc character varying(2000) NOT NULL,
    fileloc_hash bigint NOT NULL,
    data json,
    data_compressed bytea,
    last_updated timestamp with time zone NOT NULL,
    dag_hash character varying(32) NOT NULL,
    processor_subdir character varying(2000)
);


--
-- Name: session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session (
    id integer NOT NULL,
    session_id character varying(255),
    data bytea,
    expiry timestamp without time zone
);


--
-- Name: session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.session_id_seq OWNED BY public.session.id;


--
-- Name: sla_miss; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sla_miss (
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    execution_date timestamp with time zone NOT NULL,
    email_sent boolean,
    "timestamp" timestamp with time zone,
    description text,
    notification_sent boolean
);


--
-- Name: slot_pool; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slot_pool (
    id integer NOT NULL,
    pool character varying(256),
    slots integer,
    description text,
    include_deferred boolean NOT NULL
);


--
-- Name: slot_pool_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slot_pool_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slot_pool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slot_pool_id_seq OWNED BY public.slot_pool.id;


--
-- Name: task_fail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_fail (
    id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    duration integer
);


--
-- Name: task_fail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_fail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_fail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_fail_id_seq OWNED BY public.task_fail.id;


--
-- Name: task_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_instance (
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    duration double precision,
    state character varying(20),
    try_number integer,
    max_tries integer DEFAULT '-1'::integer,
    hostname character varying(1000),
    unixname character varying(1000),
    job_id integer,
    pool character varying(256) NOT NULL,
    pool_slots integer NOT NULL,
    queue character varying(256),
    priority_weight integer,
    operator character varying(1000),
    custom_operator_name character varying(1000),
    queued_dttm timestamp with time zone,
    queued_by_job_id integer,
    pid integer,
    executor character varying(1000),
    executor_config bytea,
    updated_at timestamp with time zone,
    rendered_map_index character varying(250),
    external_executor_id character varying(250),
    trigger_id integer,
    trigger_timeout timestamp without time zone,
    next_method character varying(1000),
    next_kwargs json,
    task_display_name character varying(2000)
);


--
-- Name: task_instance_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_instance_history (
    id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    try_number integer NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    duration double precision,
    state character varying(20),
    max_tries integer DEFAULT '-1'::integer,
    hostname character varying(1000),
    unixname character varying(1000),
    job_id integer,
    pool character varying(256) NOT NULL,
    pool_slots integer NOT NULL,
    queue character varying(256),
    priority_weight integer,
    operator character varying(1000),
    custom_operator_name character varying(1000),
    queued_dttm timestamp with time zone,
    queued_by_job_id integer,
    pid integer,
    executor character varying(1000),
    executor_config bytea,
    updated_at timestamp with time zone,
    rendered_map_index character varying(250),
    external_executor_id character varying(250),
    trigger_id integer,
    trigger_timeout timestamp without time zone,
    next_method character varying(1000),
    next_kwargs json,
    task_display_name character varying(2000)
);


--
-- Name: task_instance_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_instance_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_instance_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_instance_history_id_seq OWNED BY public.task_instance_history.id;


--
-- Name: task_instance_note; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_instance_note (
    user_id integer,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer NOT NULL,
    content character varying(1000),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: task_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_map (
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer NOT NULL,
    length integer NOT NULL,
    keys json,
    CONSTRAINT ck_task_map_task_map_length_not_negative CHECK ((length >= 0))
);


--
-- Name: task_outlet_dataset_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_outlet_dataset_reference (
    dataset_id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: task_reschedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_reschedule (
    id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    try_number integer NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    duration integer NOT NULL,
    reschedule_date timestamp with time zone NOT NULL
);


--
-- Name: task_reschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_reschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_reschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_reschedule_id_seq OWNED BY public.task_reschedule.id;


--
-- Name: trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trigger (
    id integer NOT NULL,
    classpath character varying(1000) NOT NULL,
    kwargs text NOT NULL,
    created_date timestamp with time zone NOT NULL,
    triggerer_id integer
);


--
-- Name: trigger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trigger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trigger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trigger_id_seq OWNED BY public.trigger.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


--
-- Name: variable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variable (
    id integer NOT NULL,
    key character varying(250),
    val text,
    description text,
    is_encrypted boolean
);


--
-- Name: variable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.variable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.variable_id_seq OWNED BY public.variable.id;


--
-- Name: xcom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.xcom (
    dag_run_id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    key character varying(512) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    value bytea,
    "timestamp" timestamp with time zone NOT NULL
);


--
-- Name: customer_order_summary; Type: VIEW; Schema: reports; Owner: -
--

CREATE VIEW reports.customer_order_summary AS
 SELECT c.email,
    count(o.order_id) AS order_count,
    sum(o.total_amount) AS total_spend,
    max(o.date_key) AS last_order_date
   FROM (dw.dim_customer c
     LEFT JOIN dw.fact_orders o ON ((o.customer_key = c.customer_key)))
  GROUP BY c.email
  ORDER BY (sum(o.total_amount)) DESC NULLS LAST;


--
-- Name: audit_logs; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.audit_logs (
    id bigint NOT NULL,
    actor_email character varying(255),
    action character varying(120),
    resource_type character varying(120),
    resource_id character varying(120),
    details text,
    created_at timestamp with time zone
);


--
-- Name: security_audit_report; Type: VIEW; Schema: reports; Owner: -
--

CREATE VIEW reports.security_audit_report AS
 SELECT actor_email,
    action,
    resource_type,
    count(*) AS event_count,
    max(created_at) AS last_seen_at
   FROM staging.audit_logs
  GROUP BY actor_email, action, resource_type
  ORDER BY (max(created_at)) DESC;


--
-- Name: order_items; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.order_items (
    id bigint NOT NULL,
    order_id bigint,
    product_id bigint,
    product_name character varying(255),
    product_slug character varying(255),
    unit_price numeric(12,2),
    quantity integer,
    line_total numeric(12,2)
);


--
-- Name: orders; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.orders (
    id bigint NOT NULL,
    order_number character varying(255),
    user_email character varying(255),
    status character varying(40),
    subtotal numeric(12,2),
    shipping_cost numeric(12,2),
    tax numeric(12,2),
    total_amount numeric(12,2),
    payment_method character varying(255),
    payment_reference character varying(255),
    created_at timestamp without time zone
);


--
-- Name: products; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.products (
    id bigint NOT NULL,
    category_id bigint,
    name character varying(160),
    slug character varying(180),
    price numeric(12,2),
    stock_quantity integer,
    status character varying(20),
    updated_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: dim_customer customer_key; Type: DEFAULT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.dim_customer ALTER COLUMN customer_key SET DEFAULT nextval('dw.dim_customer_customer_key_seq'::regclass);


--
-- Name: dim_product product_key; Type: DEFAULT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.dim_product ALTER COLUMN product_key SET DEFAULT nextval('dw.dim_product_product_key_seq'::regclass);


--
-- Name: ab_permission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_id_seq'::regclass);


--
-- Name: ab_permission_view id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_view_id_seq'::regclass);


--
-- Name: ab_permission_view_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view_role ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_view_role_id_seq'::regclass);


--
-- Name: ab_register_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_register_user ALTER COLUMN id SET DEFAULT nextval('public.ab_register_user_id_seq'::regclass);


--
-- Name: ab_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_role ALTER COLUMN id SET DEFAULT nextval('public.ab_role_id_seq'::regclass);


--
-- Name: ab_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user ALTER COLUMN id SET DEFAULT nextval('public.ab_user_id_seq'::regclass);


--
-- Name: ab_user_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user_role ALTER COLUMN id SET DEFAULT nextval('public.ab_user_role_id_seq'::regclass);


--
-- Name: ab_view_menu id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_view_menu ALTER COLUMN id SET DEFAULT nextval('public.ab_view_menu_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: callback_request id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.callback_request ALTER COLUMN id SET DEFAULT nextval('public.callback_request_id_seq'::regclass);


--
-- Name: connection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connection ALTER COLUMN id SET DEFAULT nextval('public.connection_id_seq'::regclass);


--
-- Name: dag_pickle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_pickle ALTER COLUMN id SET DEFAULT nextval('public.dag_pickle_id_seq'::regclass);


--
-- Name: dag_run id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run ALTER COLUMN id SET DEFAULT nextval('public.dag_run_id_seq'::regclass);


--
-- Name: dataset id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset ALTER COLUMN id SET DEFAULT nextval('public.dataset_id_seq'::regclass);


--
-- Name: dataset_alias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias ALTER COLUMN id SET DEFAULT nextval('public.dataset_alias_id_seq'::regclass);


--
-- Name: dataset_event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_event ALTER COLUMN id SET DEFAULT nextval('public.dataset_event_id_seq'::regclass);


--
-- Name: import_error id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_error ALTER COLUMN id SET DEFAULT nextval('public.import_error_id_seq'::regclass);


--
-- Name: job id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job ALTER COLUMN id SET DEFAULT nextval('public.job_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- Name: log_template id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_template ALTER COLUMN id SET DEFAULT nextval('public.log_template_id_seq'::regclass);


--
-- Name: login_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_attempts ALTER COLUMN id SET DEFAULT nextval('public.login_attempts_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: session id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session ALTER COLUMN id SET DEFAULT nextval('public.session_id_seq'::regclass);


--
-- Name: slot_pool id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slot_pool ALTER COLUMN id SET DEFAULT nextval('public.slot_pool_id_seq'::regclass);


--
-- Name: task_fail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_fail ALTER COLUMN id SET DEFAULT nextval('public.task_fail_id_seq'::regclass);


--
-- Name: task_instance_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance_history ALTER COLUMN id SET DEFAULT nextval('public.task_instance_history_id_seq'::regclass);


--
-- Name: task_reschedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_reschedule ALTER COLUMN id SET DEFAULT nextval('public.task_reschedule_id_seq'::regclass);


--
-- Name: trigger id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trigger ALTER COLUMN id SET DEFAULT nextval('public.trigger_id_seq'::regclass);


--
-- Name: variable id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variable ALTER COLUMN id SET DEFAULT nextval('public.variable_id_seq'::regclass);


--
-- Data for Name: dim_customer; Type: TABLE DATA; Schema: dw; Owner: -
--

COPY dw.dim_customer (customer_key, email) FROM stdin;
1	admin@example.com
2	admin@ecommerce.local
3	employee@example.com
\.


--
-- Data for Name: dim_date; Type: TABLE DATA; Schema: dw; Owner: -
--

COPY dw.dim_date (date_key, year, month, day) FROM stdin;
2026-05-05	2026	5	5
2026-05-04	2026	5	4
\.


--
-- Data for Name: dim_product; Type: TABLE DATA; Schema: dw; Owner: -
--

COPY dw.dim_product (product_key, product_id, name, slug, category_id, current_price, status) FROM stdin;
1	1	Samsung Galaxy A55	samsung-galaxy-a55	1	12999.99	ACTIVE
2	4	Nike Air Force 1 Beyaz	nike-air-force-1-beyaz	2	3299.00	ACTIVE
3	5	Philips Hue Starter Kit	philips-hue-starter-kit	3	1899.00	ACTIVE
4	6	Bambu Kesme Tahtası Seti	bambu-kesme-tahtasi-seti	3	349.90	ACTIVE
5	7	Garmin Forerunner 265	garmin-forerunner-265	4	9999.00	ACTIVE
6	8	Decathlon Yüzme Gözlüğü	decathlon-yuzme-gozlugu	4	129.90	ACTIVE
7	9	Atomic Habits - James Clear	atomic-habits-james-clear	5	189.00	ACTIVE
8	10	Rhodia A5 Defter	rhodia-a5-defter	5	229.00	ACTIVE
9	11	CeraVe Nemlendirici Krem	cerave-nemlendirici-krem	6	389.90	ACTIVE
10	12	The Ordinary Niacinamide 10%	the-ordinary-niacinamide	6	269.00	ACTIVE
11	13	LEGO Technic Bugatti Chiron	lego-technic-bugatti-chiron	7	4299.00	ACTIVE
12	14	Mega Bloks İlk İnşaatçım	mega-bloks-ilk-insaatcim	7	259.90	ACTIVE
13	15	Organik Zeytinyağı 750ml	organik-zeytinyagi-750ml	8	449.00	ACTIVE
14	16	Premium Karışık Kuruyemiş	premium-karisik-kuruyemis	8	299.90	ACTIVE
15	17	Fiskars Bahçe Makası	fiskars-bahce-makasi	9	599.00	ACTIVE
16	18	Akıllı Damla Sulama Seti	akilli-damla-sulama-seti	9	1299.00	ACTIVE
17	19	Bosch S5 Akü 60Ah	bosch-s5-aku-60ah	10	2199.00	ACTIVE
18	20	Michelin Pilot Sport 5 225/45R17	michelin-pilot-sport-5	10	3499.00	ACTIVE
19	27	USB-C Productivity Dock	usb-c-productivity-dock	24	3499.90	ACTIVE
20	28	Developer Laptop Pro 14	developer-laptop-pro-14	24	64999.90	ACTIVE
21	29	Everyday Tech Hoodie	everyday-tech-hoodie	25	1499.90	ACTIVE
22	30	Ergonomic Desk Lamp	ergonomic-desk-lamp	26	899.90	ACTIVE
23	31	Smart Training Bottle	smart-training-bottle	27	699.90	ACTIVE
24	2	Logitech MX Keys Mini	logitech-mx-keys-mini	1	2299.90	ACTIVE
25	3	Levi's 501 Original Jeans	levis-501-original-jeans	2	1499.00	ACTIVE
\.


--
-- Data for Name: fact_inventory; Type: TABLE DATA; Schema: dw; Owner: -
--

COPY dw.fact_inventory (product_id, product_key, stock_quantity, snapshot_date) FROM stdin;
1	1	50	2026-05-05
4	2	45	2026-05-05
5	3	20	2026-05-05
6	4	60	2026-05-05
7	5	15	2026-05-05
8	6	100	2026-05-05
9	7	200	2026-05-05
10	8	75	2026-05-05
11	9	90	2026-05-05
12	10	120	2026-05-05
13	11	10	2026-05-05
14	12	55	2026-05-05
15	13	40	2026-05-05
16	14	65	2026-05-05
17	15	35	2026-05-05
18	16	25	2026-05-05
19	17	20	2026-05-05
20	18	30	2026-05-05
27	19	35	2026-05-05
28	20	12	2026-05-05
29	21	48	2026-05-05
30	22	64	2026-05-05
31	23	80	2026-05-05
2	24	26	2026-05-05
3	25	79	2026-05-05
\.


--
-- Data for Name: fact_orders; Type: TABLE DATA; Schema: dw; Owner: -
--

COPY dw.fact_orders (order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count) FROM stdin;
1	ORD-20260504212512-1777929912355	2	2026-05-04	PAID	2299.90	0.00	413.98	2713.88	1
2	ORD-20260505173454-1778002494024	3	2026-05-05	PAID	2299.90	0.00	413.98	2713.88	1
4	ORD-20260505175519-1778003719399	1	2026-05-05	PAID	1499.00	0.00	269.82	1768.82	1
3	ORD-20260505173852-1778002732252	1	2026-05-05	PAID	4599.80	0.00	827.96	5427.76	2
\.


--
-- Data for Name: fact_payments; Type: TABLE DATA; Schema: dw; Owner: -
--

COPY dw.fact_payments (payment_reference, order_id, date_key, payment_method, status, amount) FROM stdin;
PAY-SIM-0000-1777929912356	1	2026-05-04	CARD	PAID	2713.88
PAY-SIM-3652-1778002494025	2	2026-05-05	CARD	PAID	2713.88
PAY-SIM-2589-1778002732252	3	2026-05-05	CARD	PAID	5427.76
PAY-SIM-2365-1778003719399	4	2026-05-05	CARD	PAID	1768.82
\.


--
-- Data for Name: ab_permission; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_permission (id, name) FROM stdin;
1	can_edit
2	can_read
3	can_create
4	can_delete
5	menu_access
\.


--
-- Data for Name: ab_permission_view; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_permission_view (id, permission_id, view_menu_id) FROM stdin;
1	1	4
2	2	4
3	1	5
4	2	5
5	1	6
6	2	6
7	3	8
8	2	8
9	1	8
10	4	8
11	5	9
12	5	10
13	3	11
14	2	11
15	1	11
16	4	11
17	5	12
18	2	13
19	5	14
20	2	15
21	5	16
22	2	17
23	5	18
24	2	19
25	5	20
26	3	23
27	2	23
28	1	23
29	4	23
30	5	23
31	5	24
32	2	25
33	5	25
34	2	26
35	5	26
36	3	27
37	2	27
38	1	27
39	4	27
40	5	27
41	5	28
42	3	29
43	2	29
44	1	29
45	4	29
46	5	29
47	2	30
48	5	30
49	2	31
50	5	31
51	2	32
52	5	32
53	3	33
54	2	33
55	1	33
56	4	33
57	5	33
58	2	34
59	5	34
60	4	34
61	1	34
62	2	35
63	5	35
64	2	36
65	5	36
66	3	37
67	2	37
68	1	37
69	4	37
70	5	37
71	2	38
72	4	38
73	5	38
74	5	40
75	5	44
76	5	45
77	5	46
78	5	47
79	5	48
80	2	49
81	4	49
82	1	49
83	2	50
84	3	50
85	4	50
86	5	50
87	2	51
88	4	51
89	1	51
90	2	52
91	3	52
92	4	52
93	5	52
94	2	53
95	4	53
96	1	53
97	2	54
98	3	54
99	4	54
100	5	54
101	2	55
102	4	55
103	1	55
104	2	56
105	3	56
106	4	56
107	5	56
108	2	57
109	4	57
110	1	57
111	2	58
112	3	58
113	4	58
114	5	58
115	1	44
116	4	44
117	2	44
118	2	40
119	2	59
120	2	46
121	2	45
122	2	60
123	2	61
124	2	62
125	2	63
126	3	46
127	4	46
\.


--
-- Data for Name: ab_permission_view_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_permission_view_role (id, permission_view_id, role_id) FROM stdin;
1	1	1
2	2	1
3	3	1
4	4	1
5	5	1
6	6	1
7	7	1
8	8	1
9	9	1
10	10	1
11	11	1
12	12	1
13	13	1
14	14	1
15	15	1
16	16	1
17	17	1
18	18	1
19	19	1
20	20	1
21	21	1
22	22	1
23	23	1
24	24	1
25	25	1
26	26	1
27	27	1
28	28	1
29	29	1
30	30	1
31	31	1
32	32	1
33	33	1
34	34	1
35	35	1
36	36	1
37	37	1
38	38	1
39	39	1
40	40	1
41	41	1
42	42	1
43	43	1
44	44	1
45	45	1
46	46	1
47	47	1
48	48	1
49	49	1
50	50	1
51	51	1
52	52	1
53	53	1
54	54	1
55	55	1
56	56	1
57	57	1
58	58	1
59	59	1
60	60	1
61	61	1
62	62	1
63	63	1
64	64	1
65	65	1
66	66	1
67	67	1
68	68	1
69	69	1
70	70	1
71	71	1
72	72	1
73	73	1
74	74	1
75	75	1
76	76	1
77	77	1
78	78	1
79	79	1
80	117	3
81	118	3
82	119	3
83	27	3
84	120	3
85	121	3
86	67	3
87	122	3
88	123	3
89	32	3
90	4	3
91	3	3
92	6	3
93	5	3
94	58	3
95	43	3
96	124	3
97	71	3
98	125	3
99	31	3
100	75	3
101	74	3
102	30	3
103	77	3
104	76	3
105	78	3
106	79	3
107	33	3
108	59	3
109	46	3
110	117	4
111	118	4
112	119	4
113	27	4
114	120	4
115	121	4
116	67	4
117	122	4
118	123	4
119	32	4
120	4	4
121	3	4
122	6	4
123	5	4
124	58	4
125	43	4
126	124	4
127	71	4
128	125	4
129	31	4
130	75	4
131	74	4
132	30	4
133	77	4
134	76	4
135	78	4
136	79	4
137	33	4
138	59	4
139	46	4
140	115	4
141	116	4
142	42	4
143	44	4
144	45	4
145	26	4
146	28	4
147	29	4
148	126	4
149	117	5
150	118	5
151	119	5
152	27	5
153	120	5
154	121	5
155	67	5
156	122	5
157	123	5
158	32	5
159	4	5
160	3	5
161	6	5
162	5	5
163	58	5
164	43	5
165	124	5
166	71	5
167	125	5
168	31	5
169	75	5
170	74	5
171	30	5
172	77	5
173	76	5
174	78	5
175	79	5
176	33	5
177	59	5
178	46	5
179	115	5
180	116	5
181	42	5
182	44	5
183	45	5
184	26	5
185	28	5
186	29	5
187	126	5
188	51	5
189	41	5
190	52	5
191	57	5
192	70	5
193	63	5
194	40	5
195	65	5
196	73	5
197	53	5
198	54	5
199	55	5
200	56	5
201	66	5
202	68	5
203	69	5
204	62	5
205	64	5
206	36	5
207	37	5
208	38	5
209	39	5
210	72	5
211	127	5
212	117	1
213	118	1
214	119	1
215	120	1
216	121	1
217	122	1
218	123	1
219	124	1
220	125	1
221	115	1
222	116	1
223	126	1
224	127	1
\.


--
-- Data for Name: ab_register_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_register_user (id, first_name, last_name, username, password, email, registration_date, registration_hash) FROM stdin;
\.


--
-- Data for Name: ab_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_role (id, name) FROM stdin;
1	Admin
2	Public
3	Viewer
4	User
5	Op
\.


--
-- Data for Name: ab_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk) FROM stdin;
1	Data	Admin	admin	pbkdf2:sha256:260000$sXQRz0eZn15aK8Sn$ba630b007857478f1ee67e0139b80c19f89684ecd94d216db3baea7ad1c9d9c9	t	admin@example.com	2026-05-05 19:24:42.401036	1	0	2026-05-05 19:13:15.029815	2026-05-05 19:13:15.029821	\N	\N
\.


--
-- Data for Name: ab_user_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_user_role (id, user_id, role_id) FROM stdin;
1	1	1
\.


--
-- Data for Name: ab_view_menu; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_view_menu (id, name) FROM stdin;
1	IndexView
2	UtilView
3	LocaleView
4	Passwords
5	My Password
6	My Profile
7	AuthDBView
8	Users
9	List Users
10	Security
11	Roles
12	List Roles
13	User Stats Chart
14	User's Statistics
15	Permissions
16	Actions
17	View Menus
18	Resources
19	Permission Views
20	Permission Pairs
21	AutocompleteView
22	Airflow
23	DAG Runs
24	Browse
25	Jobs
26	Audit Logs
27	Variables
28	Admin
29	Task Instances
30	Task Reschedules
31	Triggers
32	Configurations
33	Connections
34	SLA Misses
35	Plugins
36	Providers
37	Pools
38	XComs
39	DagDependenciesView
40	DAG Dependencies
41	RedocView
42	DevView
43	DocsView
44	DAGs
45	Cluster Activity
46	Datasets
47	Documentation
48	Docs
49	DAG:daily_sales_report
50	DAG Run:daily_sales_report
51	DAG:failed_payment_report
52	DAG Run:failed_payment_report
53	DAG:product_performance_report
54	DAG Run:product_performance_report
55	DAG:customer_order_summary
56	DAG Run:customer_order_summary
57	DAG:security_audit_report
58	DAG Run:security_audit_report
59	DAG Code
60	ImportError
61	DAG Warnings
62	Task Logs
63	Website
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
5f2621c13b39
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_user (id, created_at, email, enabled, full_name, password_hash, permissions, role, failed_login_attempts, locked_until) FROM stdin;
1	2026-05-04 20:50:38.742906+00	admin@example.com	t	Admin User	$2a$10$xYE56po1u58jfaOvP7ddzeIFs2woCPEFualWcqyRpGh5EVpqUlj/m	ADMIN_PANEL_ACCESS,PRODUCT_READ,PRODUCT_CREATE,PRODUCT_UPDATE,PRODUCT_DELETE,PRODUCT_IMAGE_UPLOAD,PRODUCT_IMAGE_DELETE,PRODUCT_IMAGE_SET_PRIMARY,CATEGORY_READ,CATEGORY_CREATE,CATEGORY_UPDATE,CATEGORY_DELETE,ORDER_READ_OWN,ORDER_READ_ALL,USER_MANAGE,ROLE_MANAGE,AUDIT_READ	ADMIN	0	\N
2	2026-05-04 20:50:38.885724+00	employee@example.com	t	Employee User	$2a$10$My8x.U6iWmY.pNqCWoOHVeLyuvCNNv5JmAYh9.zsO.fdV9bvENNEm	ADMIN_PANEL_ACCESS,PRODUCT_READ,PRODUCT_CREATE,PRODUCT_UPDATE,PRODUCT_IMAGE_UPLOAD,PRODUCT_IMAGE_SET_PRIMARY,CATEGORY_READ,ORDER_READ_OWN	EMPLOYEE	0	\N
3	2026-05-04 20:50:38.953757+00	customer@example.com	t	Customer User	$2a$10$1aFMI5R613HPzBM0tyetKOJF317Cz4tEIV843DwYaiGgck9UM1SxS	PRODUCT_READ,ORDER_READ_OWN	CUSTOMER	0	\N
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, actor_user_id, actor_email, action, resource_type, resource_id, ip_address, user_agent, details, created_at) FROM stdin;
1	\N	\N	LOGIN_FAILED	auth	admin@ecommerce.local	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	email=a***@ecommerce.local; success=false; failureCode=INVALID_CREDENTIALS; correlationId=c0c0e03c-4478-422d-ae02-04fcc16bb69f	2026-05-05 17:33:23.596604+00
2	\N	\N	LOGIN_SUCCESS	auth	employee@example.com	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	email=e***@example.com; success=true; failureCode=; correlationId=57bc54d6-4a7c-4c50-985f-50ec25f1a4ff	2026-05-05 17:33:30.667166+00
3	\N	employee@example.com	PERMISSION_DENIED	http	/api/admin/products	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	method=GET; correlationId=180c3feb-0376-4275-bbc4-57df9d8b447f	2026-05-05 17:33:30.791421+00
4	\N	employee@example.com	PERMISSION_DENIED	http	/api/admin/categories	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	method=GET; correlationId=25aaacee-d580-43f5-abb2-2d6735e801b1	2026-05-05 17:33:30.792134+00
5	\N	employee@example.com	ORDER_CREATED	order	2	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	orderNumber=ORD-20260505173454-1778002494024; totalAmount=2713.8820; correlationId=5d63fec1-390f-4056-8639-0e8f2432ddc8	2026-05-05 17:34:54.022197+00
6	\N	\N	LOGIN_SUCCESS	auth	employee@example.com	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	email=e***@example.com; success=true; failureCode=; correlationId=28d147a7-78f9-45a2-b007-f2a12f553d0c	2026-05-05 17:36:08.233583+00
7	\N	employee@example.com	PERMISSION_DENIED	http	/api/admin/products	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	method=GET; correlationId=e8dd59f2-3e7e-4b60-aa35-9468f0cde27b	2026-05-05 17:36:08.282237+00
8	\N	employee@example.com	PERMISSION_DENIED	http	/api/admin/categories	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	method=GET; correlationId=759421ab-2c41-49eb-8d1b-b2eba0a9c42d	2026-05-05 17:36:08.284541+00
9	\N	\N	LOGIN_SUCCESS	auth	admin@example.com	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	email=a***@example.com; success=true; failureCode=; correlationId=de04384c-2b49-4252-a6b5-62343e1097ce	2026-05-05 17:36:23.865728+00
10	\N	admin@example.com	ORDER_CREATED	order	3	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	orderNumber=ORD-20260505173852-1778002732252; totalAmount=5427.7640; correlationId=f8b8ae22-7dda-4a65-9992-f4f663612ee5	2026-05-05 17:38:52.249721+00
11	\N	admin@example.com	ORDER_CREATED	order	4	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	orderNumber=ORD-20260505175519-1778003719399; totalAmount=1768.8200; correlationId=c21b7047-1a18-49bc-8ac4-e9fc07a942e3	2026-05-05 17:55:19.394437+00
12	\N	\N	LOGIN_SUCCESS	auth	admin@example.com	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	email=a***@example.com; success=true; failureCode=; correlationId=18f4bca4-d264-491f-880f-0f90584e62d1	2026-05-05 19:31:38.219567+00
13	\N	admin@example.com	ORDER_CREATED	order	5	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	orderNumber=ORD-20260505195002-1778010602220; totalAmount=2713.8820; correlationId=6a3de917-a6c7-4764-b620-aa97cb3ac883	2026-05-05 19:50:02.215696+00
\.


--
-- Data for Name: callback_request; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.callback_request (id, created_at, priority_weight, callback_data, callback_type, processor_subdir) FROM stdin;
\.


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_items (id, created_at, quantity, updated_at, user_email, product_id) FROM stdin;
2	2026-05-04 21:27:12.954299	1	\N	admin@ecommerce.local	2
3	2026-05-04 21:27:15.116837	1	\N	admin@ecommerce.local	3
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.category (id, created_at, description, name, product_count, slug, status) FROM stdin;
1	2026-05-04	Telefon, bilgisayar, tablet ve tüm elektronik ürünler	Elektronik	2	elektronik	ACTIVE
2	2026-05-04	Erkek, kadın ve çocuk giyim ürünleri	Giyim	2	giyim	ACTIVE
3	2026-05-04	Ev dekorasyon, mobilya ve yaşam aksesuarları	Ev & Yaşam	2	ev-yasam	ACTIVE
4	2026-05-04	Spor malzemeleri, outdoor ekipmanları	Spor & Outdoor	2	spor-outdoor	ACTIVE
5	2026-05-04	Kitaplar, dergiler ve kırtasiye ürünleri	Kitap & Kırtasiye	2	kitap-kirtasiye	ACTIVE
6	2026-05-04	Cilt bakımı, makyaj ve parfüm ürünleri	Kozmetik	2	kozmetik	ACTIVE
7	2026-05-04	Çocuk oyuncakları ve oyun setleri	Oyuncak	2	oyuncak	ACTIVE
8	2026-05-04	Organik gıda, atıştırmalık ve içecekler	Gıda & İçecek	2	gida-icecek	ACTIVE
9	2026-05-04	Bahçe aletleri, tohum ve bahçe dekorasyonu	Bahçe	2	bahce	ACTIVE
10	2026-05-04	Araç aksesuar, bakım ve yedek parça ürünleri	Otomotiv	2	otomotiv	ACTIVE
24	2026-05-05	Phones, laptops, and gadgets	Electronics	0	electronics	ACTIVE
25	2026-05-05	Men, women and kids apparel	Clothing	0	clothing	ACTIVE
26	2026-05-05	Furniture, decor, and garden items	Home & Garden	0	home-garden	ACTIVE
27	2026-05-05	Equipment and activewear	Sports	0	sports	ACTIVE
\.


--
-- Data for Name: connection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.connection (id, conn_id, conn_type, description, host, schema, login, password, port, is_encrypted, is_extra_encrypted, extra) FROM stdin;
1	ecommerce_postgres	postgres	\N	postgres	ecommerce	ecommerce_user	change_me_in_future	5432	f	f	\N
\.


--
-- Data for Name: customer_order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_order_items (id, line_total, product_name, product_slug, quantity, unit_price, order_id, product_id) FROM stdin;
1	2299.90	Logitech MX Keys Mini	logitech-mx-keys-mini	1	2299.90	1	2
2	2299.90	Logitech MX Keys Mini	logitech-mx-keys-mini	1	2299.90	2	2
3	4599.80	Logitech MX Keys Mini	logitech-mx-keys-mini	2	2299.90	3	2
4	1499.00	Levi's 501 Original Jeans	levis-501-original-jeans	1	1499.00	4	3
5	2299.90	Logitech MX Keys Mini	logitech-mx-keys-mini	1	2299.90	5	2
\.


--
-- Data for Name: customer_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_orders (id, created_at, order_number, payment_method, payment_reference, shipping_city, shipping_cost, shipping_country, shipping_email, shipping_full_name, shipping_phone, shipping_postal_code, shipping_street, status, subtotal, tax, total_amount, user_email) FROM stdin;
1	2026-05-04 21:25:12.355173	ORD-20260504212512-1777929912355	CARD	PAY-SIM-0000-1777929912356	Hessen	0.00	Türkiye	as@example.com	Mustafa Özdemir	017693153406	35039	Am Richtsberg 20	PAID	2299.90	413.98	2713.88	admin@ecommerce.local
2	2026-05-05 17:34:54.024767	ORD-20260505173454-1778002494024	CARD	PAY-SIM-3652-1778002494025	Hessen	0.00	Türkiye	as@example.com	Mustafa Özdemir	017693153406	35039	Am Richtsberg 20	PAID	2299.90	413.98	2713.88	employee@example.com
3	2026-05-05 17:38:52.251985	ORD-20260505173852-1778002732252	CARD	PAY-SIM-2589-1778002732252	Hessen	0.00	Türkiye	ds@example.com	Mustafa Özdemir	04917693153406	35039	Am Richtsberg 20	PAID	4599.80	827.96	5427.76	admin@example.com
4	2026-05-05 17:55:19.399629	ORD-20260505175519-1778003719399	CARD	PAY-SIM-2365-1778003719399	Hessen	0.00	Türkiye	sa@example.com	Mustafa Özdemir	04917693153406	35039	Am Richtsberg 20	PAID	1499.00	269.82	1768.82	admin@example.com
5	2026-05-05 19:50:02.220061	ORD-20260505195002-1778010602220	CARD	PAY-SIM-5698-1778010602221	Hessen	0.00	Türkiye	sa@example.com	Mustafa Özdemir	04917693153406	35039	Am Richtsberg 20	PAID	2299.90	413.98	2713.88	admin@example.com
\.


--
-- Data for Name: dag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag (dag_id, root_dag_id, is_paused, is_subdag, is_active, last_parsed_time, last_pickled, last_expired, scheduler_lock, pickle_id, fileloc, processor_subdir, owners, dag_display_name, description, default_view, schedule_interval, timetable_description, dataset_expression, max_active_tasks, max_active_runs, max_consecutive_failed_dag_runs, has_task_concurrency_limits, has_import_errors, next_dagrun, next_dagrun_data_interval_start, next_dagrun_data_interval_end, next_dagrun_create_after) FROM stdin;
customer_order_summary	\N	f	f	t	2026-05-05 20:32:10.542598+00	\N	\N	\N	\N	/opt/airflow/dags/ecommerce_warehouse_etl.py	/opt/airflow/dags	data-platform	\N	\N	grid	"@daily"	At 00:00	null	16	16	0	f	f	2026-05-05 00:00:00+00	2026-05-05 00:00:00+00	2026-05-06 00:00:00+00	2026-05-06 00:00:00+00
daily_sales_report	\N	t	f	t	2026-05-05 20:32:10.549187+00	\N	\N	\N	\N	/opt/airflow/dags/ecommerce_warehouse_etl.py	/opt/airflow/dags	data-platform	\N	\N	grid	"@daily"	At 00:00	null	16	16	0	f	f	2026-05-04 00:00:00+00	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 00:00:00+00
failed_payment_report	\N	t	f	t	2026-05-05 20:32:10.551893+00	\N	\N	\N	\N	/opt/airflow/dags/ecommerce_warehouse_etl.py	/opt/airflow/dags	data-platform	\N	\N	grid	"@daily"	At 00:00	null	16	16	0	f	f	2026-05-04 00:00:00+00	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 00:00:00+00
product_performance_report	\N	t	f	t	2026-05-05 20:32:10.554347+00	\N	\N	\N	\N	/opt/airflow/dags/ecommerce_warehouse_etl.py	/opt/airflow/dags	data-platform	\N	\N	grid	"@daily"	At 00:00	null	16	16	0	f	f	2026-05-04 00:00:00+00	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 00:00:00+00
security_audit_report	\N	f	f	t	2026-05-05 20:32:10.556659+00	\N	\N	\N	\N	/opt/airflow/dags/ecommerce_warehouse_etl.py	/opt/airflow/dags	data-platform	\N	\N	grid	"@daily"	At 00:00	null	16	16	0	f	f	2026-05-05 00:00:00+00	2026-05-05 00:00:00+00	2026-05-06 00:00:00+00	2026-05-06 00:00:00+00
\.


--
-- Data for Name: dag_code; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_code (fileloc_hash, fileloc, last_updated, source_code) FROM stdin;
39676071369142587	/opt/airflow/dags/ecommerce_warehouse_etl.py	2026-05-05 19:13:52.569556+00	from __future__ import annotations\n\nfrom datetime import datetime\nfrom pathlib import Path\n\nfrom airflow import DAG\nfrom airflow.providers.postgres.operators.postgres import PostgresOperator\n\nDAG_DIR = Path(__file__).resolve().parent\nSQL_DIR = DAG_DIR / "sql"\n\n\ndef sql_file(name: str) -> str:\n    return (SQL_DIR / name).read_text(encoding="utf-8")\n\n\ndefault_args = {\n    "owner": "data-platform",\n    "retries": 1,\n}\n\n\nwith DAG(\n    dag_id="daily_sales_report",\n    default_args=default_args,\n    start_date=datetime(2026, 5, 1),\n    schedule="@daily",\n    catchup=False,\n    tags=["ecommerce", "etl", "warehouse"],\n) as daily_sales_report:\n    create_schema = PostgresOperator(\n        task_id="create_warehouse_schema",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("warehouse_schema.sql"),\n    )\n\n    refresh_warehouse = PostgresOperator(\n        task_id="refresh_warehouse",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("refresh_warehouse.sql"),\n    )\n\n    build_report = PostgresOperator(\n        task_id="build_daily_sales_report",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("daily_sales_report.sql"),\n    )\n\n    create_schema >> refresh_warehouse >> build_report\n\n\nwith DAG(\n    dag_id="product_performance_report",\n    default_args=default_args,\n    start_date=datetime(2026, 5, 1),\n    schedule="@daily",\n    catchup=False,\n    tags=["ecommerce", "etl", "warehouse"],\n) as product_performance_report:\n    create_schema = PostgresOperator(\n        task_id="create_warehouse_schema",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("warehouse_schema.sql"),\n    )\n\n    refresh_warehouse = PostgresOperator(\n        task_id="refresh_warehouse",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("refresh_warehouse.sql"),\n    )\n\n    build_report = PostgresOperator(\n        task_id="build_product_performance_report",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("product_performance_report.sql"),\n    )\n\n    create_schema >> refresh_warehouse >> build_report\n\n\nwith DAG(\n    dag_id="failed_payment_report",\n    default_args=default_args,\n    start_date=datetime(2026, 5, 1),\n    schedule="@daily",\n    catchup=False,\n    tags=["ecommerce", "etl", "warehouse"],\n) as failed_payment_report:\n    create_schema = PostgresOperator(\n        task_id="create_warehouse_schema",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("warehouse_schema.sql"),\n    )\n\n    refresh_warehouse = PostgresOperator(\n        task_id="refresh_warehouse",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("refresh_warehouse.sql"),\n    )\n\n    build_report = PostgresOperator(\n        task_id="build_failed_payment_report",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("failed_payment_report.sql"),\n    )\n\n    create_schema >> refresh_warehouse >> build_report\n\n\nwith DAG(\n    dag_id="customer_order_summary",\n    default_args=default_args,\n    start_date=datetime(2026, 5, 1),\n    schedule="@daily",\n    catchup=False,\n    tags=["ecommerce", "etl", "warehouse"],\n) as customer_order_summary:\n    create_schema = PostgresOperator(\n        task_id="create_warehouse_schema",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("warehouse_schema.sql"),\n    )\n\n    refresh_warehouse = PostgresOperator(\n        task_id="refresh_warehouse",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("refresh_warehouse.sql"),\n    )\n\n    build_report = PostgresOperator(\n        task_id="build_customer_order_summary",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("customer_order_summary.sql"),\n    )\n\n    create_schema >> refresh_warehouse >> build_report\n\n\nwith DAG(\n    dag_id="security_audit_report",\n    default_args=default_args,\n    start_date=datetime(2026, 5, 1),\n    schedule="@daily",\n    catchup=False,\n    tags=["ecommerce", "etl", "warehouse"],\n) as security_audit_report:\n    create_schema = PostgresOperator(\n        task_id="create_warehouse_schema",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("warehouse_schema.sql"),\n    )\n\n    refresh_warehouse = PostgresOperator(\n        task_id="refresh_warehouse",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("refresh_warehouse.sql"),\n    )\n\n    build_report = PostgresOperator(\n        task_id="build_security_audit_report",\n        postgres_conn_id="ecommerce_postgres",\n        sql=sql_file("security_audit_report.sql"),\n    )\n\n    create_schema >> refresh_warehouse >> build_report\n
\.


--
-- Data for Name: dag_owner_attributes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_owner_attributes (dag_id, owner, link) FROM stdin;
\.


--
-- Data for Name: dag_pickle; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_pickle (id, pickle, created_dttm, pickle_hash) FROM stdin;
\.


--
-- Data for Name: dag_priority_parsing_request; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_priority_parsing_request (id, fileloc) FROM stdin;
\.


--
-- Data for Name: dag_run; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_run (id, dag_id, queued_at, execution_date, start_date, end_date, state, run_id, creating_job_id, external_trigger, run_type, conf, data_interval_start, data_interval_end, last_scheduling_decision, dag_hash, log_template_id, updated_at, clear_number) FROM stdin;
4	security_audit_report	2026-05-05 19:36:07.614707+00	2026-05-05 19:36:07.591062+00	2026-05-05 19:36:07.828298+00	2026-05-05 19:41:15.126206+00	success	manual__2026-05-05T19:36:07.591062+00:00	\N	t	manual	\\x80057d942e	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 19:41:15.122221+00	75f73342b00e312ee46f0cfd60139a2c	2	2026-05-05 19:41:15.127499+00	0
2	customer_order_summary	2026-05-05 19:25:06.112798+00	2026-05-04 00:00:00+00	2026-05-05 19:25:06.137239+00	2026-05-05 19:30:13.745376+00	success	scheduled__2026-05-04T00:00:00+00:00	1	f	scheduled	\\x80057d942e	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 19:30:13.74321+00	0edebe45936a29efa69f0754033dec3b	2	2026-05-05 19:30:13.746169+00	0
1	customer_order_summary	2026-05-05 19:25:05.614355+00	2026-05-05 19:25:05.574225+00	2026-05-05 19:25:06.137758+00	2026-05-05 19:25:11.183235+00	success	manual__2026-05-05T19:25:05.574225+00:00	\N	t	manual	\\x80057d942e	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 19:25:11.180998+00	0edebe45936a29efa69f0754033dec3b	2	2026-05-05 19:25:11.184344+00	0
5	security_audit_report	2026-05-05 19:36:07.810546+00	2026-05-04 00:00:00+00	2026-05-05 19:36:07.828075+00	2026-05-05 19:36:12.888235+00	success	scheduled__2026-05-04T00:00:00+00:00	1	f	scheduled	\\x80057d942e	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 19:36:12.885217+00	75f73342b00e312ee46f0cfd60139a2c	2	2026-05-05 19:36:12.889687+00	0
3	customer_order_summary	2026-05-05 19:27:36.561938+00	2026-05-05 19:27:36.525312+00	2026-05-05 19:27:36.682101+00	2026-05-05 19:27:42.935537+00	success	manual__2026-05-05T19:27:36.525312+00:00	\N	t	manual	\\x80057d942e	2026-05-04 00:00:00+00	2026-05-05 00:00:00+00	2026-05-05 19:27:42.93315+00	0edebe45936a29efa69f0754033dec3b	2	2026-05-05 19:27:42.936419+00	0
\.


--
-- Data for Name: dag_run_note; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_run_note (user_id, dag_run_id, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dag_schedule_dataset_alias_reference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_schedule_dataset_alias_reference (alias_id, dag_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dag_schedule_dataset_reference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_schedule_dataset_reference (dataset_id, dag_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dag_tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_tag (name, dag_id) FROM stdin;
ecommerce	customer_order_summary
warehouse	customer_order_summary
etl	customer_order_summary
ecommerce	daily_sales_report
warehouse	daily_sales_report
etl	daily_sales_report
ecommerce	failed_payment_report
warehouse	failed_payment_report
etl	failed_payment_report
ecommerce	product_performance_report
warehouse	product_performance_report
etl	product_performance_report
ecommerce	security_audit_report
warehouse	security_audit_report
etl	security_audit_report
\.


--
-- Data for Name: dag_warning; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dag_warning (dag_id, warning_type, message, "timestamp") FROM stdin;
\.


--
-- Data for Name: dagrun_dataset_event; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dagrun_dataset_event (dag_run_id, event_id) FROM stdin;
\.


--
-- Data for Name: dataset; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dataset (id, uri, extra, created_at, updated_at, is_orphaned) FROM stdin;
\.


--
-- Data for Name: dataset_alias; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dataset_alias (id, name) FROM stdin;
\.


--
-- Data for Name: dataset_alias_dataset; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dataset_alias_dataset (alias_id, dataset_id) FROM stdin;
\.


--
-- Data for Name: dataset_alias_dataset_event; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dataset_alias_dataset_event (alias_id, event_id) FROM stdin;
\.


--
-- Data for Name: dataset_dag_run_queue; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dataset_dag_run_queue (dataset_id, target_dag_id, created_at) FROM stdin;
\.


--
-- Data for Name: dataset_event; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dataset_event (id, dataset_id, extra, source_task_id, source_dag_id, source_run_id, source_map_index, "timestamp") FROM stdin;
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	<< Flyway Baseline >>	BASELINE	<< Flyway Baseline >>	\N	ecommerce_user	2026-05-05 16:52:15.982586	0	t
2	002	create catalog schema	SQL	V002__create_catalog_schema.sql	-1355882314	ecommerce_user	2026-05-05 16:52:16.088951	27	t
3	003	seed categories	SQL	V003__seed_categories.sql	787100040	ecommerce_user	2026-05-05 16:54:59.559398	17	t
4	004	add user profile columns	SQL	V004__add_user_profile_columns.sql	-1645444674	ecommerce_user	2026-05-05 16:54:59.618509	7	t
5	005	create auth relations	SQL	V005__create_auth_relations.sql	-2101598349	ecommerce_user	2026-05-05 16:54:59.643638	45	t
6	006	create sales schema	SQL	V006__create_sales_schema.sql	-777308632	ecommerce_user	2026-05-05 16:54:59.723385	25	t
7	007	create security schema	SQL	V007__create_security_schema.sql	-1017724568	ecommerce_user	2026-05-05 16:54:59.767918	20	t
8	008	seed demo products	SQL	V008__seed_demo_products.sql	-972120089	ecommerce_user	2026-05-05 16:56:15.230517	19	t
9	009	add audit read permission	SQL	V009__add_audit_read_permission.sql	647255258	ecommerce_user	2026-05-05 16:56:15.297631	5	t
10	010	add lockout columns	SQL	V010__add_lockout_columns.sql	528804814	ecommerce_user	2026-05-05 16:56:15.321003	7	t
\.


--
-- Data for Name: import_error; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.import_error (id, "timestamp", filename, stacktrace, processor_subdir) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.job (id, dag_id, state, job_type, start_date, end_date, latest_heartbeat, executor_class, hostname, unixname) FROM stdin;
6	customer_order_summary	success	LocalTaskJob	2026-05-05 19:27:37.693038+00	2026-05-05 19:27:39.112131+00	2026-05-05 19:27:37.643438+00	\N	487402b4e129	airflow
7	customer_order_summary	success	LocalTaskJob	2026-05-05 19:27:39.548881+00	2026-05-05 19:27:41.051622+00	2026-05-05 19:27:39.492688+00	\N	487402b4e129	airflow
8	customer_order_summary	success	LocalTaskJob	2026-05-05 19:27:41.66631+00	2026-05-05 19:27:42.742797+00	2026-05-05 19:27:41.622167+00	\N	487402b4e129	airflow
1	\N	running	SchedulerJob	2026-05-05 19:13:49.056219+00	\N	2026-05-05 20:32:10.077887+00	\N	487402b4e129	airflow
2	customer_order_summary	success	LocalTaskJob	2026-05-05 19:25:06.644701+00	2026-05-05 19:25:07.691624+00	2026-05-05 19:25:06.615404+00	\N	487402b4e129	airflow
3	customer_order_summary	success	LocalTaskJob	2026-05-05 19:25:06.65857+00	2026-05-05 19:25:07.720082+00	2026-05-05 19:25:06.624147+00	\N	487402b4e129	airflow
4	customer_order_summary	success	LocalTaskJob	2026-05-05 19:25:08.624788+00	2026-05-05 19:25:09.501085+00	2026-05-05 19:25:08.595543+00	\N	487402b4e129	airflow
5	customer_order_summary	success	LocalTaskJob	2026-05-05 19:25:09.786843+00	2026-05-05 19:25:10.646246+00	2026-05-05 19:25:09.751419+00	\N	487402b4e129	airflow
9	customer_order_summary	success	LocalTaskJob	2026-05-05 19:30:08.671822+00	2026-05-05 19:30:09.568306+00	2026-05-05 19:30:08.639485+00	\N	487402b4e129	airflow
10	customer_order_summary	success	LocalTaskJob	2026-05-05 19:30:10.065614+00	2026-05-05 19:30:10.993772+00	2026-05-05 19:30:10.021676+00	\N	487402b4e129	airflow
11	customer_order_summary	success	LocalTaskJob	2026-05-05 19:30:12.288083+00	2026-05-05 19:30:13.226408+00	2026-05-05 19:30:12.258713+00	\N	487402b4e129	airflow
18	security_audit_report	success	LocalTaskJob	2026-05-05 19:41:13.845248+00	2026-05-05 19:41:15.151516+00	2026-05-05 19:41:13.797308+00	\N	487402b4e129	airflow
12	security_audit_report	success	LocalTaskJob	2026-05-05 19:36:08.282226+00	2026-05-05 19:36:09.210225+00	2026-05-05 19:36:08.252309+00	\N	487402b4e129	airflow
13	security_audit_report	success	LocalTaskJob	2026-05-05 19:36:08.2822+00	2026-05-05 19:36:09.24198+00	2026-05-05 19:36:08.250665+00	\N	487402b4e129	airflow
14	security_audit_report	success	LocalTaskJob	2026-05-05 19:36:09.56417+00	2026-05-05 19:36:10.548164+00	2026-05-05 19:36:09.534723+00	\N	487402b4e129	airflow
15	security_audit_report	success	LocalTaskJob	2026-05-05 19:36:09.56516+00	2026-05-05 19:36:10.554121+00	2026-05-05 19:36:09.536996+00	\N	487402b4e129	airflow
16	security_audit_report	success	LocalTaskJob	2026-05-05 19:36:11.782621+00	2026-05-05 19:36:12.820027+00	2026-05-05 19:36:11.74983+00	\N	487402b4e129	airflow
17	security_audit_report	success	LocalTaskJob	2026-05-05 19:36:11.800105+00	2026-05-05 19:36:12.879362+00	2026-05-05 19:36:11.764401+00	\N	487402b4e129	airflow
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.log (id, dttm, dag_id, task_id, map_index, event, execution_date, run_id, owner, owner_display_name, extra, try_number) FROM stdin;
1	2026-05-05 19:12:43.112978+00	\N	\N	\N	cli_connections_delete	\N	\N	airflow	\N	{"host_name": "cb9412bb5c12", "full_command": "['/home/airflow/.local/bin/airflow', 'connections', 'delete', 'ecommerce_postgres']"}	\N
2	2026-05-05 19:12:47.750663+00	\N	\N	\N	cli_connections_add	\N	\N	airflow	\N	{"host_name": "cb9412bb5c12", "full_command": "['/home/airflow/.local/bin/airflow', 'connections', 'add', 'ecommerce_postgres', '--conn-type', 'postgres', '--conn-host', 'postgres', '--conn-login', 'ecommerce_user', '--conn-password', '********', '--conn-schema', 'ecommerce', '--conn-port', '5432']"}	\N
3	2026-05-05 19:13:12.185114+00	\N	\N	\N	cli_users_create	\N	\N	airflow	\N	{"host_name": "cb9412bb5c12", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Data', '--lastname', 'Admin', '--role', 'Admin', '--email', 'admin@example.com']"}	\N
4	2026-05-05 19:13:29.478713+00	\N	\N	\N	cli_check	\N	\N	airflow	\N	{"host_name": "1f784f08d39a", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}	\N
5	2026-05-05 19:13:30.127725+00	\N	\N	\N	cli_check	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}	\N
6	2026-05-05 19:13:41.807605+00	\N	\N	\N	cli_webserver	\N	\N	airflow	\N	{"host_name": "1f784f08d39a", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}	\N
7	2026-05-05 19:13:46.347858+00	\N	\N	\N	cli_scheduler	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
8	2026-05-05 19:25:05.568916+00	customer_order_summary	\N	\N	trigger	\N	\N	admin	Data Admin	{"redirect_url": "/home"}	\N
9	2026-05-05 19:25:06.250595+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
10	2026-05-05 19:25:06.258658+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
11	2026-05-05 19:25:06.87685+00	customer_order_summary	create_warehouse_schema	-1	running	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
12	2026-05-05 19:25:06.878094+00	customer_order_summary	create_warehouse_schema	-1	running	2026-05-05 19:25:05.574225+00	manual__2026-05-05T19:25:05.574225+00:00	data-platform	\N	\N	1
13	2026-05-05 19:25:06.907243+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
14	2026-05-05 19:25:06.907849+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
15	2026-05-05 19:25:07.58162+00	customer_order_summary	create_warehouse_schema	-1	success	2026-05-05 19:25:05.574225+00	manual__2026-05-05T19:25:05.574225+00:00	data-platform	\N	\N	1
16	2026-05-05 19:25:07.576424+00	customer_order_summary	create_warehouse_schema	-1	failed	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
17	2026-05-05 19:25:08.380942+00	customer_order_summary	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
18	2026-05-05 19:25:08.824611+00	customer_order_summary	refresh_warehouse	-1	running	2026-05-05 19:25:05.574225+00	manual__2026-05-05T19:25:05.574225+00:00	data-platform	\N	\N	1
19	2026-05-05 19:25:08.848465+00	customer_order_summary	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
20	2026-05-05 19:25:09.393299+00	customer_order_summary	refresh_warehouse	-1	success	2026-05-05 19:25:05.574225+00	manual__2026-05-05T19:25:05.574225+00:00	data-platform	\N	\N	1
21	2026-05-05 19:25:09.503618+00	customer_order_summary	build_customer_order_summary	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
22	2026-05-05 19:25:10.012068+00	customer_order_summary	build_customer_order_summary	-1	running	2026-05-05 19:25:05.574225+00	manual__2026-05-05T19:25:05.574225+00:00	data-platform	\N	\N	1
23	2026-05-05 19:25:10.035871+00	customer_order_summary	build_customer_order_summary	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
24	2026-05-05 19:25:10.561994+00	customer_order_summary	build_customer_order_summary	-1	success	2026-05-05 19:25:05.574225+00	manual__2026-05-05T19:25:05.574225+00:00	data-platform	\N	\N	1
25	2026-05-05 19:27:36.513503+00	customer_order_summary	\N	\N	trigger	\N	\N	admin	Data Admin	{"origin": "/dags/customer_order_summary/grid?execution_date=2026-05-04+00%3A00%3A00%2B00%3A00"}	\N
26	2026-05-05 19:27:36.93402+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
27	2026-05-05 19:27:38.135803+00	customer_order_summary	create_warehouse_schema	-1	running	2026-05-05 19:27:36.525312+00	manual__2026-05-05T19:27:36.525312+00:00	data-platform	\N	\N	1
28	2026-05-05 19:27:38.173836+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
29	2026-05-05 19:27:38.931702+00	customer_order_summary	create_warehouse_schema	-1	success	2026-05-05 19:27:36.525312+00	manual__2026-05-05T19:27:36.525312+00:00	data-platform	\N	\N	1
30	2026-05-05 19:27:39.113566+00	customer_order_summary	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
31	2026-05-05 19:27:39.971246+00	customer_order_summary	refresh_warehouse	-1	running	2026-05-05 19:27:36.525312+00	manual__2026-05-05T19:27:36.525312+00:00	data-platform	\N	\N	1
32	2026-05-05 19:27:40.019035+00	customer_order_summary	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
33	2026-05-05 19:27:40.906596+00	customer_order_summary	refresh_warehouse	-1	success	2026-05-05 19:27:36.525312+00	manual__2026-05-05T19:27:36.525312+00:00	data-platform	\N	\N	1
34	2026-05-05 19:27:41.316726+00	customer_order_summary	build_customer_order_summary	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
35	2026-05-05 19:27:41.971984+00	customer_order_summary	build_customer_order_summary	-1	running	2026-05-05 19:27:36.525312+00	manual__2026-05-05T19:27:36.525312+00:00	data-platform	\N	\N	1
36	2026-05-05 19:27:42.012366+00	customer_order_summary	build_customer_order_summary	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
37	2026-05-05 19:27:42.628296+00	customer_order_summary	build_customer_order_summary	-1	success	2026-05-05 19:27:36.525312+00	manual__2026-05-05T19:27:36.525312+00:00	data-platform	\N	\N	1
38	2026-05-05 19:30:08.38864+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
39	2026-05-05 19:30:08.875652+00	customer_order_summary	create_warehouse_schema	-1	running	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	2
40	2026-05-05 19:30:08.904356+00	customer_order_summary	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
41	2026-05-05 19:30:09.463365+00	customer_order_summary	create_warehouse_schema	-1	success	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	2
42	2026-05-05 19:30:09.793286+00	customer_order_summary	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
43	2026-05-05 19:30:10.271897+00	customer_order_summary	refresh_warehouse	-1	running	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
44	2026-05-05 19:30:10.297951+00	customer_order_summary	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
45	2026-05-05 19:30:10.887267+00	customer_order_summary	refresh_warehouse	-1	success	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
46	2026-05-05 19:30:11.966609+00	customer_order_summary	build_customer_order_summary	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
47	2026-05-05 19:30:12.496427+00	customer_order_summary	build_customer_order_summary	-1	running	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
48	2026-05-05 19:30:12.531862+00	customer_order_summary	build_customer_order_summary	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
49	2026-05-05 19:30:13.102281+00	customer_order_summary	build_customer_order_summary	-1	success	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
50	2026-05-05 19:36:07.586306+00	security_audit_report	\N	\N	trigger	\N	\N	admin	Data Admin	{"origin": "/dags/security_audit_report/grid"}	\N
51	2026-05-05 19:36:07.939703+00	security_audit_report	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
52	2026-05-05 19:36:07.944812+00	security_audit_report	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
53	2026-05-05 19:36:08.510527+00	security_audit_report	create_warehouse_schema	-1	running	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
54	2026-05-05 19:36:08.514294+00	security_audit_report	create_warehouse_schema	-1	running	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	1
55	2026-05-05 19:36:08.53867+00	security_audit_report	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
56	2026-05-05 19:36:08.545584+00	security_audit_report	create_warehouse_schema	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
57	2026-05-05 19:36:09.106486+00	security_audit_report	create_warehouse_schema	-1	success	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	1
58	2026-05-05 19:36:09.109396+00	security_audit_report	create_warehouse_schema	-1	success	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
59	2026-05-05 19:36:09.304027+00	security_audit_report	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
60	2026-05-05 19:36:09.304731+00	security_audit_report	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
61	2026-05-05 19:36:09.786973+00	security_audit_report	refresh_warehouse	-1	running	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
62	2026-05-05 19:36:09.793751+00	security_audit_report	refresh_warehouse	-1	running	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	1
63	2026-05-05 19:36:09.81432+00	security_audit_report	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
64	2026-05-05 19:36:09.82062+00	security_audit_report	refresh_warehouse	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
65	2026-05-05 19:36:10.429231+00	security_audit_report	refresh_warehouse	-1	success	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	1
66	2026-05-05 19:36:10.449438+00	security_audit_report	refresh_warehouse	-1	success	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
67	2026-05-05 19:36:11.488594+00	security_audit_report	build_security_audit_report	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
68	2026-05-05 19:36:11.487881+00	security_audit_report	build_security_audit_report	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
69	2026-05-05 19:36:12.049992+00	security_audit_report	build_security_audit_report	-1	running	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
70	2026-05-05 19:36:12.060692+00	security_audit_report	build_security_audit_report	-1	running	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	1
71	2026-05-05 19:36:12.085788+00	security_audit_report	build_security_audit_report	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
72	2026-05-05 19:36:12.096083+00	security_audit_report	build_security_audit_report	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
73	2026-05-05 19:36:12.712983+00	security_audit_report	build_security_audit_report	-1	success	2026-05-04 00:00:00+00	scheduled__2026-05-04T00:00:00+00:00	data-platform	\N	\N	1
74	2026-05-05 19:36:12.712858+00	security_audit_report	build_security_audit_report	-1	failed	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	1
75	2026-05-05 19:41:13.339012+00	security_audit_report	build_security_audit_report	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
76	2026-05-05 19:41:14.1703+00	security_audit_report	build_security_audit_report	-1	running	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	2
77	2026-05-05 19:41:14.21272+00	security_audit_report	build_security_audit_report	\N	cli_task_run	\N	\N	airflow	\N	{"host_name": "487402b4e129", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}	\N
78	2026-05-05 19:41:15.01506+00	security_audit_report	build_security_audit_report	-1	success	2026-05-05 19:36:07.591062+00	manual__2026-05-05T19:36:07.591062+00:00	data-platform	\N	\N	2
\.


--
-- Data for Name: log_template; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.log_template (id, filename, elasticsearch_id, created_at) FROM stdin;
1	{{ ti.dag_id }}/{{ ti.task_id }}/{{ ts }}/{{ try_number }}.log	{dag_id}-{task_id}-{execution_date}-{try_number}	2026-05-05 19:12:39.098321+00
2	dag_id={{ ti.dag_id }}/run_id={{ ti.run_id }}/task_id={{ ti.task_id }}/{% if ti.map_index >= 0 %}map_index={{ ti.map_index }}/{% endif %}attempt={{ try_number }}.log	{dag_id}-{task_id}-{run_id}-{map_index}-{try_number}	2026-05-05 19:12:39.098329+00
\.


--
-- Data for Name: login_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.login_attempts (id, email, success, ip_address, user_agent, failure_code, created_at) FROM stdin;
1	admin@ecommerce.local	f	\N	\N	INVALID_CREDENTIALS	2026-05-05 17:33:23.590019+00
2	employee@example.com	t	\N	\N	\N	2026-05-05 17:33:30.66342+00
3	employee@example.com	t	\N	\N	\N	2026-05-05 17:36:08.230725+00
4	admin@example.com	t	\N	\N	\N	2026-05-05 17:36:23.861794+00
5	admin@example.com	t	\N	\N	\N	2026-05-05 19:31:38.215927+00
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, order_id, payment_reference, method, status, amount, created_at) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, name, description, created_at) FROM stdin;
1	ADMIN_PANEL_ACCESS	Access admin panel	2026-05-05 16:54:59.665428+00
2	PRODUCT_READ	Read products	2026-05-05 16:54:59.665428+00
3	PRODUCT_CREATE	Create products	2026-05-05 16:54:59.665428+00
4	PRODUCT_UPDATE	Update products	2026-05-05 16:54:59.665428+00
5	PRODUCT_DELETE	Delete products	2026-05-05 16:54:59.665428+00
6	PRODUCT_IMAGE_UPLOAD	Upload product images	2026-05-05 16:54:59.665428+00
7	PRODUCT_IMAGE_DELETE	Delete product images	2026-05-05 16:54:59.665428+00
8	PRODUCT_IMAGE_SET_PRIMARY	Set primary product image	2026-05-05 16:54:59.665428+00
9	CATEGORY_READ	Read categories	2026-05-05 16:54:59.665428+00
10	CATEGORY_CREATE	Create categories	2026-05-05 16:54:59.665428+00
11	CATEGORY_UPDATE	Update categories	2026-05-05 16:54:59.665428+00
12	CATEGORY_DELETE	Delete categories	2026-05-05 16:54:59.665428+00
13	ORDER_READ_OWN	Read own orders	2026-05-05 16:54:59.665428+00
14	ORDER_READ_ALL	Read all orders	2026-05-05 16:54:59.665428+00
15	USER_MANAGE	Manage users	2026-05-05 16:54:59.665428+00
16	ROLE_MANAGE	Manage roles	2026-05-05 16:54:59.665428+00
17	AUDIT_READ	Read audit logs	2026-05-05 16:56:15.305157+00
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_images (id, content_type, created_at, file_size, image_order, original_file_name, primary_image, relative_path, stored_file_name, product_id) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, created_at, description, name, price, slug, status, stock_quantity, updated_at, category_id) FROM stdin;
1	2026-05-04 21:15:04.131241	6.6" Super AMOLED ekran, 50MP kamera, 5000mAh batarya, Android 14	Samsung Galaxy A55	12999.99	samsung-galaxy-a55	ACTIVE	50	\N	1
4	2026-05-04 21:15:04.131241	Deri üst, Air-Sole taban, unisex sneaker, günlük kullanım	Nike Air Force 1 Beyaz	3299.00	nike-air-force-1-beyaz	ACTIVE	45	\N	2
5	2026-05-04 21:15:04.131241	3 adet akıllı ampul + bridge, 16 milyon renk, ses asistanı uyumlu	Philips Hue Starter Kit	1899.00	philips-hue-starter-kit	ACTIVE	20	\N	3
6	2026-05-04 21:15:04.131241	3 farklı boyut, doğal bambu, antibakteriyel yüzey, kulplu	Bambu Kesme Tahtası Seti	349.90	bambu-kesme-tahtasi-seti	ACTIVE	60	\N	3
7	2026-05-04 21:15:04.131241	Koşu GPS saati, AMOLED ekran, kalp atış takibi, 13 gün pil	Garmin Forerunner 265	9999.00	garmin-forerunner-265	ACTIVE	15	\N	4
8	2026-05-04 21:15:04.131241	UV korumalı, anti-buğu lens, ayarlanabilir askı, yetişkin	Decathlon Yüzme Gözlüğü	129.90	decathlon-yuzme-gozlugu	ACTIVE	100	\N	4
9	2026-05-04 21:15:04.131241	Küçük alışkanlıkların büyük farkı, kişisel gelişim kitabı, Türkçe çeviri	Atomic Habits - James Clear	189.00	atomic-habits-james-clear	ACTIVE	200	\N	5
10	2026-05-04 21:15:04.131241	80 yaprak, kareli iç sayfa, sert kapak, siyah	Rhodia A5 Defter	229.00	rhodia-a5-defter	ACTIVE	75	\N	5
11	2026-05-04 21:15:04.131241	177ml, hyaluronik asit + ceramide, yağsız formül, tüm cilt tipleri	CeraVe Nemlendirici Krem	389.90	cerave-nemlendirici-krem	ACTIVE	90	\N	6
12	2026-05-04 21:15:04.131241	30ml, gözenek sıkılaştırıcı, yüz serumu, yağlı ciltler için	The Ordinary Niacinamide 10%	269.00	the-ordinary-niacinamide	ACTIVE	120	\N	6
13	2026-05-04 21:15:04.131241	3599 parça, 1:8 ölçek, hareketli motor, 16+ yaş	LEGO Technic Bugatti Chiron	4299.00	lego-technic-bugatti-chiron	ACTIVE	10	\N	7
14	2026-05-04 21:15:04.131241	80 parça, büyük bloklar, 1-3 yaş, BPA içermez	Mega Bloks İlk İnşaatçım	259.90	mega-bloks-ilk-insaatcim	ACTIVE	55	\N	7
15	2026-05-04 21:15:04.131241	Soğuk sıkım, doğal sertifikalı, erken hasat, %0.2 asitlik	Organik Zeytinyağı 750ml	449.00	organik-zeytinyagi-750ml	ACTIVE	40	\N	8
16	2026-05-04 21:15:04.131241	500g, badem-ceviz-fındık karışımı, tuzsuz, glutensiz	Premium Karışık Kuruyemiş	299.90	premium-karisik-kuruyemis	ACTIVE	65	\N	8
17	2026-05-04 21:15:04.131241	Paslanmaz çelik bıçak, ergonomik tutacak, dal kesme, 21cm	Fiskars Bahçe Makası	599.00	fiskars-bahce-makasi	ACTIVE	35	\N	9
18	2026-05-04 21:15:04.131241	20 bitkiye kadar, zamanlayıcılı, otomatik, bluetooth kontrol	Akıllı Damla Sulama Seti	1299.00	akilli-damla-sulama-seti	ACTIVE	25	\N	9
19	2026-05-04 21:15:04.131241	60Ah, 540A CCA, start-stop uyumlu, 2 yıl garanti	Bosch S5 Akü 60Ah	2199.00	bosch-s5-aku-60ah	ACTIVE	20	\N	10
20	2026-05-04 21:15:04.131241	Yaz lastiği, spor kullanım, üstün yol tutuş, 225/45 R17 94Y	Michelin Pilot Sport 5 225/45R17	3499.00	michelin-pilot-sport-5	ACTIVE	30	\N	10
27	2026-05-05 16:56:15.261656	Multi-port dock with Ethernet, HDMI and power delivery.	USB-C Productivity Dock	3499.90	usb-c-productivity-dock	ACTIVE	35	\N	24
28	2026-05-05 16:56:15.261656	Portable workstation for Java and frontend development.	Developer Laptop Pro 14	64999.90	developer-laptop-pro-14	ACTIVE	12	\N	24
29	2026-05-05 16:56:15.261656	Durable cotton hoodie with a clean workwear fit.	Everyday Tech Hoodie	1499.90	everyday-tech-hoodie	ACTIVE	48	\N	25
30	2026-05-05 16:56:15.261656	Adjustable LED desk lamp for focused workspaces.	Ergonomic Desk Lamp	899.90	ergonomic-desk-lamp	ACTIVE	64	\N	26
31	2026-05-05 16:56:15.261656	Insulated bottle for gym and outdoor training.	Smart Training Bottle	699.90	smart-training-bottle	ACTIVE	80	\N	27
3	2026-05-04 21:15:04.131241	Klasik düz kesim denim pantolon, %100 pamuk, erkek	Levi's 501 Original Jeans	1499.00	levis-501-original-jeans	ACTIVE	79	2026-05-05 17:55:19.4187	2
2	2026-05-04 21:15:04.131241	Kompakt kablosuz klavye, çoklu cihaz desteği, USB-C şarj	Logitech MX Keys Mini	2299.90	logitech-mx-keys-mini	ACTIVE	25	2026-05-05 19:50:02.356878	1
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, revoked_at, created_at) FROM stdin;
1	2	DL4PR5PFWKsIK9AHxIwTE9DnjPeCU9sgpwMTMnrUJWg	2026-05-12 17:33:30.723664+00	2026-05-05 17:36:08.242953+00	2026-05-05 17:33:30.721108+00
2	2	PnbUN5123edUz45KAMsj8beOubkYzcUBVnRW9jSAHHs	2026-05-12 17:36:08.243804+00	\N	2026-05-05 17:36:08.242953+00
3	1	Ioe1lKDBJ4nJcrpP3ER6QPh4o7rFqwz9rSnY3UO6Ap0	2026-05-12 17:36:23.874814+00	2026-05-05 19:31:38.405405+00	2026-05-05 17:36:23.874166+00
4	1	MxIAhjDjr25qJBpDEp1_qsnhHG4G6WaUjZm5i0g3BtQ	2026-05-12 19:31:38.40771+00	\N	2026-05-05 19:31:38.405405+00
\.


--
-- Data for Name: rendered_task_instance_fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rendered_task_instance_fields (dag_id, task_id, run_id, map_index, rendered_fields, k8s_pod_yaml) FROM stdin;
customer_order_summary	create_warehouse_schema	scheduled__2026-05-04T00:00:00+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	create_warehouse_schema	manual__2026-05-05T19:25:05.574225+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	refresh_warehouse	manual__2026-05-05T19:25:05.574225+00:00	-1	{"sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	build_customer_order_summary	manual__2026-05-05T19:25:05.574225+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.customer_order_summary AS\\nSELECT\\n    c.email,\\n    COUNT(o.order_id) AS order_count,\\n    SUM(o.total_amount) AS total_spend,\\n    MAX(o.date_key) AS last_order_date\\nFROM dw.dim_customer c\\nLEFT JOIN dw.fact_orders o ON o.customer_key = c.customer_key\\nGROUP BY c.email\\nORDER BY total_spend DESC NULLS LAST;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	create_warehouse_schema	manual__2026-05-05T19:27:36.525312+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	refresh_warehouse	manual__2026-05-05T19:27:36.525312+00:00	-1	{"sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	build_customer_order_summary	manual__2026-05-05T19:27:36.525312+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.customer_order_summary AS\\nSELECT\\n    c.email,\\n    COUNT(o.order_id) AS order_count,\\n    SUM(o.total_amount) AS total_spend,\\n    MAX(o.date_key) AS last_order_date\\nFROM dw.dim_customer c\\nLEFT JOIN dw.fact_orders o ON o.customer_key = c.customer_key\\nGROUP BY c.email\\nORDER BY total_spend DESC NULLS LAST;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	refresh_warehouse	scheduled__2026-05-04T00:00:00+00:00	-1	{"sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
customer_order_summary	build_customer_order_summary	scheduled__2026-05-04T00:00:00+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.customer_order_summary AS\\nSELECT\\n    c.email,\\n    COUNT(o.order_id) AS order_count,\\n    SUM(o.total_amount) AS total_spend,\\n    MAX(o.date_key) AS last_order_date\\nFROM dw.dim_customer c\\nLEFT JOIN dw.fact_orders o ON o.customer_key = c.customer_key\\nGROUP BY c.email\\nORDER BY total_spend DESC NULLS LAST;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
security_audit_report	create_warehouse_schema	scheduled__2026-05-04T00:00:00+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
security_audit_report	create_warehouse_schema	manual__2026-05-05T19:36:07.591062+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
security_audit_report	refresh_warehouse	manual__2026-05-05T19:36:07.591062+00:00	-1	{"sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
security_audit_report	refresh_warehouse	scheduled__2026-05-04T00:00:00+00:00	-1	{"sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
security_audit_report	build_security_audit_report	scheduled__2026-05-04T00:00:00+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.security_audit_report AS\\nSELECT\\n    actor_email,\\n    action,\\n    resource_type,\\n    COUNT(*) AS event_count,\\n    MAX(created_at) AS last_seen_at\\nFROM staging.audit_logs\\nGROUP BY actor_email, action, resource_type\\nORDER BY last_seen_at DESC;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
security_audit_report	build_security_audit_report	manual__2026-05-05T19:36:07.591062+00:00	-1	{"sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.security_audit_report AS\\nSELECT\\n    actor_email,\\n    action,\\n    resource_type,\\n    COUNT(*) AS event_count,\\n    MAX(created_at) AS last_seen_at\\nFROM staging.audit_logs\\nGROUP BY actor_email, action, resource_type\\nORDER BY last_seen_at DESC;", "parameters": null, "conn_id": "ecommerce_postgres", "database": null, "hook_params": {}}	null
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	10
1	11
1	12
1	13
1	14
1	15
1	16
2	1
2	2
2	3
2	4
2	6
2	8
2	9
2	13
3	2
3	13
1	17
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, description, created_at) FROM stdin;
1	ADMIN	Full platform administrator	2026-05-05 16:54:59.665428+00
2	EMPLOYEE	Back office catalog operator	2026-05-05 16:54:59.665428+00
3	CUSTOMER	Storefront customer	2026-05-05 16:54:59.665428+00
\.


--
-- Data for Name: serialized_dag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.serialized_dag (dag_id, fileloc, fileloc_hash, data, data_compressed, last_updated, dag_hash, processor_subdir) FROM stdin;
daily_sales_report	/opt/airflow/dags/ecommerce_warehouse_etl.py	39676071369142587	{"__version": 1, "dag": {"timezone": "UTC", "fileloc": "/opt/airflow/dags/ecommerce_warehouse_etl.py", "schedule_interval": "@daily", "tags": ["ecommerce", "etl", "warehouse"], "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"create_warehouse_schema": ["operator", "create_warehouse_schema"], "refresh_warehouse": ["operator", "refresh_warehouse"], "build_daily_sales_report": ["operator", "build_daily_sales_report"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "edge_info": {}, "start_date": 1777593600.0, "catchup": false, "default_args": {"__var": {"owner": "data-platform", "retries": 1}, "__type": "dict"}, "_dag_id": "daily_sales_report", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"__var": {"on_failure_fail_dagrun": false, "task_id": "create_warehouse_schema", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["refresh_warehouse"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "refresh_warehouse", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["build_daily_sales_report"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "build_daily_sales_report", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": [], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.daily_sales_report AS\\nSELECT\\n    date_key,\\n    COUNT(*) AS order_count,\\n    SUM(item_count) AS item_count,\\n    SUM(total_amount) AS gross_sales\\nFROM dw.fact_orders\\nGROUP BY date_key\\nORDER BY date_key DESC;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}], "dag_dependencies": [], "params": []}}	\N	2026-05-05 19:13:51.63557+00	aa311af9e8ec72faa7d23cce1435a4a7	/opt/airflow/dags
failed_payment_report	/opt/airflow/dags/ecommerce_warehouse_etl.py	39676071369142587	{"__version": 1, "dag": {"timezone": "UTC", "fileloc": "/opt/airflow/dags/ecommerce_warehouse_etl.py", "schedule_interval": "@daily", "tags": ["ecommerce", "etl", "warehouse"], "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"create_warehouse_schema": ["operator", "create_warehouse_schema"], "refresh_warehouse": ["operator", "refresh_warehouse"], "build_failed_payment_report": ["operator", "build_failed_payment_report"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "edge_info": {}, "start_date": 1777593600.0, "catchup": false, "default_args": {"__var": {"owner": "data-platform", "retries": 1}, "__type": "dict"}, "_dag_id": "failed_payment_report", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"__var": {"on_failure_fail_dagrun": false, "task_id": "create_warehouse_schema", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["refresh_warehouse"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "refresh_warehouse", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["build_failed_payment_report"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "build_failed_payment_report", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": [], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.failed_payment_report AS\\nSELECT\\n    payment_reference,\\n    order_id,\\n    date_key,\\n    payment_method,\\n    amount\\nFROM dw.fact_payments\\nWHERE status = 'PAYMENT_FAILED'\\nORDER BY date_key DESC;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}], "dag_dependencies": [], "params": []}}	\N	2026-05-05 19:13:52.11439+00	d99d4224bd80cc216eeb1338055fcb79	/opt/airflow/dags
product_performance_report	/opt/airflow/dags/ecommerce_warehouse_etl.py	39676071369142587	{"__version": 1, "dag": {"timezone": "UTC", "fileloc": "/opt/airflow/dags/ecommerce_warehouse_etl.py", "schedule_interval": "@daily", "tags": ["ecommerce", "etl", "warehouse"], "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"create_warehouse_schema": ["operator", "create_warehouse_schema"], "refresh_warehouse": ["operator", "refresh_warehouse"], "build_product_performance_report": ["operator", "build_product_performance_report"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "edge_info": {}, "start_date": 1777593600.0, "catchup": false, "default_args": {"__var": {"owner": "data-platform", "retries": 1}, "__type": "dict"}, "_dag_id": "product_performance_report", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"__var": {"on_failure_fail_dagrun": false, "task_id": "create_warehouse_schema", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["refresh_warehouse"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "refresh_warehouse", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["build_product_performance_report"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "build_product_performance_report", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": [], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.product_performance_report AS\\nSELECT\\n    p.product_id,\\n    p.name,\\n    p.status,\\n    i.stock_quantity,\\n    i.snapshot_date\\nFROM dw.dim_product p\\nLEFT JOIN dw.fact_inventory i ON i.product_key = p.product_key\\nORDER BY p.name;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}], "dag_dependencies": [], "params": []}}	\N	2026-05-05 19:13:52.202587+00	4beed073a5703dbf1b35c095ec9904f5	/opt/airflow/dags
customer_order_summary	/opt/airflow/dags/ecommerce_warehouse_etl.py	39676071369142587	{"__version": 1, "dag": {"timezone": "UTC", "fileloc": "/opt/airflow/dags/ecommerce_warehouse_etl.py", "schedule_interval": "@daily", "tags": ["ecommerce", "etl", "warehouse"], "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"create_warehouse_schema": ["operator", "create_warehouse_schema"], "refresh_warehouse": ["operator", "refresh_warehouse"], "build_customer_order_summary": ["operator", "build_customer_order_summary"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "edge_info": {}, "start_date": 1777593600.0, "catchup": false, "default_args": {"__var": {"owner": "data-platform", "retries": 1}, "__type": "dict"}, "_dag_id": "customer_order_summary", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"__var": {"on_failure_fail_dagrun": false, "task_id": "create_warehouse_schema", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["refresh_warehouse"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "refresh_warehouse", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["build_customer_order_summary"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "build_customer_order_summary", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": [], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.customer_order_summary AS\\nSELECT\\n    c.email,\\n    COUNT(o.order_id) AS order_count,\\n    SUM(o.total_amount) AS total_spend,\\n    MAX(o.date_key) AS last_order_date\\nFROM dw.dim_customer c\\nLEFT JOIN dw.fact_orders o ON o.customer_key = c.customer_key\\nGROUP BY c.email\\nORDER BY total_spend DESC NULLS LAST;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}], "dag_dependencies": [], "params": []}}	\N	2026-05-05 19:13:52.295592+00	0edebe45936a29efa69f0754033dec3b	/opt/airflow/dags
security_audit_report	/opt/airflow/dags/ecommerce_warehouse_etl.py	39676071369142587	{"__version": 1, "dag": {"timezone": "UTC", "fileloc": "/opt/airflow/dags/ecommerce_warehouse_etl.py", "schedule_interval": "@daily", "tags": ["ecommerce", "etl", "warehouse"], "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"create_warehouse_schema": ["operator", "create_warehouse_schema"], "refresh_warehouse": ["operator", "refresh_warehouse"], "build_security_audit_report": ["operator", "build_security_audit_report"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "edge_info": {}, "start_date": 1777593600.0, "catchup": false, "default_args": {"__var": {"owner": "data-platform", "retries": 1}, "__type": "dict"}, "_dag_id": "security_audit_report", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"__var": {"on_failure_fail_dagrun": false, "task_id": "create_warehouse_schema", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["refresh_warehouse"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS staging;\\nCREATE SCHEMA IF NOT EXISTS dw;\\n\\nCREATE TABLE IF NOT EXISTS staging.orders (\\n    id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    user_email VARCHAR(255),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    payment_method VARCHAR(255),\\n    payment_reference VARCHAR(255),\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.order_items (\\n    id BIGINT PRIMARY KEY,\\n    order_id BIGINT,\\n    product_id BIGINT,\\n    product_name VARCHAR(255),\\n    product_slug VARCHAR(255),\\n    unit_price NUMERIC(12, 2),\\n    quantity INT,\\n    line_total NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.products (\\n    id BIGINT PRIMARY KEY,\\n    category_id BIGINT,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    price NUMERIC(12, 2),\\n    stock_quantity INT,\\n    status VARCHAR(20),\\n    updated_at TIMESTAMP,\\n    created_at TIMESTAMP\\n);\\n\\nCREATE TABLE IF NOT EXISTS staging.audit_logs (\\n    id BIGINT PRIMARY KEY,\\n    actor_email VARCHAR(255),\\n    action VARCHAR(120),\\n    resource_type VARCHAR(120),\\n    resource_id VARCHAR(120),\\n    details TEXT,\\n    created_at TIMESTAMPTZ\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_customer (\\n    customer_key BIGSERIAL PRIMARY KEY,\\n    email VARCHAR(255) NOT NULL UNIQUE\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_product (\\n    product_key BIGSERIAL PRIMARY KEY,\\n    product_id BIGINT NOT NULL UNIQUE,\\n    name VARCHAR(160),\\n    slug VARCHAR(180),\\n    category_id BIGINT,\\n    current_price NUMERIC(12, 2),\\n    status VARCHAR(20)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.dim_date (\\n    date_key DATE PRIMARY KEY,\\n    year INT NOT NULL,\\n    month INT NOT NULL,\\n    day INT NOT NULL\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_orders (\\n    order_id BIGINT PRIMARY KEY,\\n    order_number VARCHAR(255),\\n    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    status VARCHAR(40),\\n    subtotal NUMERIC(12, 2),\\n    shipping_cost NUMERIC(12, 2),\\n    tax NUMERIC(12, 2),\\n    total_amount NUMERIC(12, 2),\\n    item_count INT\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_payments (\\n    payment_reference VARCHAR(255) PRIMARY KEY,\\n    order_id BIGINT REFERENCES dw.fact_orders(order_id),\\n    date_key DATE REFERENCES dw.dim_date(date_key),\\n    payment_method VARCHAR(255),\\n    status VARCHAR(40),\\n    amount NUMERIC(12, 2)\\n);\\n\\nCREATE TABLE IF NOT EXISTS dw.fact_inventory (\\n    product_id BIGINT PRIMARY KEY,\\n    product_key BIGINT REFERENCES dw.dim_product(product_key),\\n    stock_quantity INT,\\n    snapshot_date DATE\\n);\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "refresh_warehouse", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": ["build_security_audit_report"], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "TRUNCATE staging.orders;\\nTRUNCATE staging.order_items;\\nTRUNCATE staging.products;\\nTRUNCATE staging.audit_logs;\\n\\nINSERT INTO staging.orders (\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\n)\\nSELECT\\n    id, order_number, user_email, status, subtotal, shipping_cost, tax,\\n    total_amount, payment_method, payment_reference, created_at\\nFROM customer_orders;\\n\\nINSERT INTO staging.order_items (\\n    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\n)\\nSELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total\\nFROM customer_order_items;\\n\\nINSERT INTO staging.products (\\n    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\n)\\nSELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at\\nFROM products;\\n\\nINSERT INTO staging.audit_logs (\\n    id, actor_email, action, resource_type, resource_id, details, created_at\\n)\\nSELECT id, actor_email, action, resource_type, resource_id, details, created_at\\nFROM audit_logs;\\n\\nINSERT INTO dw.dim_customer (email)\\nSELECT DISTINCT user_email\\nFROM staging.orders\\nWHERE user_email IS NOT NULL\\nON CONFLICT (email) DO NOTHING;\\n\\nINSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)\\nSELECT id, name, slug, category_id, price, status\\nFROM staging.products\\nON CONFLICT (product_id) DO UPDATE SET\\n    name = EXCLUDED.name,\\n    slug = EXCLUDED.slug,\\n    category_id = EXCLUDED.category_id,\\n    current_price = EXCLUDED.current_price,\\n    status = EXCLUDED.status;\\n\\nINSERT INTO dw.dim_date (date_key, year, month, day)\\nSELECT DISTINCT\\n    created_at::date,\\n    EXTRACT(YEAR FROM created_at)::int,\\n    EXTRACT(MONTH FROM created_at)::int,\\n    EXTRACT(DAY FROM created_at)::int\\nFROM staging.orders\\nWHERE created_at IS NOT NULL\\nON CONFLICT (date_key) DO NOTHING;\\n\\nINSERT INTO dw.fact_orders (\\n    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count\\n)\\nSELECT\\n    o.id,\\n    o.order_number,\\n    c.customer_key,\\n    o.created_at::date,\\n    o.status,\\n    o.subtotal,\\n    o.shipping_cost,\\n    o.tax,\\n    o.total_amount,\\n    COALESCE(SUM(oi.quantity), 0)::int\\nFROM staging.orders o\\nLEFT JOIN staging.order_items oi ON oi.order_id = o.id\\nLEFT JOIN dw.dim_customer c ON c.email = o.user_email\\nGROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount\\nON CONFLICT (order_id) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    subtotal = EXCLUDED.subtotal,\\n    shipping_cost = EXCLUDED.shipping_cost,\\n    tax = EXCLUDED.tax,\\n    total_amount = EXCLUDED.total_amount,\\n    item_count = EXCLUDED.item_count;\\n\\nINSERT INTO dw.fact_payments (\\n    payment_reference, order_id, date_key, payment_method, status, amount\\n)\\nSELECT\\n    payment_reference,\\n    id,\\n    created_at::date,\\n    payment_method,\\n    status,\\n    total_amount\\nFROM staging.orders\\nWHERE payment_reference IS NOT NULL\\nON CONFLICT (payment_reference) DO UPDATE SET\\n    status = EXCLUDED.status,\\n    amount = EXCLUDED.amount;\\n\\nINSERT INTO dw.fact_inventory (\\n    product_id, product_key, stock_quantity, snapshot_date\\n)\\nSELECT\\n    p.id,\\n    dp.product_key,\\n    p.stock_quantity,\\n    CURRENT_DATE\\nFROM staging.products p\\nJOIN dw.dim_product dp ON dp.product_id = p.id\\nON CONFLICT (product_id) DO UPDATE SET\\n    product_key = EXCLUDED.product_key,\\n    stock_quantity = EXCLUDED.stock_quantity,\\n    snapshot_date = EXCLUDED.snapshot_date;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}, {"__var": {"on_failure_fail_dagrun": false, "task_id": "build_security_audit_report", "_needs_expansion": false, "ui_color": "#ededed", "ui_fgcolor": "#000", "retries": 1, "owner": "data-platform", "template_fields": ["sql", "parameters", "conn_id", "database", "hook_params"], "pool": "default_pool", "downstream_task_ids": [], "template_fields_renderers": {"sql": "postgresql", "parameters": "json"}, "_log_config_logger_name": "airflow.task.operators", "is_setup": false, "start_from_trigger": false, "weight_rule": "downstream", "is_teardown": false, "template_ext": [".sql", ".json"], "_task_type": "PostgresOperator", "_task_module": "airflow.providers.postgres.operators.postgres", "_is_empty": false, "start_trigger_args": null, "sql": "CREATE SCHEMA IF NOT EXISTS reports;\\n\\nCREATE OR REPLACE VIEW reports.security_audit_report AS\\nSELECT\\n    actor_email,\\n    action,\\n    resource_type,\\n    COUNT(*) AS event_count,\\n    MAX(created_at) AS last_seen_at\\nFROM staging.audit_logs\\nGROUP BY actor_email, action, resource_type\\nORDER BY last_seen_at DESC;\\n", "conn_id": "ecommerce_postgres", "hook_params": {}}, "__type": "operator"}], "dag_dependencies": [], "params": []}}	\N	2026-05-05 19:13:52.40242+00	75f73342b00e312ee46f0cfd60139a2c	/opt/airflow/dags
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.session (id, session_id, data, expiry) FROM stdin;
2	207705cc-50ec-46ca-818b-a83cf7a3a4e9	\\x800495db010000000000007d94288c0a5f7065726d616e656e7494888c065f667265736894888c0a637372665f746f6b656e948c2865633264343065366561353838323931353931383339363631336138316566343266376338376363948c066c6f63616c65948c02656e948c085f757365725f6964944b018c035f6964948c806364333935313534346431333666313037626534313832656661356162363235613437363663613534376462313236663031316462666538663864633930366232353232316130306437383435333165653832393466333161643662356133326432646132653031363366353064666338353635646532633961636637383338948c116461675f7374617475735f66696c746572948c03616c6c948c0c706167655f686973746f7279945d94288c21687474703a2f2f6c6f63616c686f73743a383038382f75736572732f6c6973742f948c21687474703a2f2f6c6f63616c686f73743a383038382f726f6c65732f6c6973742f948c22687474703a2f2f6c6f63616c686f73743a383038382f64616772756e2f6c6973742f948c1f687474703a2f2f6c6f63616c686f73743a383038382f6a6f622f6c6973742f948c23687474703a2f2f6c6f63616c686f73743a383038382f616374696f6e732f6c6973742f9465752e	2026-06-04 19:47:29.629335
1	f2b9a571-ea53-4e7e-9b5d-b3d509efea57	\\x80049563000000000000007d94288c0a5f7065726d616e656e7494888c065f667265736894898c0a637372665f746f6b656e948c2865633264343065366561353838323931353931383339363631336138316566343266376338376363948c066c6f63616c65948c02656e94752e	2026-06-04 19:23:39.738209
\.


--
-- Data for Name: sla_miss; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sla_miss (task_id, dag_id, execution_date, email_sent, "timestamp", description, notification_sent) FROM stdin;
\.


--
-- Data for Name: slot_pool; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.slot_pool (id, pool, slots, description, include_deferred) FROM stdin;
1	default_pool	128	Default pool	f
\.


--
-- Data for Name: task_fail; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_fail (id, task_id, dag_id, run_id, map_index, start_date, end_date, duration) FROM stdin;
1	create_warehouse_schema	customer_order_summary	scheduled__2026-05-04T00:00:00+00:00	-1	2026-05-05 19:25:06.86431+00	2026-05-05 19:25:07.576273+00	0
2	build_security_audit_report	security_audit_report	manual__2026-05-05T19:36:07.591062+00:00	-1	2026-05-05 19:36:12.045463+00	2026-05-05 19:36:12.71273+00	0
\.


--
-- Data for Name: task_instance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_instance (task_id, dag_id, run_id, map_index, start_date, end_date, duration, state, try_number, max_tries, hostname, unixname, job_id, pool, pool_slots, queue, priority_weight, operator, custom_operator_name, queued_dttm, queued_by_job_id, pid, executor, executor_config, updated_at, rendered_map_index, external_executor_id, trigger_id, trigger_timeout, next_method, next_kwargs, task_display_name) FROM stdin;
build_security_audit_report	security_audit_report	manual__2026-05-05T19:36:07.591062+00:00	-1	2026-05-05 19:41:14.15581+00	2026-05-05 19:41:15.014453+00	0.858643	success	2	1	487402b4e129	airflow	18	default_pool	1	default	1	PostgresOperator	\N	2026-05-05 19:41:13.278304+00	1	654	\N	\\x80057d942e	2026-05-05 19:41:15.04196+00	\N	\N	\N	\N	\N	\N	build_security_audit_report
create_warehouse_schema	customer_order_summary	manual__2026-05-05T19:25:05.574225+00:00	-1	2026-05-05 19:25:06.868121+00	2026-05-05 19:25:07.581242+00	0.713121	success	1	1	487402b4e129	airflow	2	default_pool	1	default	3	PostgresOperator	\N	2026-05-05 19:25:06.190171+00	1	359	\N	\\x80057d942e	2026-05-05 19:25:07.604334+00	\N	\N	\N	\N	\N	\N	create_warehouse_schema
refresh_warehouse	customer_order_summary	manual__2026-05-05T19:25:05.574225+00:00	-1	2026-05-05 19:25:08.814326+00	2026-05-05 19:25:09.392942+00	0.578616	success	1	1	487402b4e129	airflow	4	default_pool	1	default	2	PostgresOperator	\N	2026-05-05 19:25:08.357428+00	1	370	\N	\\x80057d942e	2026-05-05 19:25:09.419514+00	\N	\N	\N	\N	\N	\N	refresh_warehouse
build_customer_order_summary	customer_order_summary	manual__2026-05-05T19:25:05.574225+00:00	-1	2026-05-05 19:25:10.001522+00	2026-05-05 19:25:10.561635+00	0.560113	success	1	1	487402b4e129	airflow	5	default_pool	1	default	1	PostgresOperator	\N	2026-05-05 19:25:09.478624+00	1	377	\N	\\x80057d942e	2026-05-05 19:25:10.583746+00	\N	\N	\N	\N	\N	\N	build_customer_order_summary
create_warehouse_schema	customer_order_summary	manual__2026-05-05T19:27:36.525312+00:00	-1	2026-05-05 19:27:38.119814+00	2026-05-05 19:27:38.930838+00	0.811024	success	1	1	487402b4e129	airflow	6	default_pool	1	default	3	PostgresOperator	\N	2026-05-05 19:27:36.752932+00	1	414	\N	\\x80057d942e	2026-05-05 19:27:38.962609+00	\N	\N	\N	\N	\N	\N	create_warehouse_schema
create_warehouse_schema	customer_order_summary	scheduled__2026-05-04T00:00:00+00:00	-1	2026-05-05 19:30:08.867335+00	2026-05-05 19:30:09.462941+00	0.595606	success	2	1	487402b4e129	airflow	9	default_pool	1	default	3	PostgresOperator	\N	2026-05-05 19:30:08.3547+00	1	465	\N	\\x80057d942e	2026-05-05 19:30:09.487574+00	\N	\N	\N	\N	\N	\N	create_warehouse_schema
refresh_warehouse	customer_order_summary	manual__2026-05-05T19:27:36.525312+00:00	-1	2026-05-05 19:27:39.950036+00	2026-05-05 19:27:40.905973+00	0.955937	success	1	1	487402b4e129	airflow	7	default_pool	1	default	2	PostgresOperator	\N	2026-05-05 19:27:39.065484+00	1	421	\N	\\x80057d942e	2026-05-05 19:27:40.937871+00	\N	\N	\N	\N	\N	\N	refresh_warehouse
build_customer_order_summary	customer_order_summary	manual__2026-05-05T19:27:36.525312+00:00	-1	2026-05-05 19:27:41.957369+00	2026-05-05 19:27:42.627905+00	0.670536	success	1	1	487402b4e129	airflow	8	default_pool	1	default	1	PostgresOperator	\N	2026-05-05 19:27:41.279959+00	1	428	\N	\\x80057d942e	2026-05-05 19:27:42.65378+00	\N	\N	\N	\N	\N	\N	build_customer_order_summary
refresh_warehouse	customer_order_summary	scheduled__2026-05-04T00:00:00+00:00	-1	2026-05-05 19:30:10.261161+00	2026-05-05 19:30:10.886871+00	0.62571	success	1	1	487402b4e129	airflow	10	default_pool	1	default	2	PostgresOperator	\N	2026-05-05 19:30:09.762229+00	1	472	\N	\\x80057d942e	2026-05-05 19:30:10.911302+00	\N	\N	\N	\N	\N	\N	refresh_warehouse
build_customer_order_summary	customer_order_summary	scheduled__2026-05-04T00:00:00+00:00	-1	2026-05-05 19:30:12.4861+00	2026-05-05 19:30:13.101823+00	0.615723	success	1	1	487402b4e129	airflow	11	default_pool	1	default	1	PostgresOperator	\N	2026-05-05 19:30:11.9288+00	1	479	\N	\\x80057d942e	2026-05-05 19:30:13.126803+00	\N	\N	\N	\N	\N	\N	build_customer_order_summary
create_warehouse_schema	security_audit_report	manual__2026-05-05T19:36:07.591062+00:00	-1	2026-05-05 19:36:08.505356+00	2026-05-05 19:36:09.106081+00	0.600725	success	1	1	487402b4e129	airflow	12	default_pool	1	default	3	PostgresOperator	\N	2026-05-05 19:36:07.878048+00	1	556	\N	\\x80057d942e	2026-05-05 19:36:09.129206+00	\N	\N	\N	\N	\N	\N	create_warehouse_schema
create_warehouse_schema	security_audit_report	scheduled__2026-05-04T00:00:00+00:00	-1	2026-05-05 19:36:08.500703+00	2026-05-05 19:36:09.109018+00	0.608315	success	1	1	487402b4e129	airflow	13	default_pool	1	default	3	PostgresOperator	\N	2026-05-05 19:36:07.878048+00	1	555	\N	\\x80057d942e	2026-05-05 19:36:09.131511+00	\N	\N	\N	\N	\N	\N	create_warehouse_schema
refresh_warehouse	security_audit_report	manual__2026-05-05T19:36:07.591062+00:00	-1	2026-05-05 19:36:09.779975+00	2026-05-05 19:36:10.428835+00	0.64886	success	1	1	487402b4e129	airflow	15	default_pool	1	default	2	PostgresOperator	\N	2026-05-05 19:36:09.278203+00	1	570	\N	\\x80057d942e	2026-05-05 19:36:10.455419+00	\N	\N	\N	\N	\N	\N	refresh_warehouse
refresh_warehouse	security_audit_report	scheduled__2026-05-04T00:00:00+00:00	-1	2026-05-05 19:36:09.775173+00	2026-05-05 19:36:10.449074+00	0.673901	success	1	1	487402b4e129	airflow	14	default_pool	1	default	2	PostgresOperator	\N	2026-05-05 19:36:09.278203+00	1	569	\N	\\x80057d942e	2026-05-05 19:36:10.47138+00	\N	\N	\N	\N	\N	\N	refresh_warehouse
build_security_audit_report	security_audit_report	scheduled__2026-05-04T00:00:00+00:00	-1	2026-05-05 19:36:12.037472+00	2026-05-05 19:36:12.712547+00	0.675075	success	1	1	487402b4e129	airflow	16	default_pool	1	default	1	PostgresOperator	\N	2026-05-05 19:36:11.455504+00	1	583	\N	\\x80057d942e	2026-05-05 19:36:12.740894+00	\N	\N	\N	\N	\N	\N	build_security_audit_report
\.


--
-- Data for Name: task_instance_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_instance_history (id, task_id, dag_id, run_id, map_index, try_number, start_date, end_date, duration, state, max_tries, hostname, unixname, job_id, pool, pool_slots, queue, priority_weight, operator, custom_operator_name, queued_dttm, queued_by_job_id, pid, executor, executor_config, updated_at, rendered_map_index, external_executor_id, trigger_id, trigger_timeout, next_method, next_kwargs, task_display_name) FROM stdin;
1	create_warehouse_schema	customer_order_summary	scheduled__2026-05-04T00:00:00+00:00	-1	1	2026-05-05 19:25:06.86431+00	2026-05-05 19:25:07.581961+00	0.717651	failed	1	487402b4e129	airflow	3	default_pool	1	default	3	PostgresOperator	\N	2026-05-05 19:25:06.190171+00	1	360	\N	\\x80057d942e	2026-05-05 19:25:07.287176+00	\N	\N	\N	\N	\N	null	create_warehouse_schema
2	build_security_audit_report	security_audit_report	manual__2026-05-05T19:36:07.591062+00:00	-1	1	2026-05-05 19:36:12.045463+00	2026-05-05 19:36:12.718115+00	0.672652	failed	1	487402b4e129	airflow	17	default_pool	1	default	1	PostgresOperator	\N	2026-05-05 19:36:11.455504+00	1	584	\N	\\x80057d942e	2026-05-05 19:36:12.495815+00	\N	\N	\N	\N	\N	null	build_security_audit_report
\.


--
-- Data for Name: task_instance_note; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_instance_note (user_id, task_id, dag_id, run_id, map_index, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: task_map; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_map (dag_id, task_id, run_id, map_index, length, keys) FROM stdin;
\.


--
-- Data for Name: task_outlet_dataset_reference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_outlet_dataset_reference (dataset_id, dag_id, task_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: task_reschedule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_reschedule (id, task_id, dag_id, run_id, map_index, try_number, start_date, end_date, duration, reschedule_date) FROM stdin;
\.


--
-- Data for Name: trigger; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trigger (id, classpath, kwargs, created_date, triggerer_id) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_roles (user_id, role_id) FROM stdin;
1	1
2	2
3	3
\.


--
-- Data for Name: variable; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.variable (id, key, val, description, is_encrypted) FROM stdin;
\.


--
-- Data for Name: xcom; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.xcom (dag_run_id, task_id, map_index, key, dag_id, run_id, value, "timestamp") FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: staging; Owner: -
--

COPY staging.audit_logs (id, actor_email, action, resource_type, resource_id, details, created_at) FROM stdin;
1	\N	LOGIN_FAILED	auth	admin@ecommerce.local	email=a***@ecommerce.local; success=false; failureCode=INVALID_CREDENTIALS; correlationId=c0c0e03c-4478-422d-ae02-04fcc16bb69f	2026-05-05 17:33:23.596604+00
2	\N	LOGIN_SUCCESS	auth	employee@example.com	email=e***@example.com; success=true; failureCode=; correlationId=57bc54d6-4a7c-4c50-985f-50ec25f1a4ff	2026-05-05 17:33:30.667166+00
3	employee@example.com	PERMISSION_DENIED	http	/api/admin/products	method=GET; correlationId=180c3feb-0376-4275-bbc4-57df9d8b447f	2026-05-05 17:33:30.791421+00
4	employee@example.com	PERMISSION_DENIED	http	/api/admin/categories	method=GET; correlationId=25aaacee-d580-43f5-abb2-2d6735e801b1	2026-05-05 17:33:30.792134+00
5	employee@example.com	ORDER_CREATED	order	2	orderNumber=ORD-20260505173454-1778002494024; totalAmount=2713.8820; correlationId=5d63fec1-390f-4056-8639-0e8f2432ddc8	2026-05-05 17:34:54.022197+00
6	\N	LOGIN_SUCCESS	auth	employee@example.com	email=e***@example.com; success=true; failureCode=; correlationId=28d147a7-78f9-45a2-b007-f2a12f553d0c	2026-05-05 17:36:08.233583+00
7	employee@example.com	PERMISSION_DENIED	http	/api/admin/products	method=GET; correlationId=e8dd59f2-3e7e-4b60-aa35-9468f0cde27b	2026-05-05 17:36:08.282237+00
8	employee@example.com	PERMISSION_DENIED	http	/api/admin/categories	method=GET; correlationId=759421ab-2c41-49eb-8d1b-b2eba0a9c42d	2026-05-05 17:36:08.284541+00
9	\N	LOGIN_SUCCESS	auth	admin@example.com	email=a***@example.com; success=true; failureCode=; correlationId=de04384c-2b49-4252-a6b5-62343e1097ce	2026-05-05 17:36:23.865728+00
10	admin@example.com	ORDER_CREATED	order	3	orderNumber=ORD-20260505173852-1778002732252; totalAmount=5427.7640; correlationId=f8b8ae22-7dda-4a65-9992-f4f663612ee5	2026-05-05 17:38:52.249721+00
11	admin@example.com	ORDER_CREATED	order	4	orderNumber=ORD-20260505175519-1778003719399; totalAmount=1768.8200; correlationId=c21b7047-1a18-49bc-8ac4-e9fc07a942e3	2026-05-05 17:55:19.394437+00
12	\N	LOGIN_SUCCESS	auth	admin@example.com	email=a***@example.com; success=true; failureCode=; correlationId=18f4bca4-d264-491f-880f-0f90584e62d1	2026-05-05 19:31:38.219567+00
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: staging; Owner: -
--

COPY staging.order_items (id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total) FROM stdin;
1	1	2	Logitech MX Keys Mini	logitech-mx-keys-mini	2299.90	1	2299.90
2	2	2	Logitech MX Keys Mini	logitech-mx-keys-mini	2299.90	1	2299.90
3	3	2	Logitech MX Keys Mini	logitech-mx-keys-mini	2299.90	2	4599.80
4	4	3	Levi's 501 Original Jeans	levis-501-original-jeans	1499.00	1	1499.00
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: staging; Owner: -
--

COPY staging.orders (id, order_number, user_email, status, subtotal, shipping_cost, tax, total_amount, payment_method, payment_reference, created_at) FROM stdin;
1	ORD-20260504212512-1777929912355	admin@ecommerce.local	PAID	2299.90	0.00	413.98	2713.88	CARD	PAY-SIM-0000-1777929912356	2026-05-04 21:25:12.355173
2	ORD-20260505173454-1778002494024	employee@example.com	PAID	2299.90	0.00	413.98	2713.88	CARD	PAY-SIM-3652-1778002494025	2026-05-05 17:34:54.024767
3	ORD-20260505173852-1778002732252	admin@example.com	PAID	4599.80	0.00	827.96	5427.76	CARD	PAY-SIM-2589-1778002732252	2026-05-05 17:38:52.251985
4	ORD-20260505175519-1778003719399	admin@example.com	PAID	1499.00	0.00	269.82	1768.82	CARD	PAY-SIM-2365-1778003719399	2026-05-05 17:55:19.399629
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: staging; Owner: -
--

COPY staging.products (id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at) FROM stdin;
1	1	Samsung Galaxy A55	samsung-galaxy-a55	12999.99	50	ACTIVE	\N	2026-05-04 21:15:04.131241
4	2	Nike Air Force 1 Beyaz	nike-air-force-1-beyaz	3299.00	45	ACTIVE	\N	2026-05-04 21:15:04.131241
5	3	Philips Hue Starter Kit	philips-hue-starter-kit	1899.00	20	ACTIVE	\N	2026-05-04 21:15:04.131241
6	3	Bambu Kesme Tahtası Seti	bambu-kesme-tahtasi-seti	349.90	60	ACTIVE	\N	2026-05-04 21:15:04.131241
7	4	Garmin Forerunner 265	garmin-forerunner-265	9999.00	15	ACTIVE	\N	2026-05-04 21:15:04.131241
8	4	Decathlon Yüzme Gözlüğü	decathlon-yuzme-gozlugu	129.90	100	ACTIVE	\N	2026-05-04 21:15:04.131241
9	5	Atomic Habits - James Clear	atomic-habits-james-clear	189.00	200	ACTIVE	\N	2026-05-04 21:15:04.131241
10	5	Rhodia A5 Defter	rhodia-a5-defter	229.00	75	ACTIVE	\N	2026-05-04 21:15:04.131241
11	6	CeraVe Nemlendirici Krem	cerave-nemlendirici-krem	389.90	90	ACTIVE	\N	2026-05-04 21:15:04.131241
12	6	The Ordinary Niacinamide 10%	the-ordinary-niacinamide	269.00	120	ACTIVE	\N	2026-05-04 21:15:04.131241
13	7	LEGO Technic Bugatti Chiron	lego-technic-bugatti-chiron	4299.00	10	ACTIVE	\N	2026-05-04 21:15:04.131241
14	7	Mega Bloks İlk İnşaatçım	mega-bloks-ilk-insaatcim	259.90	55	ACTIVE	\N	2026-05-04 21:15:04.131241
15	8	Organik Zeytinyağı 750ml	organik-zeytinyagi-750ml	449.00	40	ACTIVE	\N	2026-05-04 21:15:04.131241
16	8	Premium Karışık Kuruyemiş	premium-karisik-kuruyemis	299.90	65	ACTIVE	\N	2026-05-04 21:15:04.131241
17	9	Fiskars Bahçe Makası	fiskars-bahce-makasi	599.00	35	ACTIVE	\N	2026-05-04 21:15:04.131241
18	9	Akıllı Damla Sulama Seti	akilli-damla-sulama-seti	1299.00	25	ACTIVE	\N	2026-05-04 21:15:04.131241
19	10	Bosch S5 Akü 60Ah	bosch-s5-aku-60ah	2199.00	20	ACTIVE	\N	2026-05-04 21:15:04.131241
20	10	Michelin Pilot Sport 5 225/45R17	michelin-pilot-sport-5	3499.00	30	ACTIVE	\N	2026-05-04 21:15:04.131241
27	24	USB-C Productivity Dock	usb-c-productivity-dock	3499.90	35	ACTIVE	\N	2026-05-05 16:56:15.261656
28	24	Developer Laptop Pro 14	developer-laptop-pro-14	64999.90	12	ACTIVE	\N	2026-05-05 16:56:15.261656
29	25	Everyday Tech Hoodie	everyday-tech-hoodie	1499.90	48	ACTIVE	\N	2026-05-05 16:56:15.261656
30	26	Ergonomic Desk Lamp	ergonomic-desk-lamp	899.90	64	ACTIVE	\N	2026-05-05 16:56:15.261656
31	27	Smart Training Bottle	smart-training-bottle	699.90	80	ACTIVE	\N	2026-05-05 16:56:15.261656
2	1	Logitech MX Keys Mini	logitech-mx-keys-mini	2299.90	26	ACTIVE	2026-05-05 17:38:52.267735	2026-05-04 21:15:04.131241
3	2	Levi's 501 Original Jeans	levis-501-original-jeans	1499.00	79	ACTIVE	2026-05-05 17:55:19.4187	2026-05-04 21:15:04.131241
\.


--
-- Name: dim_customer_customer_key_seq; Type: SEQUENCE SET; Schema: dw; Owner: -
--

SELECT pg_catalog.setval('dw.dim_customer_customer_key_seq', 15, true);


--
-- Name: dim_product_product_key_seq; Type: SEQUENCE SET; Schema: dw; Owner: -
--

SELECT pg_catalog.setval('dw.dim_product_product_key_seq', 125, true);


--
-- Name: ab_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_permission_id_seq', 5, true);


--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 127, true);


--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 224, true);


--
-- Name: ab_register_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_register_user_id_seq', 1, false);


--
-- Name: ab_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_role_id_seq', 5, true);


--
-- Name: ab_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_user_id_seq', 1, true);


--
-- Name: ab_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_user_role_id_seq', 1, true);


--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 63, true);


--
-- Name: app_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.app_user_id_seq', 3, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 13, true);


--
-- Name: callback_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.callback_request_id_seq', 1, false);


--
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 7, true);


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.category_id_seq', 27, true);


--
-- Name: connection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.connection_id_seq', 1, true);


--
-- Name: customer_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_order_items_id_seq', 5, true);


--
-- Name: customer_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_orders_id_seq', 5, true);


--
-- Name: dag_pickle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dag_pickle_id_seq', 1, false);


--
-- Name: dag_run_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dag_run_id_seq', 5, true);


--
-- Name: dataset_alias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dataset_alias_id_seq', 1, false);


--
-- Name: dataset_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dataset_event_id_seq', 1, false);


--
-- Name: dataset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dataset_id_seq', 1, false);


--
-- Name: import_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.import_error_id_seq', 1, false);


--
-- Name: job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.job_id_seq', 18, true);


--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.log_id_seq', 78, true);


--
-- Name: log_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.log_template_id_seq', 2, true);


--
-- Name: login_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.login_attempts_id_seq', 5, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 1, false);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permissions_id_seq', 17, true);


--
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_images_id_seq', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 31, true);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 4, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.session_id_seq', 2, true);


--
-- Name: slot_pool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.slot_pool_id_seq', 1, true);


--
-- Name: task_fail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.task_fail_id_seq', 2, true);


--
-- Name: task_instance_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.task_instance_history_id_seq', 2, true);


--
-- Name: task_reschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.task_reschedule_id_seq', 1, false);


--
-- Name: trigger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.trigger_id_seq', 1, false);


--
-- Name: variable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.variable_id_seq', 1, false);


--
-- Name: dim_customer dim_customer_email_key; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.dim_customer
    ADD CONSTRAINT dim_customer_email_key UNIQUE (email);


--
-- Name: dim_customer dim_customer_pkey; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.dim_customer
    ADD CONSTRAINT dim_customer_pkey PRIMARY KEY (customer_key);


--
-- Name: dim_date dim_date_pkey; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.dim_date
    ADD CONSTRAINT dim_date_pkey PRIMARY KEY (date_key);


--
-- Name: dim_product dim_product_pkey; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.dim_product
    ADD CONSTRAINT dim_product_pkey PRIMARY KEY (product_key);


--
-- Name: dim_product dim_product_product_id_key; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.dim_product
    ADD CONSTRAINT dim_product_product_id_key UNIQUE (product_id);


--
-- Name: fact_inventory fact_inventory_pkey; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_inventory
    ADD CONSTRAINT fact_inventory_pkey PRIMARY KEY (product_id);


--
-- Name: fact_orders fact_orders_pkey; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_orders
    ADD CONSTRAINT fact_orders_pkey PRIMARY KEY (order_id);


--
-- Name: fact_payments fact_payments_pkey; Type: CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_payments
    ADD CONSTRAINT fact_payments_pkey PRIMARY KEY (payment_reference);


--
-- Name: ab_permission ab_permission_name_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_uq UNIQUE (name);


--
-- Name: ab_permission ab_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);


--
-- Name: ab_permission_view ab_permission_view_permission_id_view_menu_id_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_uq UNIQUE (permission_id, view_menu_id);


--
-- Name: ab_permission_view ab_permission_view_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);


--
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_uq UNIQUE (permission_view_id, role_id);


--
-- Name: ab_permission_view_role ab_permission_view_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);


--
-- Name: ab_register_user ab_register_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);


--
-- Name: ab_register_user ab_register_user_username_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_uq UNIQUE (username);


--
-- Name: ab_role ab_role_name_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_uq UNIQUE (name);


--
-- Name: ab_role ab_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);


--
-- Name: ab_user ab_user_email_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_uq UNIQUE (email);


--
-- Name: ab_user ab_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);


--
-- Name: ab_user_role ab_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);


--
-- Name: ab_user_role ab_user_role_user_id_role_id_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_uq UNIQUE (user_id, role_id);


--
-- Name: ab_user ab_user_username_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_uq UNIQUE (username);


--
-- Name: ab_view_menu ab_view_menu_name_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_uq UNIQUE (name);


--
-- Name: ab_view_menu ab_view_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: callback_request callback_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.callback_request
    ADD CONSTRAINT callback_request_pkey PRIMARY KEY (id);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: connection connection_conn_id_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connection
    ADD CONSTRAINT connection_conn_id_uq UNIQUE (conn_id);


--
-- Name: connection connection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connection
    ADD CONSTRAINT connection_pkey PRIMARY KEY (id);


--
-- Name: customer_order_items customer_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_items
    ADD CONSTRAINT customer_order_items_pkey PRIMARY KEY (id);


--
-- Name: customer_orders customer_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT customer_orders_pkey PRIMARY KEY (id);


--
-- Name: dag_code dag_code_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_code
    ADD CONSTRAINT dag_code_pkey PRIMARY KEY (fileloc_hash);


--
-- Name: dag_owner_attributes dag_owner_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_owner_attributes
    ADD CONSTRAINT dag_owner_attributes_pkey PRIMARY KEY (dag_id, owner);


--
-- Name: dag_pickle dag_pickle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_pickle
    ADD CONSTRAINT dag_pickle_pkey PRIMARY KEY (id);


--
-- Name: dag dag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag
    ADD CONSTRAINT dag_pkey PRIMARY KEY (dag_id);


--
-- Name: dag_priority_parsing_request dag_priority_parsing_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_priority_parsing_request
    ADD CONSTRAINT dag_priority_parsing_request_pkey PRIMARY KEY (id);


--
-- Name: dag_run dag_run_dag_id_execution_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_dag_id_execution_date_key UNIQUE (dag_id, execution_date);


--
-- Name: dag_run dag_run_dag_id_run_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_dag_id_run_id_key UNIQUE (dag_id, run_id);


--
-- Name: dag_run_note dag_run_note_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_pkey PRIMARY KEY (dag_run_id);


--
-- Name: dag_run dag_run_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_pkey PRIMARY KEY (id);


--
-- Name: dag_tag dag_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_tag
    ADD CONSTRAINT dag_tag_pkey PRIMARY KEY (name, dag_id);


--
-- Name: dag_warning dag_warning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_warning
    ADD CONSTRAINT dag_warning_pkey PRIMARY KEY (dag_id, warning_type);


--
-- Name: dagrun_dataset_event dagrun_dataset_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_pkey PRIMARY KEY (dag_run_id, event_id);


--
-- Name: dataset_alias_dataset_event dataset_alias_dataset_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset_event
    ADD CONSTRAINT dataset_alias_dataset_event_pkey PRIMARY KEY (alias_id, event_id);


--
-- Name: dataset_alias_dataset dataset_alias_dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset
    ADD CONSTRAINT dataset_alias_dataset_pkey PRIMARY KEY (alias_id, dataset_id);


--
-- Name: dataset_alias dataset_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias
    ADD CONSTRAINT dataset_alias_pkey PRIMARY KEY (id);


--
-- Name: dataset_event dataset_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_event
    ADD CONSTRAINT dataset_event_pkey PRIMARY KEY (id);


--
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- Name: dataset_dag_run_queue datasetdagrunqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT datasetdagrunqueue_pkey PRIMARY KEY (dataset_id, target_dag_id);


--
-- Name: dag_schedule_dataset_alias_reference dsdar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_schedule_dataset_alias_reference
    ADD CONSTRAINT dsdar_pkey PRIMARY KEY (alias_id, dag_id);


--
-- Name: dag_schedule_dataset_reference dsdr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_pkey PRIMARY KEY (dataset_id, dag_id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: import_error import_error_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_error
    ADD CONSTRAINT import_error_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: log_template log_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_template
    ADD CONSTRAINT log_template_pkey PRIMARY KEY (id);


--
-- Name: login_attempts login_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (id);


--
-- Name: payments payments_payment_reference_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_reference_key UNIQUE (payment_reference);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_name_key UNIQUE (name);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: rendered_task_instance_fields rendered_task_instance_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendered_task_instance_fields
    ADD CONSTRAINT rendered_task_instance_fields_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: serialized_dag serialized_dag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serialized_dag
    ADD CONSTRAINT serialized_dag_pkey PRIMARY KEY (dag_id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: session session_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_session_id_key UNIQUE (session_id);


--
-- Name: sla_miss sla_miss_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sla_miss
    ADD CONSTRAINT sla_miss_pkey PRIMARY KEY (task_id, dag_id, execution_date);


--
-- Name: slot_pool slot_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slot_pool
    ADD CONSTRAINT slot_pool_pkey PRIMARY KEY (id);


--
-- Name: slot_pool slot_pool_pool_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slot_pool
    ADD CONSTRAINT slot_pool_pool_uq UNIQUE (pool);


--
-- Name: task_fail task_fail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_fail
    ADD CONSTRAINT task_fail_pkey PRIMARY KEY (id);


--
-- Name: task_instance_history task_instance_history_dtrt_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance_history
    ADD CONSTRAINT task_instance_history_dtrt_uq UNIQUE (dag_id, task_id, run_id, map_index, try_number);


--
-- Name: task_instance_history task_instance_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance_history
    ADD CONSTRAINT task_instance_history_pkey PRIMARY KEY (id);


--
-- Name: task_instance_note task_instance_note_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_pkey PRIMARY KEY (task_id, dag_id, run_id, map_index);


--
-- Name: task_instance task_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: task_map task_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_map
    ADD CONSTRAINT task_map_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: task_reschedule task_reschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_pkey PRIMARY KEY (id);


--
-- Name: task_outlet_dataset_reference todr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_pkey PRIMARY KEY (dataset_id, dag_id, task_id);


--
-- Name: trigger trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trigger
    ADD CONSTRAINT trigger_pkey PRIMARY KEY (id);


--
-- Name: app_user uk1j9d9a06i600gd43uu3km82jw; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT uk1j9d9a06i600gd43uu3km82jw UNIQUE (email);


--
-- Name: category uk46ccwnsi9409t36lurvtyljak; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT uk46ccwnsi9409t36lurvtyljak UNIQUE (name);


--
-- Name: cart_items uk_cart_user_product; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT uk_cart_user_product UNIQUE (user_email, product_id);


--
-- Name: products uk_product_category_slug; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT uk_product_category_slug UNIQUE (category_id, slug);


--
-- Name: category ukhqknmjh5423vchi4xkyhxlhg2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT ukhqknmjh5423vchi4xkyhxlhg2 UNIQUE (slug);


--
-- Name: customer_orders uks4wt1sgd48rj6cgahwlksogx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT uks4wt1sgd48rj6cgahwlksogx UNIQUE (order_number);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: variable variable_key_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_key_uq UNIQUE (key);


--
-- Name: variable variable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_pkey PRIMARY KEY (id);


--
-- Name: xcom xcom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xcom
    ADD CONSTRAINT xcom_pkey PRIMARY KEY (dag_run_id, task_id, map_index, key);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: dag_id_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dag_id_state ON public.dag_run USING btree (dag_id, state);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: idx_ab_register_user_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_ab_register_user_username ON public.ab_register_user USING btree (lower((username)::text));


--
-- Name: idx_ab_user_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_ab_user_username ON public.ab_user USING btree (lower((username)::text));


--
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- Name: idx_app_user_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_user_role ON public.app_user USING btree (role);


--
-- Name: idx_audit_logs_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_action ON public.audit_logs USING btree (action);


--
-- Name: idx_audit_logs_actor_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_actor_user_id ON public.audit_logs USING btree (actor_user_id);


--
-- Name: idx_audit_logs_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_created_at ON public.audit_logs USING btree (created_at);


--
-- Name: idx_cart_items_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cart_items_product_id ON public.cart_items USING btree (product_id);


--
-- Name: idx_cart_items_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cart_items_user_email ON public.cart_items USING btree (user_email);


--
-- Name: idx_customer_order_items_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_order_items_order_id ON public.customer_order_items USING btree (order_id);


--
-- Name: idx_customer_order_items_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_order_items_product_id ON public.customer_order_items USING btree (product_id);


--
-- Name: idx_customer_orders_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_orders_created_at ON public.customer_orders USING btree (created_at);


--
-- Name: idx_customer_orders_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_orders_status ON public.customer_orders USING btree (status);


--
-- Name: idx_customer_orders_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_orders_user_email ON public.customer_orders USING btree (user_email);


--
-- Name: idx_dag_run_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dag_run_dag_id ON public.dag_run USING btree (dag_id);


--
-- Name: idx_dag_run_queued_dags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dag_run_queued_dags ON public.dag_run USING btree (state, dag_id) WHERE ((state)::text = 'queued'::text);


--
-- Name: idx_dag_run_running_dags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dag_run_running_dags ON public.dag_run USING btree (state, dag_id) WHERE ((state)::text = 'running'::text);


--
-- Name: idx_dag_schedule_dataset_alias_reference_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dag_schedule_dataset_alias_reference_dag_id ON public.dag_schedule_dataset_alias_reference USING btree (dag_id);


--
-- Name: idx_dag_schedule_dataset_reference_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dag_schedule_dataset_reference_dag_id ON public.dag_schedule_dataset_reference USING btree (dag_id);


--
-- Name: idx_dag_tag_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dag_tag_dag_id ON public.dag_tag USING btree (dag_id);


--
-- Name: idx_dag_warning_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dag_warning_dag_id ON public.dag_warning USING btree (dag_id);


--
-- Name: idx_dagrun_dataset_events_dag_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dagrun_dataset_events_dag_run_id ON public.dagrun_dataset_event USING btree (dag_run_id);


--
-- Name: idx_dagrun_dataset_events_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dagrun_dataset_events_event_id ON public.dagrun_dataset_event USING btree (event_id);


--
-- Name: idx_dataset_alias_dataset_alias_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dataset_alias_dataset_alias_dataset_id ON public.dataset_alias_dataset USING btree (dataset_id);


--
-- Name: idx_dataset_alias_dataset_alias_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dataset_alias_dataset_alias_id ON public.dataset_alias_dataset USING btree (alias_id);


--
-- Name: idx_dataset_alias_dataset_event_alias_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dataset_alias_dataset_event_alias_id ON public.dataset_alias_dataset_event USING btree (alias_id);


--
-- Name: idx_dataset_alias_dataset_event_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dataset_alias_dataset_event_event_id ON public.dataset_alias_dataset_event USING btree (event_id);


--
-- Name: idx_dataset_dag_run_queue_target_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dataset_dag_run_queue_target_dag_id ON public.dataset_dag_run_queue USING btree (target_dag_id);


--
-- Name: idx_dataset_id_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dataset_id_timestamp ON public.dataset_event USING btree (dataset_id, "timestamp");


--
-- Name: idx_fileloc_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileloc_hash ON public.serialized_dag USING btree (fileloc_hash);


--
-- Name: idx_job_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_job_dag_id ON public.job USING btree (dag_id);


--
-- Name: idx_job_state_heartbeat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_job_state_heartbeat ON public.job USING btree (state, latest_heartbeat);


--
-- Name: idx_log_dag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_dag ON public.log USING btree (dag_id);


--
-- Name: idx_log_dttm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_dttm ON public.log USING btree (dttm);


--
-- Name: idx_log_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_event ON public.log USING btree (event);


--
-- Name: idx_log_task_instance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_task_instance ON public.log USING btree (dag_id, task_id, run_id, map_index, try_number);


--
-- Name: idx_login_attempts_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_login_attempts_created_at ON public.login_attempts USING btree (created_at);


--
-- Name: idx_login_attempts_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_login_attempts_email ON public.login_attempts USING btree (email);


--
-- Name: idx_login_attempts_success; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_login_attempts_success ON public.login_attempts USING btree (success);


--
-- Name: idx_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_name_unique ON public.dataset_alias USING btree (name);


--
-- Name: idx_next_dagrun_create_after; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_next_dagrun_create_after ON public.dag USING btree (next_dagrun_create_after);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_order_id ON public.payments USING btree (order_id);


--
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- Name: idx_product_images_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_images_product_id ON public.product_images USING btree (product_id);


--
-- Name: idx_products_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_category_id ON public.products USING btree (category_id);


--
-- Name: idx_products_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_status ON public.products USING btree (status);


--
-- Name: idx_refresh_tokens_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refresh_tokens_expires_at ON public.refresh_tokens USING btree (expires_at);


--
-- Name: idx_refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refresh_tokens_user_id ON public.refresh_tokens USING btree (user_id);


--
-- Name: idx_root_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_root_dag_id ON public.dag USING btree (root_dag_id);


--
-- Name: idx_task_fail_task_instance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_fail_task_instance ON public.task_fail USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: idx_task_outlet_dataset_reference_dag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_outlet_dataset_reference_dag_id ON public.task_outlet_dataset_reference USING btree (dag_id);


--
-- Name: idx_task_reschedule_dag_run; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_reschedule_dag_run ON public.task_reschedule USING btree (dag_id, run_id);


--
-- Name: idx_task_reschedule_dag_task_run; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_reschedule_dag_task_run ON public.task_reschedule USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: idx_uri_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_uri_unique ON public.dataset USING btree (uri);


--
-- Name: idx_xcom_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_xcom_key ON public.xcom USING btree (key);


--
-- Name: idx_xcom_task_instance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_xcom_task_instance ON public.xcom USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: job_type_heart; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_type_heart ON public.job USING btree (job_type, latest_heartbeat);


--
-- Name: sm_dag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sm_dag ON public.sla_miss USING btree (dag_id);


--
-- Name: ti_dag_run; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ti_dag_run ON public.task_instance USING btree (dag_id, run_id);


--
-- Name: ti_dag_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ti_dag_state ON public.task_instance USING btree (dag_id, state);


--
-- Name: ti_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ti_job_id ON public.task_instance USING btree (job_id);


--
-- Name: ti_pool; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ti_pool ON public.task_instance USING btree (pool, state, priority_weight);


--
-- Name: ti_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ti_state ON public.task_instance USING btree (state);


--
-- Name: ti_state_lkp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ti_state_lkp ON public.task_instance USING btree (dag_id, task_id, run_id, state);


--
-- Name: ti_trigger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ti_trigger_id ON public.task_instance USING btree (trigger_id);


--
-- Name: fact_inventory fact_inventory_product_key_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_inventory
    ADD CONSTRAINT fact_inventory_product_key_fkey FOREIGN KEY (product_key) REFERENCES dw.dim_product(product_key);


--
-- Name: fact_orders fact_orders_customer_key_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_orders
    ADD CONSTRAINT fact_orders_customer_key_fkey FOREIGN KEY (customer_key) REFERENCES dw.dim_customer(customer_key);


--
-- Name: fact_orders fact_orders_date_key_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_orders
    ADD CONSTRAINT fact_orders_date_key_fkey FOREIGN KEY (date_key) REFERENCES dw.dim_date(date_key);


--
-- Name: fact_payments fact_payments_date_key_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_payments
    ADD CONSTRAINT fact_payments_date_key_fkey FOREIGN KEY (date_key) REFERENCES dw.dim_date(date_key);


--
-- Name: fact_payments fact_payments_order_id_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: -
--

ALTER TABLE ONLY dw.fact_payments
    ADD CONSTRAINT fact_payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES dw.fact_orders(order_id);


--
-- Name: ab_permission_view ab_permission_view_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);


--
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);


--
-- Name: ab_permission_view_role ab_permission_view_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- Name: ab_permission_view ab_permission_view_view_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_view_menu_id_fkey FOREIGN KEY (view_menu_id) REFERENCES public.ab_view_menu(id);


--
-- Name: ab_user ab_user_changed_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);


--
-- Name: ab_user ab_user_created_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);


--
-- Name: ab_user_role ab_user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- Name: ab_user_role ab_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: audit_logs audit_logs_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- Name: dag_owner_attributes dag.dag_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_owner_attributes
    ADD CONSTRAINT "dag.dag_id" FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dag_run_note dag_run_note_dr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_dr_fkey FOREIGN KEY (dag_run_id) REFERENCES public.dag_run(id) ON DELETE CASCADE;


--
-- Name: dag_run_note dag_run_note_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_user_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: dag_tag dag_tag_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_tag
    ADD CONSTRAINT dag_tag_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dagrun_dataset_event dagrun_dataset_event_dag_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_dag_run_id_fkey FOREIGN KEY (dag_run_id) REFERENCES public.dag_run(id) ON DELETE CASCADE;


--
-- Name: dagrun_dataset_event dagrun_dataset_event_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.dataset_event(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset dataset_alias_dataset_alias_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset
    ADD CONSTRAINT dataset_alias_dataset_alias_id_fkey FOREIGN KEY (alias_id) REFERENCES public.dataset_alias(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset dataset_alias_dataset_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset
    ADD CONSTRAINT dataset_alias_dataset_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset_event dataset_alias_dataset_event_alias_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset_event
    ADD CONSTRAINT dataset_alias_dataset_event_alias_id_fkey FOREIGN KEY (alias_id) REFERENCES public.dataset_alias(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset_event dataset_alias_dataset_event_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset_event
    ADD CONSTRAINT dataset_alias_dataset_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.dataset_event(id) ON DELETE CASCADE;


--
-- Name: dag_warning dcw_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_warning
    ADD CONSTRAINT dcw_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dataset_dag_run_queue ddrq_dag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT ddrq_dag_fkey FOREIGN KEY (target_dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dataset_dag_run_queue ddrq_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT ddrq_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset ds_dsa_alias_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset
    ADD CONSTRAINT ds_dsa_alias_id FOREIGN KEY (alias_id) REFERENCES public.dataset_alias(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset ds_dsa_dataset_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset
    ADD CONSTRAINT ds_dsa_dataset_id FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_alias_reference dsdar_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_schedule_dataset_alias_reference
    ADD CONSTRAINT dsdar_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_alias_reference dsdar_dataset_alias_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_schedule_dataset_alias_reference
    ADD CONSTRAINT dsdar_dataset_alias_fkey FOREIGN KEY (alias_id) REFERENCES public.dataset_alias(id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_reference dsdr_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_reference dsdr_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset_event dss_de_alias_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset_event
    ADD CONSTRAINT dss_de_alias_id FOREIGN KEY (alias_id) REFERENCES public.dataset_alias(id) ON DELETE CASCADE;


--
-- Name: dataset_alias_dataset_event dss_de_event_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_alias_dataset_event
    ADD CONSTRAINT dss_de_event_id FOREIGN KEY (event_id) REFERENCES public.dataset_event(id) ON DELETE CASCADE;


--
-- Name: products fk1cf90etcu98x1e6n9aks3tel3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk1cf90etcu98x1e6n9aks3tel3 FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- Name: cart_items fk1re40cjegsfvw58xrkdp6bac6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT fk1re40cjegsfvw58xrkdp6bac6 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: customer_order_items fkb8kd4gu1fg8jg69ks4osgyxdv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_items
    ADD CONSTRAINT fkb8kd4gu1fg8jg69ks4osgyxdv FOREIGN KEY (order_id) REFERENCES public.customer_orders(id);


--
-- Name: customer_order_items fkop6tb1apto95njcywn6oy8avo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_items
    ADD CONSTRAINT fkop6tb1apto95njcywn6oy8avo FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: product_images fkqnq71xsohugpqwf3c9gxmsuy; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT fkqnq71xsohugpqwf3c9gxmsuy FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.customer_orders(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: rendered_task_instance_fields rtif_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendered_task_instance_fields
    ADD CONSTRAINT rtif_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_fail task_fail_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_fail
    ADD CONSTRAINT task_fail_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_instance task_instance_dag_run_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_dag_run_fkey FOREIGN KEY (dag_id, run_id) REFERENCES public.dag_run(dag_id, run_id) ON DELETE CASCADE;


--
-- Name: task_instance_history task_instance_history_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance_history
    ADD CONSTRAINT task_instance_history_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dag_run task_instance_log_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT task_instance_log_template_id_fkey FOREIGN KEY (log_template_id) REFERENCES public.log_template(id);


--
-- Name: task_instance_note task_instance_note_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_instance_note task_instance_note_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_user_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: task_instance task_instance_trigger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_trigger_id_fkey FOREIGN KEY (trigger_id) REFERENCES public.trigger(id) ON DELETE CASCADE;


--
-- Name: task_map task_map_task_instance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_map
    ADD CONSTRAINT task_map_task_instance_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_reschedule task_reschedule_dr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_dr_fkey FOREIGN KEY (dag_id, run_id) REFERENCES public.dag_run(dag_id, run_id) ON DELETE CASCADE;


--
-- Name: task_reschedule task_reschedule_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_outlet_dataset_reference todr_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: task_outlet_dataset_reference todr_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: xcom xcom_task_instance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xcom
    ADD CONSTRAINT xcom_task_instance_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 6eUgHkO7PZTDvJRhTOhWHfx6WpbpNWPA6rrqdKziwQ5Y85Rdhymh8sV0g73Mgr0

