--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: mediawiki; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA mediawiki;


ALTER SCHEMA mediawiki OWNER TO postgres;

--
-- Name: media_type; Type: TYPE; Schema: mediawiki; Owner: postgres
--

CREATE TYPE mediawiki.media_type AS ENUM (
    'UNKNOWN',
    'BITMAP',
    'DRAWING',
    'AUDIO',
    'VIDEO',
    'MULTIMEDIA',
    'OFFICE',
    'TEXT',
    'EXECUTABLE',
    'ARCHIVE',
    '3D'
);


ALTER TYPE mediawiki.media_type OWNER TO postgres;

--
-- Name: add_interwiki(text, integer, smallint); Type: FUNCTION; Schema: mediawiki; Owner: postgres
--

CREATE FUNCTION mediawiki.add_interwiki(text, integer, smallint) RETURNS integer
    LANGUAGE sql
    AS $_$
 INSERT INTO interwiki (iw_prefix, iw_url, iw_local) VALUES ($1,$2,$3);
 SELECT 1;
 $_$;


ALTER FUNCTION mediawiki.add_interwiki(text, integer, smallint) OWNER TO postgres;

--
-- Name: page_deleted(); Type: FUNCTION; Schema: mediawiki; Owner: postgres
--

CREATE FUNCTION mediawiki.page_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
 BEGIN
 DELETE FROM recentchanges WHERE rc_namespace = OLD.page_namespace AND rc_title = OLD.page_title;
 RETURN NULL;
 END;
 $$;


ALTER FUNCTION mediawiki.page_deleted() OWNER TO postgres;

--
-- Name: ts2_page_text(); Type: FUNCTION; Schema: mediawiki; Owner: postgres
--

CREATE FUNCTION mediawiki.ts2_page_text() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
 BEGIN
 IF TG_OP = 'INSERT' THEN
 NEW.textvector = to_tsvector(NEW.old_text);
 ELSIF NEW.old_text != OLD.old_text THEN
 NEW.textvector := to_tsvector(NEW.old_text);
 END IF;
 RETURN NEW;
 END;
 $$;


ALTER FUNCTION mediawiki.ts2_page_text() OWNER TO postgres;

--
-- Name: ts2_page_title(); Type: FUNCTION; Schema: mediawiki; Owner: postgres
--

CREATE FUNCTION mediawiki.ts2_page_title() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
 BEGIN
 IF TG_OP = 'INSERT' THEN
 NEW.titlevector = to_tsvector(REPLACE(NEW.page_title,'/',' '));
 ELSIF NEW.page_title != OLD.page_title THEN
 NEW.titlevector := to_tsvector(REPLACE(NEW.page_title,'/',' '));
 END IF;
 RETURN NEW;
 END;
 $$;


ALTER FUNCTION mediawiki.ts2_page_title() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actor; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.actor (
    actor_id bigint NOT NULL,
    actor_user integer,
    actor_name text NOT NULL
);


ALTER TABLE mediawiki.actor OWNER TO postgres;

--
-- Name: actor_actor_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.actor_actor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.actor_actor_id_seq OWNER TO postgres;

--
-- Name: actor_actor_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.actor_actor_id_seq OWNED BY mediawiki.actor.actor_id;


--
-- Name: archive; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.archive (
    ar_id integer NOT NULL,
    ar_namespace smallint NOT NULL,
    ar_title text NOT NULL,
    ar_page_id integer,
    ar_parent_id integer,
    ar_sha1 text DEFAULT ''::text NOT NULL,
    ar_comment_id integer NOT NULL,
    ar_actor integer NOT NULL,
    ar_timestamp timestamp with time zone NOT NULL,
    ar_minor_edit smallint DEFAULT 0 NOT NULL,
    ar_rev_id integer NOT NULL,
    ar_deleted smallint DEFAULT 0 NOT NULL,
    ar_len integer
);


ALTER TABLE mediawiki.archive OWNER TO postgres;

--
-- Name: archive_ar_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.archive_ar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.archive_ar_id_seq OWNER TO postgres;

--
-- Name: archive_ar_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.archive_ar_id_seq OWNED BY mediawiki.archive.ar_id;


--
-- Name: bot_passwords; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.bot_passwords (
    bp_user integer NOT NULL,
    bp_app_id text NOT NULL,
    bp_password text NOT NULL,
    bp_token text NOT NULL,
    bp_restrictions text NOT NULL,
    bp_grants text NOT NULL
);


ALTER TABLE mediawiki.bot_passwords OWNER TO postgres;

--
-- Name: category; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.category (
    cat_id integer NOT NULL,
    cat_title text NOT NULL,
    cat_pages integer DEFAULT 0 NOT NULL,
    cat_subcats integer DEFAULT 0 NOT NULL,
    cat_files integer DEFAULT 0 NOT NULL
);


ALTER TABLE mediawiki.category OWNER TO postgres;

--
-- Name: category_cat_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.category_cat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.category_cat_id_seq OWNER TO postgres;

--
-- Name: category_cat_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.category_cat_id_seq OWNED BY mediawiki.category.cat_id;


--
-- Name: categorylinks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.categorylinks (
    cl_from integer NOT NULL,
    cl_to text NOT NULL,
    cl_sortkey text,
    cl_timestamp timestamp with time zone NOT NULL,
    cl_sortkey_prefix text DEFAULT ''::text NOT NULL,
    cl_collation text DEFAULT 0 NOT NULL,
    cl_type text DEFAULT 'page'::text NOT NULL
);


ALTER TABLE mediawiki.categorylinks OWNER TO postgres;

--
-- Name: change_tag; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.change_tag (
    ct_id integer NOT NULL,
    ct_rc_id integer,
    ct_log_id integer,
    ct_rev_id integer,
    ct_params text,
    ct_tag_id integer NOT NULL
);


ALTER TABLE mediawiki.change_tag OWNER TO postgres;

--
-- Name: change_tag_ct_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.change_tag_ct_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.change_tag_ct_id_seq OWNER TO postgres;

--
-- Name: change_tag_ct_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.change_tag_ct_id_seq OWNED BY mediawiki.change_tag.ct_id;


--
-- Name: change_tag_def; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.change_tag_def (
    ctd_id integer NOT NULL,
    ctd_name text NOT NULL,
    ctd_user_defined smallint DEFAULT 0 NOT NULL,
    ctd_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE mediawiki.change_tag_def OWNER TO postgres;

--
-- Name: change_tag_def_ctd_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.change_tag_def_ctd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.change_tag_def_ctd_id_seq OWNER TO postgres;

--
-- Name: change_tag_def_ctd_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.change_tag_def_ctd_id_seq OWNED BY mediawiki.change_tag_def.ctd_id;


--
-- Name: comment; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.comment (
    comment_id integer NOT NULL,
    comment_hash integer NOT NULL,
    comment_text text NOT NULL,
    comment_data text
);


ALTER TABLE mediawiki.comment OWNER TO postgres;

--
-- Name: comment_comment_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.comment_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.comment_comment_id_seq OWNER TO postgres;

--
-- Name: comment_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.comment_comment_id_seq OWNED BY mediawiki.comment.comment_id;


--
-- Name: content; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.content (
    content_id integer NOT NULL,
    content_size integer NOT NULL,
    content_sha1 text NOT NULL,
    content_model smallint NOT NULL,
    content_address text NOT NULL
);


ALTER TABLE mediawiki.content OWNER TO postgres;

--
-- Name: content_content_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.content_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.content_content_id_seq OWNER TO postgres;

--
-- Name: content_content_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.content_content_id_seq OWNED BY mediawiki.content.content_id;


--
-- Name: content_models; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.content_models (
    model_id smallint NOT NULL,
    model_name text NOT NULL
);


ALTER TABLE mediawiki.content_models OWNER TO postgres;

--
-- Name: content_models_model_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.content_models_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.content_models_model_id_seq OWNER TO postgres;

--
-- Name: content_models_model_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.content_models_model_id_seq OWNED BY mediawiki.content_models.model_id;


--
-- Name: externallinks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.externallinks (
    el_id integer NOT NULL,
    el_from integer NOT NULL,
    el_to text NOT NULL,
    el_index text NOT NULL,
    el_index_60 bytea NOT NULL
);


ALTER TABLE mediawiki.externallinks OWNER TO postgres;

--
-- Name: externallinks_el_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.externallinks_el_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.externallinks_el_id_seq OWNER TO postgres;

--
-- Name: externallinks_el_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.externallinks_el_id_seq OWNED BY mediawiki.externallinks.el_id;


--
-- Name: filearchive; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.filearchive (
    fa_id integer NOT NULL,
    fa_name text NOT NULL,
    fa_archive_name text,
    fa_storage_group text,
    fa_storage_key text,
    fa_deleted_user integer,
    fa_deleted_timestamp timestamp with time zone NOT NULL,
    fa_deleted_reason_id integer NOT NULL,
    fa_size integer NOT NULL,
    fa_width integer NOT NULL,
    fa_height integer NOT NULL,
    fa_metadata bytea DEFAULT '\x'::bytea NOT NULL,
    fa_bits smallint,
    fa_media_type text,
    fa_major_mime text DEFAULT 'unknown'::text,
    fa_minor_mime text DEFAULT 'unknown'::text,
    fa_description_id integer NOT NULL,
    fa_actor integer NOT NULL,
    fa_timestamp timestamp with time zone,
    fa_deleted smallint DEFAULT 0 NOT NULL,
    fa_sha1 text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.filearchive OWNER TO postgres;

--
-- Name: filearchive_fa_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.filearchive_fa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.filearchive_fa_id_seq OWNER TO postgres;

--
-- Name: filearchive_fa_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.filearchive_fa_id_seq OWNED BY mediawiki.filearchive.fa_id;


--
-- Name: image; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.image (
    img_name text NOT NULL,
    img_size integer NOT NULL,
    img_width integer NOT NULL,
    img_height integer NOT NULL,
    img_metadata bytea DEFAULT '\x'::bytea NOT NULL,
    img_bits smallint,
    img_media_type text,
    img_major_mime text DEFAULT 'unknown'::text,
    img_minor_mime text DEFAULT 'unknown'::text,
    img_description_id integer NOT NULL,
    img_actor integer NOT NULL,
    img_timestamp timestamp with time zone,
    img_sha1 text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.image OWNER TO postgres;

--
-- Name: imagelinks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.imagelinks (
    il_from integer NOT NULL,
    il_from_namespace integer DEFAULT 0 NOT NULL,
    il_to text NOT NULL
);


ALTER TABLE mediawiki.imagelinks OWNER TO postgres;

--
-- Name: interwiki; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.interwiki (
    iw_prefix text NOT NULL,
    iw_url text NOT NULL,
    iw_local smallint NOT NULL,
    iw_trans smallint DEFAULT 0 NOT NULL,
    iw_api text DEFAULT ''::text NOT NULL,
    iw_wikiid text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.interwiki OWNER TO postgres;

--
-- Name: ip_changes; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.ip_changes (
    ipc_rev_id integer NOT NULL,
    ipc_rev_timestamp timestamp with time zone NOT NULL,
    ipc_hex bytea DEFAULT '\x'::bytea NOT NULL
);


ALTER TABLE mediawiki.ip_changes OWNER TO postgres;

--
-- Name: ip_changes_ipc_rev_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.ip_changes_ipc_rev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.ip_changes_ipc_rev_id_seq OWNER TO postgres;

--
-- Name: ip_changes_ipc_rev_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.ip_changes_ipc_rev_id_seq OWNED BY mediawiki.ip_changes.ipc_rev_id;


--
-- Name: ipblocks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.ipblocks (
    ipb_id integer NOT NULL,
    ipb_address text,
    ipb_user integer,
    ipb_by_actor integer NOT NULL,
    ipb_reason_id integer NOT NULL,
    ipb_timestamp timestamp with time zone NOT NULL,
    ipb_auto smallint DEFAULT 0 NOT NULL,
    ipb_anon_only smallint DEFAULT 0 NOT NULL,
    ipb_create_account smallint DEFAULT 1 NOT NULL,
    ipb_enable_autoblock smallint DEFAULT 1 NOT NULL,
    ipb_expiry timestamp with time zone NOT NULL,
    ipb_range_start text,
    ipb_range_end text,
    ipb_deleted smallint DEFAULT 0 NOT NULL,
    ipb_block_email smallint DEFAULT 0 NOT NULL,
    ipb_allow_usertalk smallint DEFAULT 0 NOT NULL,
    ipb_parent_block_id integer,
    ipb_sitewide smallint DEFAULT 1 NOT NULL
);


ALTER TABLE mediawiki.ipblocks OWNER TO postgres;

--
-- Name: ipblocks_ipb_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.ipblocks_ipb_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.ipblocks_ipb_id_seq OWNER TO postgres;

--
-- Name: ipblocks_ipb_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.ipblocks_ipb_id_seq OWNED BY mediawiki.ipblocks.ipb_id;


--
-- Name: ipblocks_restrictions; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.ipblocks_restrictions (
    ir_ipb_id integer NOT NULL,
    ir_type smallint NOT NULL,
    ir_value integer NOT NULL
);


ALTER TABLE mediawiki.ipblocks_restrictions OWNER TO postgres;

--
-- Name: iwlinks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.iwlinks (
    iwl_from integer DEFAULT 0 NOT NULL,
    iwl_prefix text DEFAULT ''::text NOT NULL,
    iwl_title text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.iwlinks OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.job (
    job_id integer NOT NULL,
    job_cmd text NOT NULL,
    job_namespace smallint NOT NULL,
    job_title text NOT NULL,
    job_timestamp timestamp with time zone,
    job_params text NOT NULL,
    job_random integer DEFAULT 0 NOT NULL,
    job_attempts integer DEFAULT 0 NOT NULL,
    job_token text DEFAULT ''::text NOT NULL,
    job_token_timestamp timestamp with time zone,
    job_sha1 text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.job OWNER TO postgres;

--
-- Name: job_job_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.job_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.job_job_id_seq OWNER TO postgres;

--
-- Name: job_job_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.job_job_id_seq OWNED BY mediawiki.job.job_id;


--
-- Name: l10n_cache; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.l10n_cache (
    lc_lang text NOT NULL,
    lc_key text NOT NULL,
    lc_value bytea NOT NULL
);


ALTER TABLE mediawiki.l10n_cache OWNER TO postgres;

--
-- Name: langlinks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.langlinks (
    ll_from integer NOT NULL,
    ll_lang text,
    ll_title text
);


ALTER TABLE mediawiki.langlinks OWNER TO postgres;

--
-- Name: log_search; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.log_search (
    ls_field text NOT NULL,
    ls_value text NOT NULL,
    ls_log_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE mediawiki.log_search OWNER TO postgres;

--
-- Name: logging; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.logging (
    log_id integer NOT NULL,
    log_type text NOT NULL,
    log_action text NOT NULL,
    log_timestamp timestamp with time zone NOT NULL,
    log_actor integer NOT NULL,
    log_namespace smallint NOT NULL,
    log_title text NOT NULL,
    log_comment_id integer NOT NULL,
    log_params text,
    log_deleted smallint DEFAULT 0 NOT NULL,
    log_page integer
);


ALTER TABLE mediawiki.logging OWNER TO postgres;

--
-- Name: logging_log_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.logging_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.logging_log_id_seq OWNER TO postgres;

--
-- Name: logging_log_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.logging_log_id_seq OWNED BY mediawiki.logging.log_id;


--
-- Name: module_deps; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.module_deps (
    md_module text NOT NULL,
    md_skin text NOT NULL,
    md_deps text NOT NULL
);


ALTER TABLE mediawiki.module_deps OWNER TO postgres;

--
-- Name: mwuser; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.mwuser (
    user_id integer NOT NULL,
    user_name text NOT NULL,
    user_real_name text,
    user_password text,
    user_newpassword text,
    user_newpass_time timestamp with time zone,
    user_token text,
    user_email text,
    user_email_token text,
    user_email_token_expires timestamp with time zone,
    user_email_authenticated timestamp with time zone,
    user_touched timestamp with time zone,
    user_registration timestamp with time zone,
    user_editcount integer,
    user_password_expires timestamp with time zone
);


ALTER TABLE mediawiki.mwuser OWNER TO postgres;

--
-- Name: objectcache; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.objectcache (
    keyname text,
    value bytea DEFAULT '\x'::bytea NOT NULL,
    exptime timestamp with time zone NOT NULL
);


ALTER TABLE mediawiki.objectcache OWNER TO postgres;

--
-- Name: oldimage; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.oldimage (
    oi_name text NOT NULL,
    oi_archive_name text NOT NULL,
    oi_size integer NOT NULL,
    oi_width integer NOT NULL,
    oi_height integer NOT NULL,
    oi_bits smallint,
    oi_description_id integer NOT NULL,
    oi_actor integer NOT NULL,
    oi_timestamp timestamp with time zone,
    oi_metadata bytea DEFAULT '\x'::bytea NOT NULL,
    oi_media_type text,
    oi_major_mime text DEFAULT 'unknown'::text,
    oi_minor_mime text DEFAULT 'unknown'::text,
    oi_deleted smallint DEFAULT 0 NOT NULL,
    oi_sha1 text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.oldimage OWNER TO postgres;

--
-- Name: page; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.page (
    page_id integer NOT NULL,
    page_namespace smallint NOT NULL,
    page_title text NOT NULL,
    page_restrictions text,
    page_is_redirect smallint DEFAULT 0 NOT NULL,
    page_is_new smallint DEFAULT 0 NOT NULL,
    page_random numeric(15,14) DEFAULT random() NOT NULL,
    page_touched timestamp with time zone,
    page_links_updated timestamp with time zone,
    page_latest integer NOT NULL,
    page_len integer NOT NULL,
    page_content_model text,
    page_lang text,
    titlevector tsvector
);


ALTER TABLE mediawiki.page OWNER TO postgres;

--
-- Name: page_page_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.page_page_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.page_page_id_seq OWNER TO postgres;

--
-- Name: page_page_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.page_page_id_seq OWNED BY mediawiki.page.page_id;


--
-- Name: page_props; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.page_props (
    pp_page integer NOT NULL,
    pp_propname text NOT NULL,
    pp_value text NOT NULL,
    pp_sortkey double precision
);


ALTER TABLE mediawiki.page_props OWNER TO postgres;

--
-- Name: page_restrictions; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.page_restrictions (
    pr_id integer NOT NULL,
    pr_page integer NOT NULL,
    pr_type text NOT NULL,
    pr_level text NOT NULL,
    pr_cascade smallint NOT NULL,
    pr_user integer,
    pr_expiry timestamp with time zone
);


ALTER TABLE mediawiki.page_restrictions OWNER TO postgres;

--
-- Name: page_restrictions_pr_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.page_restrictions_pr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.page_restrictions_pr_id_seq OWNER TO postgres;

--
-- Name: page_restrictions_pr_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.page_restrictions_pr_id_seq OWNED BY mediawiki.page_restrictions.pr_id;


--
-- Name: pagecontent; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.pagecontent (
    old_id integer NOT NULL,
    old_text text,
    old_flags text,
    textvector tsvector
);


ALTER TABLE mediawiki.pagecontent OWNER TO postgres;

--
-- Name: pagelinks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.pagelinks (
    pl_from integer NOT NULL,
    pl_from_namespace integer DEFAULT 0 NOT NULL,
    pl_namespace smallint NOT NULL,
    pl_title text NOT NULL
);


ALTER TABLE mediawiki.pagelinks OWNER TO postgres;

--
-- Name: protected_titles; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.protected_titles (
    pt_namespace smallint NOT NULL,
    pt_title text NOT NULL,
    pt_user integer,
    pt_reason_id integer NOT NULL,
    pt_timestamp timestamp with time zone NOT NULL,
    pt_expiry timestamp with time zone,
    pt_create_perm text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.protected_titles OWNER TO postgres;

--
-- Name: querycache; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.querycache (
    qc_type text NOT NULL,
    qc_value integer NOT NULL,
    qc_namespace smallint NOT NULL,
    qc_title text NOT NULL
);


ALTER TABLE mediawiki.querycache OWNER TO postgres;

--
-- Name: querycache_info; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.querycache_info (
    qci_type text,
    qci_timestamp timestamp with time zone
);


ALTER TABLE mediawiki.querycache_info OWNER TO postgres;

--
-- Name: querycachetwo; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.querycachetwo (
    qcc_type text NOT NULL,
    qcc_value integer DEFAULT 0 NOT NULL,
    qcc_namespace integer DEFAULT 0 NOT NULL,
    qcc_title text DEFAULT ''::text NOT NULL,
    qcc_namespacetwo integer DEFAULT 0 NOT NULL,
    qcc_titletwo text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.querycachetwo OWNER TO postgres;

--
-- Name: recentchanges; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.recentchanges (
    rc_id integer NOT NULL,
    rc_timestamp timestamp with time zone NOT NULL,
    rc_actor integer NOT NULL,
    rc_namespace smallint NOT NULL,
    rc_title text NOT NULL,
    rc_comment_id integer NOT NULL,
    rc_minor smallint DEFAULT 0 NOT NULL,
    rc_bot smallint DEFAULT 0 NOT NULL,
    rc_new smallint DEFAULT 0 NOT NULL,
    rc_cur_id integer,
    rc_this_oldid integer NOT NULL,
    rc_last_oldid integer NOT NULL,
    rc_type smallint DEFAULT 0 NOT NULL,
    rc_source text NOT NULL,
    rc_patrolled smallint DEFAULT 0 NOT NULL,
    rc_ip cidr,
    rc_old_len integer,
    rc_new_len integer,
    rc_deleted smallint DEFAULT 0 NOT NULL,
    rc_logid integer DEFAULT 0 NOT NULL,
    rc_log_type text,
    rc_log_action text,
    rc_params text
);


ALTER TABLE mediawiki.recentchanges OWNER TO postgres;

--
-- Name: recentchanges_rc_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.recentchanges_rc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.recentchanges_rc_id_seq OWNER TO postgres;

--
-- Name: recentchanges_rc_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.recentchanges_rc_id_seq OWNED BY mediawiki.recentchanges.rc_id;


--
-- Name: redirect; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.redirect (
    rd_from integer NOT NULL,
    rd_namespace smallint NOT NULL,
    rd_title text NOT NULL,
    rd_interwiki text,
    rd_fragment text
);


ALTER TABLE mediawiki.redirect OWNER TO postgres;

--
-- Name: revision; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.revision (
    rev_id integer NOT NULL,
    rev_page integer,
    rev_comment_id integer DEFAULT 0 NOT NULL,
    rev_actor integer DEFAULT 0 NOT NULL,
    rev_timestamp timestamp with time zone NOT NULL,
    rev_minor_edit smallint DEFAULT 0 NOT NULL,
    rev_deleted smallint DEFAULT 0 NOT NULL,
    rev_len integer,
    rev_parent_id integer,
    rev_sha1 text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.revision OWNER TO postgres;

--
-- Name: revision_actor_temp; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.revision_actor_temp (
    revactor_rev integer NOT NULL,
    revactor_actor integer NOT NULL,
    revactor_timestamp timestamp with time zone NOT NULL,
    revactor_page integer
);


ALTER TABLE mediawiki.revision_actor_temp OWNER TO postgres;

--
-- Name: revision_comment_temp; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.revision_comment_temp (
    revcomment_rev integer NOT NULL,
    revcomment_comment_id integer NOT NULL
);


ALTER TABLE mediawiki.revision_comment_temp OWNER TO postgres;

--
-- Name: revision_rev_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.revision_rev_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.revision_rev_id_seq OWNER TO postgres;

--
-- Name: revision_rev_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.revision_rev_id_seq OWNED BY mediawiki.revision.rev_id;


--
-- Name: site_identifiers; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.site_identifiers (
    si_type text NOT NULL,
    si_key text NOT NULL,
    si_site integer NOT NULL
);


ALTER TABLE mediawiki.site_identifiers OWNER TO postgres;

--
-- Name: site_stats; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.site_stats (
    ss_row_id integer DEFAULT 0 NOT NULL,
    ss_total_edits integer,
    ss_good_articles integer,
    ss_total_pages integer,
    ss_users integer,
    ss_active_users integer,
    ss_images integer
);


ALTER TABLE mediawiki.site_stats OWNER TO postgres;

--
-- Name: sites; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.sites (
    site_id integer NOT NULL,
    site_global_key text NOT NULL,
    site_type text NOT NULL,
    site_group text NOT NULL,
    site_source text NOT NULL,
    site_language text NOT NULL,
    site_protocol text NOT NULL,
    site_domain text NOT NULL,
    site_data text NOT NULL,
    site_forward smallint NOT NULL,
    site_config text NOT NULL
);


ALTER TABLE mediawiki.sites OWNER TO postgres;

--
-- Name: sites_site_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.sites_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.sites_site_id_seq OWNER TO postgres;

--
-- Name: sites_site_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.sites_site_id_seq OWNED BY mediawiki.sites.site_id;


--
-- Name: slot_roles; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.slot_roles (
    role_id smallint NOT NULL,
    role_name text NOT NULL
);


ALTER TABLE mediawiki.slot_roles OWNER TO postgres;

--
-- Name: slot_roles_role_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.slot_roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.slot_roles_role_id_seq OWNER TO postgres;

--
-- Name: slot_roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.slot_roles_role_id_seq OWNED BY mediawiki.slot_roles.role_id;


--
-- Name: slots; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.slots (
    slot_revision_id integer NOT NULL,
    slot_role_id smallint NOT NULL,
    slot_content_id integer NOT NULL,
    slot_origin integer NOT NULL
);


ALTER TABLE mediawiki.slots OWNER TO postgres;

--
-- Name: templatelinks; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.templatelinks (
    tl_from integer NOT NULL,
    tl_from_namespace integer DEFAULT 0 NOT NULL,
    tl_namespace smallint NOT NULL,
    tl_title text NOT NULL
);


ALTER TABLE mediawiki.templatelinks OWNER TO postgres;

--
-- Name: text_old_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.text_old_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.text_old_id_seq OWNER TO postgres;

--
-- Name: text_old_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.text_old_id_seq OWNED BY mediawiki.pagecontent.old_id;


--
-- Name: updatelog; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.updatelog (
    ul_key character varying(255) NOT NULL,
    ul_value text
);


ALTER TABLE mediawiki.updatelog OWNER TO postgres;

--
-- Name: uploadstash; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.uploadstash (
    us_id integer NOT NULL,
    us_user integer,
    us_key text,
    us_orig_path text,
    us_path text,
    us_props bytea,
    us_source_type text,
    us_timestamp timestamp with time zone,
    us_status text,
    us_chunk_inx integer,
    us_size integer,
    us_sha1 text,
    us_mime text,
    us_media_type mediawiki.media_type,
    us_image_width integer,
    us_image_height integer,
    us_image_bits smallint
);


ALTER TABLE mediawiki.uploadstash OWNER TO postgres;

--
-- Name: uploadstash_us_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.uploadstash_us_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.uploadstash_us_id_seq OWNER TO postgres;

--
-- Name: uploadstash_us_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.uploadstash_us_id_seq OWNED BY mediawiki.uploadstash.us_id;


--
-- Name: user_former_groups; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.user_former_groups (
    ufg_user integer DEFAULT 0 NOT NULL,
    ufg_group text DEFAULT ''::text NOT NULL
);


ALTER TABLE mediawiki.user_former_groups OWNER TO postgres;

--
-- Name: user_groups; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.user_groups (
    ug_user integer NOT NULL,
    ug_group text NOT NULL,
    ug_expiry timestamp with time zone
);


ALTER TABLE mediawiki.user_groups OWNER TO postgres;

--
-- Name: user_newtalk; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.user_newtalk (
    user_id integer DEFAULT 0 NOT NULL,
    user_ip text DEFAULT ''::text NOT NULL,
    user_last_timestamp timestamp with time zone
);


ALTER TABLE mediawiki.user_newtalk OWNER TO postgres;

--
-- Name: user_properties; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.user_properties (
    up_user integer,
    up_property text NOT NULL,
    up_value text
);


ALTER TABLE mediawiki.user_properties OWNER TO postgres;

--
-- Name: user_user_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.user_user_id_seq
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.user_user_id_seq OWNER TO postgres;

--
-- Name: user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.user_user_id_seq OWNED BY mediawiki.mwuser.user_id;


--
-- Name: watchlist; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.watchlist (
    wl_id integer NOT NULL,
    wl_user integer NOT NULL,
    wl_namespace smallint DEFAULT 0 NOT NULL,
    wl_title text NOT NULL,
    wl_notificationtimestamp timestamp with time zone
);


ALTER TABLE mediawiki.watchlist OWNER TO postgres;

--
-- Name: watchlist_expiry; Type: TABLE; Schema: mediawiki; Owner: postgres
--

CREATE TABLE mediawiki.watchlist_expiry (
    we_item integer NOT NULL,
    we_expiry timestamp with time zone NOT NULL
);


ALTER TABLE mediawiki.watchlist_expiry OWNER TO postgres;

--
-- Name: watchlist_expiry_we_item_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.watchlist_expiry_we_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.watchlist_expiry_we_item_seq OWNER TO postgres;

--
-- Name: watchlist_expiry_we_item_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.watchlist_expiry_we_item_seq OWNED BY mediawiki.watchlist_expiry.we_item;


--
-- Name: watchlist_wl_id_seq; Type: SEQUENCE; Schema: mediawiki; Owner: postgres
--

CREATE SEQUENCE mediawiki.watchlist_wl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mediawiki.watchlist_wl_id_seq OWNER TO postgres;

--
-- Name: watchlist_wl_id_seq; Type: SEQUENCE OWNED BY; Schema: mediawiki; Owner: postgres
--

ALTER SEQUENCE mediawiki.watchlist_wl_id_seq OWNED BY mediawiki.watchlist.wl_id;


--
-- Name: actor actor_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.actor ALTER COLUMN actor_id SET DEFAULT nextval('mediawiki.actor_actor_id_seq'::regclass);


--
-- Name: archive ar_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.archive ALTER COLUMN ar_id SET DEFAULT nextval('mediawiki.archive_ar_id_seq'::regclass);


--
-- Name: category cat_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.category ALTER COLUMN cat_id SET DEFAULT nextval('mediawiki.category_cat_id_seq'::regclass);


--
-- Name: change_tag ct_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.change_tag ALTER COLUMN ct_id SET DEFAULT nextval('mediawiki.change_tag_ct_id_seq'::regclass);


--
-- Name: change_tag_def ctd_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.change_tag_def ALTER COLUMN ctd_id SET DEFAULT nextval('mediawiki.change_tag_def_ctd_id_seq'::regclass);


--
-- Name: comment comment_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.comment ALTER COLUMN comment_id SET DEFAULT nextval('mediawiki.comment_comment_id_seq'::regclass);


--
-- Name: content content_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.content ALTER COLUMN content_id SET DEFAULT nextval('mediawiki.content_content_id_seq'::regclass);


--
-- Name: content_models model_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.content_models ALTER COLUMN model_id SET DEFAULT nextval('mediawiki.content_models_model_id_seq'::regclass);


--
-- Name: externallinks el_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.externallinks ALTER COLUMN el_id SET DEFAULT nextval('mediawiki.externallinks_el_id_seq'::regclass);


--
-- Name: filearchive fa_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.filearchive ALTER COLUMN fa_id SET DEFAULT nextval('mediawiki.filearchive_fa_id_seq'::regclass);


--
-- Name: ip_changes ipc_rev_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ip_changes ALTER COLUMN ipc_rev_id SET DEFAULT nextval('mediawiki.ip_changes_ipc_rev_id_seq'::regclass);


--
-- Name: ipblocks ipb_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ipblocks ALTER COLUMN ipb_id SET DEFAULT nextval('mediawiki.ipblocks_ipb_id_seq'::regclass);


--
-- Name: job job_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.job ALTER COLUMN job_id SET DEFAULT nextval('mediawiki.job_job_id_seq'::regclass);


--
-- Name: logging log_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.logging ALTER COLUMN log_id SET DEFAULT nextval('mediawiki.logging_log_id_seq'::regclass);


--
-- Name: mwuser user_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.mwuser ALTER COLUMN user_id SET DEFAULT nextval('mediawiki.user_user_id_seq'::regclass);


--
-- Name: page page_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page ALTER COLUMN page_id SET DEFAULT nextval('mediawiki.page_page_id_seq'::regclass);


--
-- Name: page_restrictions pr_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page_restrictions ALTER COLUMN pr_id SET DEFAULT nextval('mediawiki.page_restrictions_pr_id_seq'::regclass);


--
-- Name: pagecontent old_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.pagecontent ALTER COLUMN old_id SET DEFAULT nextval('mediawiki.text_old_id_seq'::regclass);


--
-- Name: recentchanges rc_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.recentchanges ALTER COLUMN rc_id SET DEFAULT nextval('mediawiki.recentchanges_rc_id_seq'::regclass);


--
-- Name: revision rev_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.revision ALTER COLUMN rev_id SET DEFAULT nextval('mediawiki.revision_rev_id_seq'::regclass);


--
-- Name: sites site_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.sites ALTER COLUMN site_id SET DEFAULT nextval('mediawiki.sites_site_id_seq'::regclass);


--
-- Name: slot_roles role_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.slot_roles ALTER COLUMN role_id SET DEFAULT nextval('mediawiki.slot_roles_role_id_seq'::regclass);


--
-- Name: uploadstash us_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.uploadstash ALTER COLUMN us_id SET DEFAULT nextval('mediawiki.uploadstash_us_id_seq'::regclass);


--
-- Name: watchlist wl_id; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.watchlist ALTER COLUMN wl_id SET DEFAULT nextval('mediawiki.watchlist_wl_id_seq'::regclass);


--
-- Name: watchlist_expiry we_item; Type: DEFAULT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.watchlist_expiry ALTER COLUMN we_item SET DEFAULT nextval('mediawiki.watchlist_expiry_we_item_seq'::regclass);


--
-- Data for Name: actor; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.actor (actor_id, actor_user, actor_name) FROM stdin;
1	1	Admin
2	2	MediaWiki default
\.


--
-- Data for Name: archive; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.archive (ar_id, ar_namespace, ar_title, ar_page_id, ar_parent_id, ar_sha1, ar_comment_id, ar_actor, ar_timestamp, ar_minor_edit, ar_rev_id, ar_deleted, ar_len) FROM stdin;
\.


--
-- Data for Name: bot_passwords; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.bot_passwords (bp_user, bp_app_id, bp_password, bp_token, bp_restrictions, bp_grants) FROM stdin;
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.category (cat_id, cat_title, cat_pages, cat_subcats, cat_files) FROM stdin;
\.


--
-- Data for Name: categorylinks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.categorylinks (cl_from, cl_to, cl_sortkey, cl_timestamp, cl_sortkey_prefix, cl_collation, cl_type) FROM stdin;
\.


--
-- Data for Name: change_tag; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.change_tag (ct_id, ct_rc_id, ct_log_id, ct_rev_id, ct_params, ct_tag_id) FROM stdin;
\.


--
-- Data for Name: change_tag_def; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.change_tag_def (ctd_id, ctd_name, ctd_user_defined, ctd_count) FROM stdin;
\.


--
-- Data for Name: comment; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.comment (comment_id, comment_hash, comment_text, comment_data) FROM stdin;
1	0		\N
\.


--
-- Data for Name: content; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.content (content_id, content_size, content_sha1, content_model, content_address) FROM stdin;
1	735	a5wehuldd0go2uniagwvx66n6c80irq	1	tt:1
\.


--
-- Data for Name: content_models; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.content_models (model_id, model_name) FROM stdin;
1	wikitext
\.


--
-- Data for Name: externallinks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.externallinks (el_id, el_from, el_to, el_index, el_index_60) FROM stdin;
\.


--
-- Data for Name: filearchive; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.filearchive (fa_id, fa_name, fa_archive_name, fa_storage_group, fa_storage_key, fa_deleted_user, fa_deleted_timestamp, fa_deleted_reason_id, fa_size, fa_width, fa_height, fa_metadata, fa_bits, fa_media_type, fa_major_mime, fa_minor_mime, fa_description_id, fa_actor, fa_timestamp, fa_deleted, fa_sha1) FROM stdin;
\.


--
-- Data for Name: image; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.image (img_name, img_size, img_width, img_height, img_metadata, img_bits, img_media_type, img_major_mime, img_minor_mime, img_description_id, img_actor, img_timestamp, img_sha1) FROM stdin;
\.


--
-- Data for Name: imagelinks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.imagelinks (il_from, il_from_namespace, il_to) FROM stdin;
\.


--
-- Data for Name: interwiki; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.interwiki (iw_prefix, iw_url, iw_local, iw_trans, iw_api, iw_wikiid) FROM stdin;
acronym	https://www.acronymfinder.com/~/search/af.aspx?string=exact&Acronym=$1	0	0		
advogato	http://www.advogato.org/$1	0	0		
arxiv	https://www.arxiv.org/abs/$1	0	0		
c2find	http://c2.com/cgi/wiki?FindPage&value=$1	0	0		
cache	https://www.google.com/search?q=cache:$1	0	0		
commons	https://commons.wikimedia.org/wiki/$1	0	0	https://commons.wikimedia.org/w/api.php	
dictionary	http://www.dict.org/bin/Dict?Database=*&Form=Dict1&Strategy=*&Query=$1	0	0		
doi	https://dx.doi.org/$1	0	0		
drumcorpswiki	http://www.drumcorpswiki.com/$1	0	0	http://drumcorpswiki.com/api.php	
dwjwiki	http://www.suberic.net/cgi-bin/dwj/wiki.cgi?$1	0	0		
elibre	http://enciclopedia.us.es/index.php/$1	0	0	http://enciclopedia.us.es/api.php	
emacswiki	https://www.emacswiki.org/emacs/$1	0	0		
foldoc	https://foldoc.org/?$1	0	0		
foxwiki	https://fox.wikis.com/wc.dll?Wiki~$1	0	0		
freebsdman	https://www.FreeBSD.org/cgi/man.cgi?apropos=1&query=$1	0	0		
gentoo-wiki	http://gentoo-wiki.com/$1	0	0		
google	https://www.google.com/search?q=$1	0	0		
googlegroups	https://groups.google.com/groups?q=$1	0	0		
hammondwiki	http://www.dairiki.org/HammondWiki/$1	0	0		
hrwiki	http://www.hrwiki.org/wiki/$1	0	0	http://www.hrwiki.org/w/api.php	
imdb	http://www.imdb.com/find?q=$1&tt=on	0	0		
kmwiki	https://kmwiki.wikispaces.com/$1	0	0		
linuxwiki	http://linuxwiki.de/$1	0	0		
lojban	https://mw.lojban.org/papri/$1	0	0		
lqwiki	http://wiki.linuxquestions.org/wiki/$1	0	0		
meatball	http://www.usemod.com/cgi-bin/mb.pl?$1	0	0		
mediawikiwiki	https://www.mediawiki.org/wiki/$1	0	0	https://www.mediawiki.org/w/api.php	
memoryalpha	http://en.memory-alpha.org/wiki/$1	0	0	http://en.memory-alpha.org/api.php	
metawiki	http://sunir.org/apps/meta.pl?$1	0	0		
metawikimedia	https://meta.wikimedia.org/wiki/$1	0	0	https://meta.wikimedia.org/w/api.php	
mozillawiki	https://wiki.mozilla.org/$1	0	0	https://wiki.mozilla.org/api.php	
mw	https://www.mediawiki.org/wiki/$1	0	0	https://www.mediawiki.org/w/api.php	
oeis	https://oeis.org/$1	0	0		
openwiki	http://openwiki.com/ow.asp?$1	0	0		
pmid	https://www.ncbi.nlm.nih.gov/pubmed/$1?dopt=Abstract	0	0		
pythoninfo	https://wiki.python.org/moin/$1	0	0		
rfc	https://tools.ietf.org/html/rfc$1	0	0		
s23wiki	http://s23.org/wiki/$1	0	0	http://s23.org/w/api.php	
seattlewireless	http://seattlewireless.net/$1	0	0		
senseislibrary	https://senseis.xmp.net/?$1	0	0		
shoutwiki	http://www.shoutwiki.com/wiki/$1	0	0	http://www.shoutwiki.com/w/api.php	
squeak	http://wiki.squeak.org/squeak/$1	0	0		
tmbw	http://www.tmbw.net/wiki/$1	0	0	http://tmbw.net/wiki/api.php	
tmnet	http://www.technomanifestos.net/?$1	0	0		
theopedia	https://www.theopedia.com/$1	0	0		
twiki	http://twiki.org/cgi-bin/view/$1	0	0		
uncyclopedia	https://en.uncyclopedia.co/wiki/$1	0	0	https://en.uncyclopedia.co/w/api.php	
unreal	https://wiki.beyondunreal.com/$1	0	0	https://wiki.beyondunreal.com/w/api.php	
usemod	http://www.usemod.com/cgi-bin/wiki.pl?$1	0	0		
wiki	http://c2.com/cgi/wiki?$1	0	0		
wikia	http://www.wikia.com/wiki/$1	0	0		
wikibooks	https://en.wikibooks.org/wiki/$1	0	0	https://en.wikibooks.org/w/api.php	
wikidata	https://www.wikidata.org/wiki/$1	0	0	https://www.wikidata.org/w/api.php	
wikif1	http://www.wikif1.org/$1	0	0		
wikihow	https://www.wikihow.com/$1	0	0	https://www.wikihow.com/api.php	
wikinfo	http://wikinfo.co/English/index.php/$1	0	0		
wikimedia	https://foundation.wikimedia.org/wiki/$1	0	0	https://foundation.wikimedia.org/w/api.php	
wikinews	https://en.wikinews.org/wiki/$1	0	0	https://en.wikinews.org/w/api.php	
wikipedia	https://en.wikipedia.org/wiki/$1	0	0	https://en.wikipedia.org/w/api.php	
wikiquote	https://en.wikiquote.org/wiki/$1	0	0	https://en.wikiquote.org/w/api.php	
wikisource	https://wikisource.org/wiki/$1	0	0	https://wikisource.org/w/api.php	
wikispecies	https://species.wikimedia.org/wiki/$1	0	0	https://species.wikimedia.org/w/api.php	
wikiversity	https://en.wikiversity.org/wiki/$1	0	0	https://en.wikiversity.org/w/api.php	
wikivoyage	https://en.wikivoyage.org/wiki/$1	0	0	https://en.wikivoyage.org/w/api.php	
wikt	https://en.wiktionary.org/wiki/$1	0	0	https://en.wiktionary.org/w/api.php	
wiktionary	https://en.wiktionary.org/wiki/$1	0	0	https://en.wiktionary.org/w/api.php	
\.


--
-- Data for Name: ip_changes; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.ip_changes (ipc_rev_id, ipc_rev_timestamp, ipc_hex) FROM stdin;
\.


--
-- Data for Name: ipblocks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.ipblocks (ipb_id, ipb_address, ipb_user, ipb_by_actor, ipb_reason_id, ipb_timestamp, ipb_auto, ipb_anon_only, ipb_create_account, ipb_enable_autoblock, ipb_expiry, ipb_range_start, ipb_range_end, ipb_deleted, ipb_block_email, ipb_allow_usertalk, ipb_parent_block_id, ipb_sitewide) FROM stdin;
\.


--
-- Data for Name: ipblocks_restrictions; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.ipblocks_restrictions (ir_ipb_id, ir_type, ir_value) FROM stdin;
\.


--
-- Data for Name: iwlinks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.iwlinks (iwl_from, iwl_prefix, iwl_title) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.job (job_id, job_cmd, job_namespace, job_title, job_timestamp, job_params, job_random, job_attempts, job_token, job_token_timestamp, job_sha1) FROM stdin;
\.


--
-- Data for Name: l10n_cache; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.l10n_cache (lc_lang, lc_key, lc_value) FROM stdin;
\.


--
-- Data for Name: langlinks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.langlinks (ll_from, ll_lang, ll_title) FROM stdin;
\.


--
-- Data for Name: log_search; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.log_search (ls_field, ls_value, ls_log_id) FROM stdin;
associated_rev_id	1	1
\.


--
-- Data for Name: logging; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.logging (log_id, log_type, log_action, log_timestamp, log_actor, log_namespace, log_title, log_comment_id, log_params, log_deleted, log_page) FROM stdin;
1	create	create	2021-06-14 15:51:48+00	2	0	Main_Page	1	a:1:{s:17:"associated_rev_id";i:1;}	0	1
\.


--
-- Data for Name: module_deps; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.module_deps (md_module, md_skin, md_deps) FROM stdin;
skins.vector.styles.legacy	vector|en	["resources/src/mediawiki.less/mediawiki.mixins.animation.less","resources/src/mediawiki.less/mediawiki.mixins.less","resources/src/mediawiki.less/mediawiki.mixins.rotation.less","resources/src/mediawiki.less/mediawiki.ui/variables.less","resources/src/mediawiki.skinning/i18n-all-lists-margins.less","resources/src/mediawiki.skinning/i18n-headings.less","resources/src/mediawiki.skinning/i18n-ordered-lists.less","resources/src/mediawiki.skinning/images/ajax-loader.gif","resources/src/mediawiki.skinning/images/magnify-clip-ltr.png","resources/src/mediawiki.skinning/images/magnify-clip-ltr.svg","resources/src/mediawiki.skinning/images/magnify-clip-rtl.png","resources/src/mediawiki.skinning/images/magnify-clip-rtl.svg","resources/src/mediawiki.skinning/images/spinner.gif","skins/Vector/resources/skins.vector.styles/Footer.less","skins/Vector/resources/skins.vector.styles/Indicators.less","skins/Vector/resources/skins.vector.styles/Menu.less","skins/Vector/resources/skins.vector.styles/MenuDropdown.less","skins/Vector/resources/skins.vector.styles/MenuPortal.less","skins/Vector/resources/skins.vector.styles/MenuTabs.less","skins/Vector/resources/skins.vector.styles/SearchBox.less","skins/Vector/resources/skins.vector.styles/SidebarLogo.less","skins/Vector/resources/skins.vector.styles/SiteNotice.less","skins/Vector/resources/skins.vector.styles/TabWatchstarLink-ie8.less","skins/Vector/resources/skins.vector.styles/TabWatchstarLink.less","skins/Vector/resources/skins.vector.styles/common/normalize.less","skins/Vector/resources/skins.vector.styles/common/print.less","skins/Vector/resources/skins.vector.styles/common/typography.less","skins/Vector/resources/skins.vector.styles/images/arrow-down.png","skins/Vector/resources/skins.vector.styles/images/arrow-down.svg","skins/Vector/resources/skins.vector.styles/images/bullet-icon.svg","skins/Vector/resources/skins.vector.styles/images/external-link-ltr-icon.png","skins/Vector/resources/skins.vector.styles/images/external-link-ltr-icon.svg","skins/Vector/resources/skins.vector.styles/images/portal-separator.png","skins/Vector/resources/skins.vector.styles/images/search.png","skins/Vector/resources/skins.vector.styles/images/search.svg","skins/Vector/resources/skins.vector.styles/images/tab-current-fade.png","skins/Vector/resources/skins.vector.styles/images/tab-normal-fade.png","skins/Vector/resources/skins.vector.styles/images/tab-separator.png","skins/Vector/resources/skins.vector.styles/images/unwatch-icon-hl.svg","skins/Vector/resources/skins.vector.styles/images/unwatch-icon.svg","skins/Vector/resources/skins.vector.styles/images/unwatch-temp-icon-hl.svg","skins/Vector/resources/skins.vector.styles/images/unwatch-temp-icon.svg","skins/Vector/resources/skins.vector.styles/images/user-avatar.png","skins/Vector/resources/skins.vector.styles/images/user-avatar.svg","skins/Vector/resources/skins.vector.styles/images/watch-icon-hl.svg","skins/Vector/resources/skins.vector.styles/images/watch-icon.svg","skins/Vector/resources/skins.vector.styles/legacy/Sidebar.less","skins/Vector/resources/skins.vector.styles/legacy/layout.less","skins/Vector/variables.less"]
mediawiki.icon	vector|en	["resources/src/mediawiki.icon/images/arrow-collapsed-ltr.png","resources/src/mediawiki.icon/images/arrow-collapsed-ltr.svg","resources/src/mediawiki.icon/images/arrow-expanded.png","resources/src/mediawiki.icon/images/arrow-expanded.svg","resources/src/mediawiki.less/mediawiki.mixins.less"]
mediawiki.htmlform.styles	vector|en	["resources/src/mediawiki.htmlform.styles/images/question.png","resources/src/mediawiki.htmlform.styles/images/question.svg","resources/src/mediawiki.less/mediawiki.mixins.less"]
mediawiki.special.userlogin.common.styles	vector|en	["resources/src/mediawiki.special.userlogin.common.styles/images/icon-lock.png"]
mediawiki.special.userlogin.login.styles	vector|en	["resources/src/mediawiki.special.userlogin.login.styles/images/glyph-people-large.png"]
mediawiki.ui	vector|en	["resources/src/mediawiki.less/mediawiki.mixins.less","resources/src/mediawiki.less/mediawiki.ui/variables.less","resources/src/mediawiki.ui/components/forms.less","resources/src/mediawiki.ui/components/utilities.less"]
mediawiki.ui.button	vector|en	["resources/src/mediawiki.less/mediawiki.mixins.less","resources/src/mediawiki.less/mediawiki.ui/mixins.buttons.less","resources/src/mediawiki.less/mediawiki.ui/variables.less"]
mediawiki.ui.checkbox	vector|en	["resources/src/mediawiki.less/mediawiki.mixins.less","resources/src/mediawiki.less/mediawiki.ui/variables.less","resources/src/mediawiki.ui/components/images/checkbox-checked.png","resources/src/mediawiki.ui/components/images/checkbox-checked.svg"]
mediawiki.ui.input	vector|en	["resources/src/mediawiki.less/mediawiki.mixins.less","resources/src/mediawiki.less/mediawiki.ui/variables.less"]
mediawiki.ui.radio	vector|en	["resources/src/mediawiki.less/mediawiki.mixins.less","resources/src/mediawiki.less/mediawiki.ui/variables.less"]
oojs-ui-core.styles	vector|en	["resources/src/mediawiki.less/mediawiki.ui/variables.less","skins/Vector/variables.less"]
mediawiki.helplink	vector|en	["resources/src/mediawiki.helplink/images/helpNotice.png","resources/src/mediawiki.helplink/images/helpNotice.svg","resources/src/mediawiki.less/mediawiki.mixins.less"]
mediawiki.special	vector|en	["resources/src/mediawiki.less/mediawiki.mixins.less","resources/src/mediawiki.less/mediawiki.ui/variables.less"]
\.


--
-- Data for Name: mwuser; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.mwuser (user_id, user_name, user_real_name, user_password, user_newpassword, user_newpass_time, user_token, user_email, user_email_token, user_email_token_expires, user_email_authenticated, user_touched, user_registration, user_editcount, user_password_expires) FROM stdin;
0	Anonymous		\N	\N	\N	\N	\N	\N	\N	\N	2021-06-14 15:51:47.328407+00	2021-06-14 15:51:47.328407+00	\N	\N
1	Admin		:pbkdf2:sha512:30000:64:HFVW8ADMpg25ddbPvGUKoA==:yX3DqTXP/T4zR+ukqdlhJg1Fujf92+b1MZtmaH98Huw3v6a5o3ovvJuMFULgElUrG4FEBuRUkwfibkYzRZqI/g==		\N	16764aa01d8da3df28183a12776c3aa0			\N	\N	2021-06-14 15:51:49+00	2021-06-14 15:51:48+00	0	\N
2	MediaWiki default				\N	*** INVALID ***		\N	\N	\N	2021-06-14 15:51:48+00	2021-06-14 15:51:48+00	0	\N
\.


--
-- Data for Name: objectcache; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.objectcache (keyname, value, exptime) FROM stdin;
WANCache:t:postgres-mediawiki-:messages:en	\\x2bb63232b5520a080d727775b13234333236b3303334b2d033353332b1323454b20600	2022-06-14 15:55:28+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Uncategorizedcategories-helppage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d4333734b3333eb5a00	2021-06-15 15:57:12+00
WANCache:t:global:MessageBlobStore	\\x2bb63232b1520a080d727775b13234333236b330333431d233b5b430b53250b20600	2022-06-14 15:55:42+00
postgres-mediawiki-:messages:en	\\x158cb10a83401005ff65bf606fddbd0bef2a0b419b242884589ec72d585b4afe3ddacdc030051dce0309f419e6657a3d29ef907c404163bf8c746127208f553d8995c869f3f6f0c2d5b9b2b5a6ae89ef2e8286ef7b9ad75bc2351096c03158303315cabf3f	2038-01-19 03:14:07+00
WANCache:v:postgres-mediawiki-:messages:en:hash:v1	\\x258c410e83300c04ff920720c709365abfc64d6311a9b77043fc9dd21ee6321a8da3e21c201bc83f1c8c737e6dda7deec9260a2385b41acaab0be92bfa164e2da8d1da7b8daaf47482f4f1a3cf23d933bc06d8fee7626f64e1229be4ca8b1495ac76dd	2038-01-19 03:14:07+00
WANCache:v:global:revision-row-1.29:postgres-mediawiki-:1:1	\\x7d52cb4ec33010fc952a5754643b899b6e8e9c0bdc3846ab7829167911bb0fa9eabfe34780a4aa38445666bcbbb33346c8e0a281951a78f85ea080c458f5d4a03109080e17031292918e955649698043c2fd594470c03dcd619e46dcea968cc576f0a010900826f89ac935cf563c879c43563c30164ab258d2eaae1f2b52da4e0d23cb23aba8214b6a4e6d22d350e7ffdce04d9acf350c385267ff74b3996ef381416fea70cc4ff471689462fb5e1c3a8dfbd3f12c6527eb82e9f12b544f1ed47ddbfa9e96ce412583e41eadd062523e7b265f32f55d170f86c60916f30d3cfe3b8bbb7d77ce1e7cd39f7aa5e81d0f4d20b6f132d6b65f7671c6fa7caa0e5d1803d6b430964dacd5b6a1a9cf0e7557bd4e996ea60b4bc93e900037685dc40b4afe54986a744a47aaed8df7b1f236313739acea85feb3ea558370cf54b2ac60fecda6a57233452a0bc933f1280bb64db7e5f51b	2021-06-21 15:55:42+00
WANCache:v:global:NameTableSqlStore:slot_roles:postgres-mediawiki-	\\x4bb432b1aaceb432b0ceb43204e3442b439080a175315046293731334fc9ba36d3ca082869646a69646000526a6c9d62656866646c6661666862a46766616961685d0b00	2021-07-14 15:55:42+00
WANCache:v:global:NameTableSqlStore:content_models:postgres-mediawiki-	\\x4bb432b1aaceb432b0ceb43204e3442b439080a175b19585955279667666496a458992756da69511508191a9a591810148b9b1758a95a19991b1998599a189919e99a5b1b991b9752d00	2021-07-14 15:55:42+00
WANCache:v:postgres-mediawiki-:page-content-model:1	\\x4bb432b1aaceb432b0ceb43204e3622b0b2ba5f2cceccc92d48a1225a09011089b5a1a19188014195ba758199a19199b5998199a18e999599a591a1859d70200	2021-07-14 15:55:42+00
Pingback-1.35.0	\\x31	2021-06-14 16:55:42+00
WANCache:v:postgres-mediawiki-:page-restrictions:v1:1:1	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfc2ccc40024636c9d62656866646c6661666862a4676e6a60606c625d0b00	2021-06-15 15:55:42+00
postgres-mediawiki-:pcache:idhash:1-0!canonical	\\x01a70758f84f3a383a22737464436c617373223a323a7b733a31343a225f5f7376635f736368656d615f5f223b733a31313a224441414944676f4b415177223b733a383a225f5f646174615f5f223b733a313837343a22bd587b6fdbc811bfbff929f6581cda02914452926353b280d479d8073fd4c8befc5114c19a5c495b935c627729590d0ee847e867ec27e9cc72299194e40b92f6843ca49dd999dfbc87bc0bfd2074a7542a26ef0a9d17da0d07a7e117150e4337bd67cfda1da9d03f0dce42779c4fc64a4b912d26372ce6f4137fe264491579642c233c539a26098bbbe39ee572c63db8924f2e44a68a4413bd64644c499450a5ce5d90cd644613a2510b594a363f77975ae72aecf5d6eb753745256b50d21572d1c32fbd59ce224e93f066734db3454117ac77c9923c040d9a655ab9930730e48f8a7c2878ccc63d3a217321011bfc9b52cd4546e04fa178b6306850285162aed754b2aec1eb8c9701d899d3ac029aae3b4b46e38467cc253c3e773f30ad41c26730586a16bb137b40ec013800ae4fc6e93a0413b46291d19c03dc73f786f28c4ce1ab4b2ce1dcf50f88685e9e8c7b00cb1917c9649cf0c9ffdc8b37342be004fc38e78b421a577d562526f06ae39c54e724e14aa393c73dc0e4fc3f81bd7ff357b79675f0734faf64c9b99b89b94812b176bf0a06e2575d546dc0182029e5494a3343c3bce96d7176689689228b581d096865543182d7307ebf834bae4544418d89c51fee25cd5452c64b32250a19310898e5616487140b610374925841bf4fe42e44fa48cb72c9690ac8189519598a35d18244864890828569e0a1bc2db4710f32de19ffd8e910e796ada7537070ca35b83d17523b17345ab29868885f48022ff0bd137fe00f87c34150d2087bceb9dc84e4f464e079cedb4d46531e815ed32f4232a789620e60cc131e192faa90fcedefcec5f4c148855e01b684c4eb7afd332c5891c5caf9c8d03b4df2c0db92a7804e0a88830297afb8e250d024133103bd056aedf77ccf7c9ca950fa3ffffa37a0a4590c7d2a4a0a6053fc9f28b4177867affd61401e379a29e79e014aaa19a17251a400ff08df255f2c99d2c4085558b031cbf5121cd41b78cebbe79cc1e98a413fc2ae4fe690d2a6ac2d380fc1390fd0ce25cfc1d15121eb4250db969a37e0577086a571164ea75306d031a90a061a693b70c68f653cc99f7e7a95aa5790ba897aa5adb97f76004fd7f37e22f0c12f1e311f9f74b480916314942932a32b865eac4c8b4c0aacb95e9227b631681750249d5d4987b9e109790c836c19fa1defc788662283644808da84e8a027a7792bbd0c51328c2ed8c063e23b048198713980d959d5c135cf9e943ba2a1177ef915683ed02ec0ac85909cb50957598c6928649de0e124e63a61d5388659bc9b22f0fb04d5b5d4f4ab335b996d79d6b9f52b41edfc2aae515e23b21494d5b94fe1f03d4fd80cea395adee5a6766a74f4c13bdb49b6e04e70b338016cdf3be7473cf4c1f2d767df22eae56167459f78df211ac75525a766edb7ce1b2bea74f02d90be625c54def4bfcb9b8d3e6f44621e0c4d5a431ee0fd43c5006d7d562e39eee831f446f6ce252c70074898bcb7e2036e9a72d338bd841ded0a9a464d3ee6e88d888b84b54ba33c9de9cd3ee9675526c62f54b6aba3dc902f85a81b0129987e829956264ffdd46237a77ef88503561a9ae51a806911256cc592caf960b3fd0dca4237c0ff21de66ebb43e69ed88b6f4b3227d64d25ef3dd5214cf62f65c3f033c7329528d7da4d6433e573d045d88fd5acce7500906d4e9a05440b36829640bc476f91dfd5a05722a45cea46e74358cc0fdddc5e5fdcd350a002595326869b6b3562db3d660fdc1a93945b1ef32fa98b0bbbb87ab2adc0180faa1feccf203364ef63c1530c437353d7d6f8ff14d847399c57b0d2b38dde3c5f66566d45baae98ef380d46b5c4a3e9a1956f1422e41a0fd330c2110cb01d789801decb651325b057e0fbc26db1af2bbc937f05c6b799d2fcfed7a81db85312628f38c877d9357f0b71cc6588bfd7eeb36ccc37274dbc503077843886785d805c308099a42aa315d2d255f23a36dc67619303b46e376606f0f4a0b067b17cb65a65a62cc0e7350bd5ffa2018362514e526d3d9d7bcc36dee0d0edf3b6aee70e7f7b64e882c5410ac88739eb05a732853ebe56dc73502a12eccdeb21378b4946057a94ab771459bce63d6e25199fd0d32ce090ee1b49b72597a36fcc793ffe75995fe81c97ebf61b831d543026c14472a01701c4b7e34ec60c21bb6154d0a3329fbb699a25eb75900e8b79792be29c86b09aa2730c4e985c4ff6a3968d2c1e46f4a085a12ca62080273f97801bc0cc31604cebc4345f05b368cec503c50082f5fad1506eafece62b0c3a796bb28c3f4de3323fcb70a0321346bc187ee7424ff6d0b6a15003cefad80e702a6cfd33f68f404f654a3eac0ac80a922e92c029fe9998c6a13a8ef1fe67dcbe6b4485accf842eea0605c695aacfb18de2774f1b2665cf40a5c1457ec235b5dc19cbf4573866d46b5e3c355e22a7e50ec2873f5bcb41dfd35e6bd995e3123cf6c49fdbf50c5fa27967bbf0b7d923487f5e32d5f5de06b0c566d5d653cd375a77c26ec88f22d27c4c73fd2cf6ee8f39b98e668d23bf3f6c01dc5e1d5edfb91dd021feaebc36dd9b3d25f98794ab63dcbef9e7407db4dc7bc89b8b71ded487b0e2abe4ae5adcdc4f2f4a3750606c26cd6ff05223b7d	2021-06-15 15:55:42+00
postgres-mediawiki-:pcache:idoptions:1	\\x458dc10ac2301044ff653fa0ec8624d4c9513c782a14f55e6cc01caaa55bc452faef2642f136bc37cc3438808eddfd112f69880487552106345c35f6cd38a7d753297460ac9ba2cee21627cd9482e63649e52b5bb27076ffa5422cc8b011f662c53967cd8f9abd77fa8c695a2824d4de3217e777d7c6772a2fe7be7809db17	2021-06-15 15:55:42+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Nstab-talk	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18e9599a9a1a581859d70200	2021-06-15 15:55:42+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Vector-action-viewsource	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18e9599a5a9a989858d70200	2021-06-15 15:55:42+00
WANCache:t:global:resourceloader-titleinfo:postgres-mediawiki-	\\x2bb63232b5520a080d727775b13234333236b330333431d2b3b4b034b7323454b20600	2022-06-14 15:55:42+00
WANCache:v:global:resourceloader-titleinfo:postgres-mediawiki-:432bad786e4c35990f47bc567a0c523303fe1c48	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfd8cc0024616c9d62656866646c666166646ea167646c6e62686c5d0b00	2021-06-14 16:57:58+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-navigation	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb191899191b995bd70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-n-help-mediawiki	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb19181b181b5b58d70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Accesskey-n-help-mediawiki	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb19181b1b99195ad70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-tb	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb19185b185a5a58d70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-lang	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb1998985a181b5ad70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-personal	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb19981a5a1a5b5ad70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-namespaces	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb19989a5958185bd70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-variants	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb1998199a1a9b58d70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-views	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb1998991a185a58d70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-ca-view	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb199859981a5b5ad70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Accesskey-ca-view	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb19981b9b5a185ad70200	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Tooltip-p-cactions	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a18eb195818189b9a5ad70200	2021-06-15 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:jquery.makeCollapsible.styles	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:jquery.confirmable	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:jquery.makeCollapsible	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:jquery.tablesorter	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.api	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.confirmCloseWindow	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.feedback	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.htmlform	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.searchSuggest	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.ForeignUpload	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.ForeignStructuredUpload	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.Upload.Dialog	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.Upload.BookletLayout	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:v:global:resourceloader-titleinfo:postgres-mediawiki-:da39a3ee5e6b4b0d3255bfef95601890afd80709	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfd8cc0024616c9d62656866646c6661666862a9676e68666064645d0b00	2021-06-14 16:55:49+00
WANCache:v:global:resourceloader-titleinfo:postgres-mediawiki-:e13a4c6012b98731f23f3a3a185dc3aa663155e7	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfd8cc0024616c9d62656866646c666166686aae67686861646a625d0b00	2021-06-14 16:55:57+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.ForeignStructuredUpload.BookletLayout	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.toc.styles	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.util	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.action.delete	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.action.delete.file	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.action.edit.preview	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.action.view.metadata	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.action.view.postEdit	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.action.edit.editWarning	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.language	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.language.months	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.language.specialCharacters	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.page.gallery.slideshow	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.page.ready	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.page.watch.ajax	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.rcfilters.filters.dm	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.rcfilters.filters.ui	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.interface.helpers.styles	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.apisandbox	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.misc-authed-curate	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.edittags	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.preferences.ooui	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.revisionDelete	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.search.commonsInterwikiWidget	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.unwatchedPages	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.upload	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.createaccount	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.special.watchlist	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.legacy.protect	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.AbandonEditDialog	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.DateInputWidget	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.datetime	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.CategoryMultiselectWidget	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.SizeFilterWidget	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.MediaSearch	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.Table	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:mediawiki.watchstar.widgets	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:oojs-ui-core	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:oojs-ui-widgets	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:oojs-ui-toolbars	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:t:postgres-mediawiki-:MessageBlobStore:oojs-ui-windows	\\x2bb63232b5520a080d727775b13234333236b330333431d633323235b4323454b20600	2022-06-14 15:55:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Uncategorizedimages-helppage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d430b13334b23eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:jquery.tablesorter:en:4c46fe1c2ef50ebdf873998aba613898	\\x4bb432b1aaceb432b0ceb43204e3622b4303432ba56aa5e2fca212ddc4e2e4d4bc94ccbc74252ba560a08002424007a22225155d099208544d665e664966620e4c018c5bab04b4d10888cdcc8d2d2d2c800c63eb142b43332363330b3323730b3d2373234b230beb5a00	2021-06-22 11:11:06+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:jquery.makeCollapsible:en:2e1aec29500269620cc8fe965cd4f966	\\x4bb432b1aaceb432b0ceb43204e3622b33532ba56aa5e4fc9c9cc482e2cca49c545d283b55c94ac919c6d44151915a5190989702947785306a9580861901b199a1a1a9a91990616c9d62656866646c666166686aae676c626a61646a5d0b00	2021-06-21 17:48:33+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:jquery.makeCollapsible.styles:en:2e1aec29500269620cc8fe965cd4f966	\\x4bb432b1aaceb432b0ceb43204e3622b33532ba56aa5e4fc9c9cc482e2cca49c545d283b55c94ac919c6d44151915a5190989702947785306a9580861901b1998991b925c87463eb142b43332363330b334353733d63130b13334beb5a00	2021-06-22 02:29:07+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.confirmCloseWindow:en:2621ba6cf3dcb767b780683d7e5163d2	\\x1d8d510a83301044afb2e4bf524db3b19b2bf4128ba649409362b445c4bb77f163e0cd30cc303de848747789da4b959e9ad4a18692df699927cf5f7ffbf192530e8ad44bbc10ac3155f870f030f30e036fd5c35e36580b4c4598b3a49173f0f5caa3cc4875f48d3a951c7522b43d5a23a0dd482d761a7b6c8d6db441abddf907	2021-06-22 12:27:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Uncategorizedpages-helppage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d434b03332343eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Uncategorizedtemplates-helppage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d434b0b632323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-brokenredirects	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d6363334b1333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-deadendpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d63536343130beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-doubleredirects	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d635373530b13eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-longpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d6333133343eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-ancientpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d6373030b334beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-lonelypages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d6373534b3323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-fewestrevisions	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d630b23235353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-withoutinterwiki	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d630b7323534beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-protectedpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d634b435323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.searchSuggest:en:d36d2470c7b5851ce578c54ba956bbf0	\\x4bb432b1aaceb432b0ceb43204e3622b0b4b2ba56aa5e2d4c4a2e48ce2d2f4f4d4e212dde4fcbc92c4ccbcccbc74252b2504474f4f4f49074d29840754160c66285457077b86b8fa39fabad6d62ad52a012d31026233736373733320c3d83ac5cad0ccc8d8ccc2ccc8dc42cfc8c2d4d0dcd2ba1600	2021-06-22 11:07:34+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.ForeignStructuredUpload:en:e92f2f4df425c159a113f15d13fa553b	\\x2d8ec10a84300c447f25f45eb1b57435bdef7f14ad6e401aa9f5b088ffbed5ee6120ccbc0ce3d1e049d83a42f56847a50614a738b695fd24674e819628471fb37c9c91e34c8b40f1f6b4860932c3ed43fe04a8d9917c268e507e612e0cd4aefd466feadf59b31436de2973fa36e21265832eb2bd69b52d47e726545677b6b7fad5377a68b551eefa01	2021-06-22 13:58:24+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.Upload.Dialog:en:2025422b649e11cb5eb9a7741a194c41	\\x75cfc10ac2300c06e057919e9d6ce98833bda96f203e40b64e29965658e765ecdd4d1d78107708ffdfe6bb84a9a6c951691c559f1908a02435a9f1e923dbc23af6f15eb4634a31142d770f45ea9863fb9f741cbade0b3a2d6585d9187a41e71c2b64e05726971c2b64f914745dca2f4b2ef9febbdedc9cbc662587820ca2c6b291a28da50a416383b06f7670d07565e637	2021-06-22 08:18:06+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.ForeignStructuredUpload.BookletLayout:en:7127b5dc6f65db4b26b61e0825047ee2	\\xad544d8fda3010fd2ba39c0902b2051a4e55bb070eed65b7876ac5618827c1aae3896c531451fe7b2766f9509ba2ee6ea538f124f3c6efbdb183f95dbed7f968a1f3711c3e1f4fc6f33cd927dbc630aab46457a706d764526d4b8e6181812a769a7c92271f2fc1e01648499ea47fea1e7d899643ca3b9beed87d4f0d1768d28a2c395d7459a42b2be86fbc851a5b40e3197668030486e05ad87a6d2b787a7a68a8d068f2afb1fecfb021382e050d56046c61bf7f583ede7ff9f0f9fe7058ad06a04b081beda1d486a0400beb1384947c2127a155e4bab976d0b0d185881dbe54448c6e49e825afa8c4ad09d72256ab7f58bb26ef25b7c7c26509ad5040d12508c0b5c81606cf0b5cac388b3e4b062e63ec370256e0a861af03bb76008d21f4629f61b9c71a4a84700568551487b296780935850dab570838d9f736fad7cdff4fac4f8c85db635742aeba05790bf1ed2dc8ad2e1d05f810a96c30c012b07e96d96df58b52518f7ff6642880826da95d7d8557dc6165e3956c0cef8e85a404b93afae3c9fdd0054503c435b2f1589d1d8cc7e1b60d7f6f5c0f9d3e39af63f6dbc11e268744fe671319d3f9e8eedd7b99640b958fa7936c3a9f4e66f36136ca66b36c71f805	2021-06-22 12:58:57+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.toc.styles:en:11c0571606cd3d304339566a72dae9f2	\\x25ca310ac0201044d1bb6c1d82baba91f13441035a59184821de3dc6141f1ec39cb0e8052a14e855033b50a75cd275d74858a28d5aaecf3f7ca241f36e6622ce3a3bc121418b61f1620ebfb312253a8c17	2021-06-22 08:48:52+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.action.delete:en:dec3a3913d1d84c8cf975557252e3dbe	\\x1dca410a80201046e1abc4ec0b7564d4dfd348b5102243db89774f5a7cf0162fc1a267a898a17f0dc6823aede52af7dace27d5f4964a202c34683e6612b62c3c83e3012d86c58b717e63e542f0717c	2021-06-22 00:10:41+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.action.delete.file:en:dec3a3913d1d84c8cf975557252e3dbe	\\x1dca410a80201046e1abc4ec0bc71926f93d8d540b2132b49d74f7a4c5076ff112143dc3c50cfe35780575daca59aeb91d77aae929954098e8a5f1f8c15834e808893bd8bc5830bf8645d829c7f703	2021-06-21 18:22:42+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.action.edit.preview:en:edaff49d2d365c28d7ddbaef4e48c70f	\\x6d914d6ac3301085af32882c524842fc132728ab50bcc8a2a5d05e409527b18a2d0559ae1b8cefdeb1a2e2a674213433ef9bc743123ce5bde2ebbde2913f0d4fe30d673d93168553facc387b0c25cc22b6605828278d3e554a3a12736ae1a7e713725bcd6fd5dd589aba46edee54986beca041e994d10f131b267fd85f9c7125da4ae8732bced81077d4e067300d17ec42b753ae4202c860097dff7a7ccb9f0f4ff93078dd52a2121b6f319f45a3f5c5e2a7c20ead35d6e1d718f8a0c1b760a46cadc502ba525508c239ac2f3e9f331016e16a5a0bb2a41cd8acc8b069df3f28f932e8e4f7124873822072cfd5b5b0d7ffb9f16120109c0d8c7e2da693edb6eb744345b22f7894c549b6cbe2ed6e95445992ee876f	2021-06-22 14:48:43+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.action.view.metadata:en:191a7b6d83712a8e27678c835d2d6bb0	\\x65cd3d0ac3300c86e1ab04cd6988ed603bf205baf704a212d4e0fc800d0d84dcbda24b870e2f7cc3031fe18467c6316534df2ac68070c2228d981add9e5b29b45701847b66e9e468b2b270c72a72a9d0ffac1c3badacf2f1dadefff202bdb09a37710e930e97188db7ce476f431c9c1d8d0be9fa00	2021-06-21 19:54:12+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.action.view.postEdit:en:128894e3091cd746004238a7dee7c6ab	\\x758fc10e823010447fa5d9b334d26a81e537bc782cb04a13a5a42d7a20fcbbb5514ff630c966665f26a3f180abc17d6bb04cf2286483b0c26c7da0c184a2b7d3c5b8bb0ec64e45ef48471b104e23b1595f898ddab38e68629f8cc32e03cf4b77337e4cf8d92e8ebd5fd833f2bf240f3bf2c1ba4cf537cce35e3ffef42697c30671bb88524a34f5311eb21db05442aa5a89aae652c85256edf602	2021-06-22 08:07:43+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.language.months:en:73af9e0086587a82daaf89854b1d5aa0	\\x4d924d6e83301046efe2751b059cb8c8ac2a5559203559e40095435c4a452032b8128a72f78e3de39f05e3f7bdf1803028b9938f5e6eeb5e16fe9aa5e095640fa6ee8649f60ef5c5713f608295f26ba7c7dcd9ce25a89eedbc6074104c1809f6aa5b881f503debdb451b1488c9d264d6f9d6171007a89e8d55664581982ccd669d5fe54403d5338d3644d1d160e6ad3b85c60ec82b06eac4edc160189135064d29eef5e6a6dc6b7f2a83dcfe608295326d4f6ef569458e5dca5fc33476518cd31ff011aae770c8c780c9d27db2ced4baaf786a17e409474f44d1d160f2b3be433e43f5bc84879e23679ea653efc9e0572ce11242ec8b3d00afafb21025179528dfaa0de7db5d55d6cf7f	2021-06-22 09:06:33+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.language.specialCharacters:en:6c63baaca3399f8893662ffe6206ade0	\\x8d94c16e83300c865f05711e53291545e9a9eba46eda0e95d617081005af21a004b65555df7d4ea0ed0e93e921f11febfba3c4b1c2d9829d80cd56c0623f2c8be359c6c253685b510057515171c38b4e181b49d3f46d84cb1c8a9085eb413c4ca1e2a713ba14e5d5125c338437e75a2a8e9ea7411068c1352f01a7bc3120417385b6cd980cd6b72cb5c7d18052fe5e9b8b24f0527ce1fe921b40c3f36d4158a411e280f4d6c729f04fd1bce1ae9ac9fe13339d3bd3f62209bc12b911df08bf0c8240a1754ff1ba5b53d0a1aa8541eccd470254bc41ec1d6712ea407bccc529f04fbdbce1ae7ab528b145d0b31b15015bd015f71df9312a0a3ed679a3ac834745c01dafc1b5ecde470a14aa97bd230741a115776db077e15fac834e8948d425b71582a20ebca2587d61f5245b83eedded7d0c2c481d9e43fc61e638d2e562b6745f4eb22a599cce93344be7cbec3149d2384b57e75f	2021-06-22 11:12:28+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.page.gallery.slideshow:en:7b71d5c963c72a156de94ba32ec74b36	\\x1dcb410a80201040d1abc4ec8b724487f11a5dc0484c980ab28890ee9eb4f8f036dfb3e692b8778987bfcc9a180a442f128ea7cd92e69097fd6ecf3d4609c030fe68cee55aa7cd27c9f0427d55cd90b5682bd0cd3c1885868cb2d42192eec9bd1f	2021-06-22 15:00:15+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.util:en:f91d56e8550123299aa6a008325e6a10	\\x1d8b4b0a80201400af128f9615f98fe751a285a50b6961a8d042bc7bda62601818831c8bc7557b243f09f98a50e08ce6ba5d4e80b08fe48009de10ed9cdc63a2c921b63e4085f6d086e442f12e4c5b249232b94922d4c2baeafa01	2021-06-22 03:18:19+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.action.edit.editWarning:en:34a87ba55d376b1b89dd29fc7e4a93b7	\\x554fbb6ec3300cfc15427362d48fb8b63c7728d04ff0c2588c2c20a50249491118fef7d28a970c04ef8ec717ea462f4e7f0c4e9739a2aeea4aab459171e90f033bb6c73d2bad7e081f8220cd2ec20d2dc12f3e61c27b2478fa3b240f572f1859d419d952ccfa8c8fcd6aa818f9fb92250c245e6bc980e343962664302ee2f94aaf0dfb6231082718d5b2384efa16e8128fdb85525cd75141a42939cfe0f3ec009b8302f144b15007f5d6206f7ced6855f27425d15675df7702eac1e85258dbb5e5e9b3a8dba6eb9b61fd07	2021-06-21 21:15:55+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-protectedtitles	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d634b33530b33eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-shortpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233da0a0a9a999752d00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-uncategorizedcategories	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d13031313634beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-uncategorizedimages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d134303633373eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-uncategorizedpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d1343534b630beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-uncategorizedtemplates	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d132303736333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-unusedcategories	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d132353230b53eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-unusedimages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d136303734b23eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-unusedtemplates	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d136353436313eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-unwatchedpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d13634b534313eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-wantedcategories	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d131353134beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.interface.helpers.styles:en:0cf70578d5e9dac6ec60a41a65351708	\\x5d8ec10ac2300c865f65e4a4b0c9d64a5bd347110f750b58b4eb687b9b7b77333de83c04fe7c211fbfc323ce1e5bebb17b4fc64eb50833f43104d7649a5c72252640a82ba881571acb8d32e52617970a1f767f9cc681e99e69a6e0fbf888e3466457d135b9fe4ee56b39ffc28fe2b28afd449befea59c1025c56f028a58539719076e0e6422aa3843607c9511bbbbc00	2021-06-22 09:19:27+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.misc-authed-curate:en:1ed074e011c2caf56c7a3697b6975102	\\x758f410e82301045afd2342e95d0168b0e4b2f608c1718ca200dd01aca8610ee6e5574c7e227ffcffc37c92064305b480b0be2a3003295c067dee3d05285e189e3e0bb8e2ae7475b4f1cf8bdb1819906dd83d8e8d94eb006032b891cfb422cc63f96f03d7fbb124d7b30ded576e871b4defd42bc78ed0803b175009b84f3b17c4167a8dbec4c1462e9b6eef8c2e35b324a0ba5ce2a1a555420b454faa4657e4a547e9459b1bc00	2021-06-21 18:21:11+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.edittags:en:01e3f8e45d97a4ddcb7bb5cb12d14be8	\\x658d310ec3201004bf82ae0e910d0946c71fd2e405082e01099bc89c2bcb7f0f719b62a42d76763dde70cf38b88ce349c371b0083bb07f374931b30ca9365ae452e54a6d2bdc00e151c5af205e755ba2e0e459cc9e4382cbbff8293e50aa25d2dacd27150a2c5a9de99c8003fab1ea186bd57dea41bb88a351da58a3267bd59355cab8e30b	2021-06-22 15:08:55+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.preferences.ooui:en:bb3ab29028953558defd8f4e8c5622fe	\\x6591c16ac3300c865f4598c12e4b999be265ee13ecdc5d06bdb8891a9b7a76b0958652faee53bc946dec202c197dffff1b1bbdd157a79fb74ecb52596f6aa9c5550c098fb9caae0f86c6849575bdf55c54614a31092d76364e5006f0b135e462104f0b47e690ab60ceae2ff74c0762e4dd0d1a3ee208ad09306604b2081e8f04267490667930ac38c1092f1928c2a28170409a104321667570bf7aef32adeee69349c185be5a4eb665c7c733c2a7e9105a6b428f45fb12c704338209433bdf5943600daf8648ecc87699a70e2e48ab7d783bce08e79d37c8ba0c83e9112647368e04ad77ed890d612f1ee45efc979f9cf78b328c43c7afeae6d0c5a224ff8efa172a717ea2dc81fbfe8e7b7113fc776b2ea594543537f5b6d352ad6bd5a8f54bb3aa1bf9dac8eded0b	2021-06-22 09:00:41+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.revisionDelete:en:dec3a3913d1d84c8cf975557252e3dbe	\\x1dca410a80201046e1abc4ec0b1d6db2dfd348b5102243db8977cf5a7cf0162fc0a246281fa17f056c4195b674a66b2cc71d7278522610066ad41fee44f3aabe307e871636e284173719371b61df5e	2021-06-21 18:13:00+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.search.commonsInterwikiWidget:en:a8e0068cc00875ce14599886df6f8594	\\x358c510ac2301044af22fb6da4c9866dd89ca1870876d5c5c64a52f1a3f4eea6a21f03f398c724f6bc2a7751d97e5339788615aaa472be197d2c52de7a5793e722a6487d4d4b05861d0f7f3cfef467992f3a89d19caeb25b439b35cba8093668ffae85ba1ec9b78271644b0e2990ebc30943b016e3f601	2021-06-21 16:40:42+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.page.ready:en:de67a5d8755ecd3f040f03cadfe6757f	\\x1d8c410ac3300c04bf22746e421cbb72915fd2a34b54230871691c4a09f97b951e863dec309903efca4352767f5626cfb8e35c4bd1a574756bdd529b3ebfc878af1be4b7c043ec82539109ccb8c06b96bc0a7cb2b61e0fb4d46810c5309c6d9f2676347aba91bbc6de36444ac70f	2021-06-22 09:19:17+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.unwatchedPages:en:30dd28d0765aecbf389ffc55fe68f01e	\\x9590cd0e823010845f65b3f1a884b608585e43c3854b956a9b08356df1278477b712540e5e3c4c32b3f9660e2b78c27bcde3427332ca719a641c7b14752deb9bf007e5e5ddaf9c32d623c7ad9270112709152e4885a08483bd942d8c3c78030fd359188b67ed7c844bb4b231d7bfc6a6061cad697e0c76ed18c3c26e729f9b6e4fdf730851f42abcf1728267683903070c3fa041691e33ba0e861535272965699ed22c8fd88610428be109	2021-06-22 12:56:43+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.upload:en:09fcab4aaa44d45db01d81d353b0a38f	\\x5551cb6ec23010fc9595c51150132025e6d44a5555954a55d5deb89864e3ac1a6c6407104df31dfda0fe58d709547058ef7866bc0f59c9a96c48de2c48465d78399dcda46804e6541f943364f4e89485144b547b465097e461ab34c2461d21533b8f70b43ba82d5496b132cc96ca68f41d5faa7db0e6385e99a7a2a39443f66a8d3990197654a60ce4e4d5bac2bec3a9311bf88eb0124d43a6965b87851f8509596cdb95008f594dd680ed6a3b080e746832f463311495721a0baad0a3dba3e345de43f9c000e735f1188e5ba8be4fef0a4a664d417ae778485e4d55953d847a570370b587131a0a4f5f385a1f6bf44c0f22689ad7e5c7dbdd520ea2ef4077876fdbb355935617f6c7fbb3f04995bd109eff850d5ebd7809c281f2ba2c917459f7ecef0f0c62d10afed39823b999a6510093452ea3249e24f324be9d8f27e92c49d345fb07	2021-06-21 15:59:50+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.createaccount:en:4e7bd5888fcae94afa316ee8ec6ad9ad	\\x4d90cb4ec4300c457fc58a5842451f849974cd9e0d0ba46e4ce2aa1ea50924e9f018cdbfe33002b1b06247f79e9b18cd604e6c6e4736ed4f65d3ddef8c3a299b080ba1b5e58656649fe86de3444e19f5506740e712e5acaeff4b434c2b7afec2c23188f4396e09b64c29e04af0cedec30b89f5b0e5420e4a84495d759302b7519d0ad925b0450fc22e896de5e4464242ac880b12163c12845820bf92e5990585709460f717563db5a70fce258befe9f715148a5c8b43fe84ee133854533385474f9809ec12a31c088ee75994a1c0057856b2a24e4a0f5d7ba7a5e947675addf57aa7656d4dbfdf0f7d3b9ebf01	2021-06-22 02:20:34+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-wantedfiles	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d135343030363eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-wantedpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d135353232333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-wantedtemplates	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d133303231333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-allpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d133353231363eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-prefixindex	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d13334b637353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-categories	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d13736353730beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.legacy.protect:en:cdaff2a99116d4d803737c71a50a2a44	\\x2d8c410ac3201045af22b34f51634619cfd103046bc9905645cd2ae4ee95d0c583f7e1f15732743249cfa46e1aa12138a1d4dc63e8d391c2b6729a4aac5f6e8d736a40f04c9f1c76f13e6adf6215ff58e4d2efe082f1a507681dea65c8ec5fa450cf38b6750f23ad54ce5f3f	2021-06-22 12:28:23+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets:en:90f2d6a8a07d09292b08bdd0f8c757fa	\\x8d50cb6e03210cfc15847a68a51285dd0d41ecb1526ffd08026e6495005a1c6d5651febdb07ddcaaf4608fb166c6d8d60ce68a663ba2916b14d3ef76865ff921d8f811ed094ab60eb8e18f6f16e3137fe6a759cce88f4045b89417820b05bba433adcfca7c69708f27de2d864a7ead009e5162adbb62c07c4876f29bfb26e5ec1c94f23514bf7dfed01352008cb96a3d143761264c51449845b6c7b66203e61314161331b86021b600fdcb66028f1338aa363f65fbcc83aceadf33161bdace2ddf78bd775743756ad0ba16fde88d545dafb4eaf67a33c8ad967abc7d02	2021-06-21 21:59:26+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.AbandonEditDialog:en:91e71cb3d29bc983232a2267ffd03f78	\\x7550cb0ac23010fc9590b395be48dbf450447f249ab52eda449a6d8394febb69150f420f03c3320f6695cce58432ae51262b9c4cb34af289773ef2a85b2017a9b332da1ad0485cf2430fec6507e6862ff1ca1023cb1ea046608b0a4dcb3aab8179a49b1d8839352eb72bf68e1abedb088f34ba8bea7528397dd89ae6b60d778067501fad099dc3af7cdb40480ff81bd1f09987ed698048e22a5e9e91d55a2622cd4429d2a2dce7492ee2a29edf	2021-06-21 17:39:38+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.DateInputWidget:en:eeb737376629d6da9647b8c8812eea5d	\\x8d8e310b83301484ff8abcb92989c6685f5657bb770ce65103d188a64811ff7ba34b970e3d38b83bf8e00c4adc1c72ed509c5e50941261836165abb34f8a0bb326921ba7576463380b20dc4376a46c214f5d240b97dfc4e44d477df096e6b4be13f948626dcb9ae61f660863ecbf14ec906ee6c9aaaa393f42a12d0a9517aa5679555fa5b87151eafd03	2021-06-22 12:18:00+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.datetime:en:e0aa3ea0e47ff391fce39fc8029b31b4	\\x4d925f4f833014c5bf4b9f3be3d884a57b321a1f16d94cc0ecd17450370c5052a806977d77ef1fbaf9c0e9ef9cb637979b6ab554e74addaf2b35a7af5771122b7116ba7342894750895cd5ec6005ef8fe840897d3fb04590a23405d8675062d31c8ce380518a4f7380e00594d879ed460e1821751506a0c4a51ed92248f1a55bb01b50e2e9fa6622c83c76bbf135f3c88677e8a66f990d1b03aed1d864aa1d737162072bfa91dcc8fc51dbf6780b2c964c6dcbccada60c52b4f61bec1694380c631b500a5be0f476c5c06cf9c06e22293ae32a5bce7483334e6f4187c11b06bdc60a991e98bde31eb280909a0e0350e221b4915d19721a4d46a3019e6af8e93f8693079b8312bb9ef7f38090568df9b5ad99d5b6d038ff575aff6df8011fc67bfe84a1c7d9e7de3087721349f1634af07b50e2369cd85ff922e0c146f0c5519cccf1052fd6a59ac7d1225ec551b2ba5b460f51b2befc01	2021-06-21 22:03:08+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.CategoryMultiselectWidget:en:7dd073b2861bbd2700d585db817c7f7b	\\x3d8ecd0ac23010845f252c1e144c68fa9396edc94709dda506a32949a04ae9bb1b053d7c739899c367b1c5cd61353ad45f12eaba42d8e0becad5d1cc39c9c9669e437c25f63ce510a525fa9772f176e26bf0c411102e44c28adfa89482334426e9dde326b3cb9ecbe9a0c571b1330b0a9cc42364c14f97f20976281275c174bde93e46cd48a84ddd98c1d4fda0da128d1ef737	2021-06-22 06:38:49+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.SizeFilterWidget:en:b6e48ceeab2e33b866e89471c6fd7c5e	\\x4bb432b1aaceb432b0ceb43204e3622b73532ba56aa5dcc48accdcd25cdde2ccaa54252b25dfc40a0510d34a49472937330f452a330f2c059429484c4f858a6a245596a4166b2ad52a018d35026233631323531320c3d83ac5cad0ccc8d8ccc2ccc8dc42cfc4d80008ad6b01	2021-06-22 00:08:52+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.MediaSearch:en:a9b36c493bba52113ec9ce249c2919fe	\\x7d90c10e82300c407f65593c3a230307295789273de8c9e36455974c4636160ec8bf3b508f7a68d2a6efb54d2564306858971a92393c7091001de8a367bd5637ec3c7ba0d2d2a374f59de9a60d1d6b8dacf16e8d4247819ee616b95a4766942e7fd98d75e883e97cb40e967c8a688646ad7e6b0e6b6c3a165a63a59adc61d855876d758445f23cdbe0c691bc19f265fecc9a7732e9b464465ed0c479fb09206fe27b151d69fc088f21b2342fa6242d152482a7a2103c2f5659caf36c538e2f	2021-06-22 02:47:40+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.widgets.Table:en:405e4abb14d1dc75e496eda1d2b2981c	\\x1d8b410a80201000bf127b37d25d4cd76b1f295c422882143c887f4f3a0c0c03b333714bbc84c4fa2733114383bbaa9ae22925abb21f97a8f7a92aca25458061fb651a0d3a8ccf0cacf62be2100c91b535689d35ab9b09c9791dfa07	2021-06-21 20:06:51+00
WANCache:t:postgres-mediawiki-:valid-tags-db	\\x2bb63232b5520a080d727775b13234333236b330333431d633b530b0b4323454b20600	2022-06-14 15:55:43+00
WANCache:v:postgres-mediawiki-:valid-tags-db	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfd800246e6c9d62656866646c6661666862ac676a616c6a686c5d0b00	2021-06-14 16:00:43+00
WANCache:t:postgres-mediawiki-:tags-usage-statistics	\\x2bb63232b5520a080d727775b13234333236b330333431d633b53035b1323454b20600	2022-06-14 15:55:43+00
WANCache:v:postgres-mediawiki-:tags-usage-statistics	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfd800246e6c9d62656866646c6661666862ac676a616e6161665d0b00	2021-06-14 16:00:43+00
WANCache:v:postgres-mediawiki-:ChangesListSpecialPage-changeTagListSummary:en	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfc2ccc40024636c9d62656866646c6661666862ac676a6169626e665d0b00	2021-06-15 15:55:43+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.watchstar.widgets:en:b849d27c00abf720c87640bab46e588d	\\xbd52cb6ec2400cfc156bc591a0e649baf98c1e38841c4cd6148b6537ca9a4244f9f76e915aa9aae8a9e2606924db33a3b15117fac2faa9619dde2ae8f239d5eaa2d0183227947e47e781c729f183b07721b1b821abb45a7df62c0701e103c140237ba3d5fcd7a6d059e2fc5ab5ad9ea55db75680ce004b00c3a13f86107961c057821dbe116c881cdc48403c4cfe3842dbbe0cd4335afdadfa7efa425d075b3fc22c5bdc114f04edfe8e030cc147628962ffee809da12d3b16b28f08215ee0808e9cd8e96f1f8fc8e38799ab8abf95c5aad23a2ff308f2c6e8b4caf2aaaeb265bd28f2655914cdf503	2021-06-21 19:43:51+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:oojs-ui-widgets:en:805480785a5253ec5f04b88b5d147f03	\\x7d91c16e022110865f85701623bbebaaecd578b387f609b6cb544990212ce8c1f8ee9d059bc6d6f630c9cfccf73124f4aa5157a3169d5132d7a8ea8d54fcca11931126c2490438e119b8e2af25ccca0c53b4c68118d0c580564c33a1f1e288dc536693cc72e33f23f9079e8e7fd03f9e91f12f76040b43fc3016c47b8a11ddbd43f45b0eac67d3f409af437fd001bdf0b61fe0885643206d4badacb02384679ec328c6e43d86089a84ddc496b941c7ccc88860dfc4ef1b1e17be6059476261c8b971fa938aaa9595ac3714ea4e2bd95675bb6eabd57ade348be572d5dd3e01	2021-06-21 18:00:17+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:oojs-ui-toolbars:en:95f32f46a33e3d104160f47c8d3a2126	\\x4bb432b1aaceb432b0ceb43204e3622b4b632ba56aa5fcfcd24cdd92fcfc9ca4c422dddcfca254252b255f10a583904a2fca2f2dd04dcecfc9492c280629704b2d4f2dc254915a519098970233a05609689111109b99189a999a0319c6d62956866646c666166646e6167a262646160646d6b500	2021-06-22 02:12:15+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:oojs-ui-windows:en:86ef3a9ba0fc10cbab1e061d34ed17a2	\\x75d0b10ac2301405d05f29998d681a534d47dd1c1cf40742fa884fdaa4bca49422febb5174913a5cb8c3b9cb355aea3bea558d7afd4ed4422acdee2c84017983a60d8e7710a371c08db5d027a6d9e9c816b382e006f625f6c65b687f544fc166c86df009fd002ff7adf3b2c1d8618c191e3e6dde0151a0accea1837445ef8a117c2a460adefd9910249af2e44253619c41cf1e2c5f207254b9a964954b59377aad44a9b64a54dba59495d889faf104	2021-06-22 00:33:45+00
WANCache:v:global:resourceloader-titleinfo:postgres-mediawiki-:d9d23996dd18d68198e67ffa8ca41fae447c88a6	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfd8cc0024616c9d62656866646c666166686aae676c6464646c6a5d0b00	2021-06-14 16:55:57+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:oojs-ui-core:en:5fb7fe33c7905017844cadc5c281554d	\\x3d8e4d0e82301085af62666d0da5b590e9d28d07f0022d549ca4320d946842b8bbe0dfe2e52dbe972fcfa1c699b0b084f29d1165a91166609e48347cf7ecf929fc9433f7223a1f22205cb8eb62d871cac4fd08fbcffa4a21b6e216625a27e7adbe20719a927850db852c9ac863f809dd40ee6f3d6d0416588f946b4cad8b6a7ba56c8bd294cad4461eab83d24a49699717	2021-06-22 13:57:08+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.api:en:d781fb5b91a0135ca484ab9218d4fa6b	\\x7591c16ec2300c865fc58a761c881628231c77d90e93268d17c888472dc0ee1c178610efbeaced761a074b89adffcbff3bc1cffc85fc6445bee82af95931f1eee24243a3cd9e902d51c411aa8a8ec2bba86174dead6b04c5cf1693c1292418266377ffbfb2366bb2ec0df5889a95d62a63846ee8e169bd7e85bbe2a69af818f6141553239c30839efb0efcb6e043e500a9c3dfc4b06c84193796018fd2ee23b0180c3d3001cba90606bc845dbeb48a709616ea7044087012dd116f81d83007f8139330048e607a86b00dc4373d181d505a1b56d83f06917a2b7d9a0827b29ab8b3835f4de6e755fd08c7eeeaf23795b9aa876555cef361ba8abea8ca69f55015f3c5783a2f17b3e5eafa0d	2021-06-22 15:29:42+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.language:en:3a9f499e2e83e3fb39217173e73ad1c1	\\x558cb10a80300c447fa564aed2d81a25fd9a601d1cb4520587e2bf1bdd1c1e77bc83130e5c17767161fc38b81f192ac89680c1bc6161caeb2acd31ef52e4cc45076b545fb9a49f357083be740a054f8eb4f89818a9f33412f643ab161dc6fb01	2021-06-22 02:42:43+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-listredirects	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d130b034beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-pageswithprop	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d130b33336353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-trackingcategories	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d134b030b13eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.page.watch.ajax:en:bbee7f0b315429b7b961c293bbfe0130	\\xa593cb8e823014865fe5a47139102b036a5d99d9ba9838312e9045875669444a68bd0579f72920488cb3c145c3299cf37dfc5c28f924b920c39920b85a8a4cc62382724419e3ec4c7518697ed188a00df27d32c041b041401306422b60428547a5844c20a53b0e113d71f8e53c816a1cb484ab3c66e0fb3f290f058dc9ba24c642e9dbb9a982c0461f4f3e4bd378ff8f942a250d4b1bfebbd28c1fe4e99d9877006c3379e86ded17b6975a4b196b915a21b58e4975cd789715097424542d7920dbf197b316bfa42213c9ce40f2fc7bb15ace1726c00d03a3d7dba03aa8a280986f3588e40969c3572cc27df9beea2c26f0eb7b6c3d566408cad8e6b0e567a876fde94dfe39639df0cde7d38dfe7856ab7bd59eabd3afda8d6d9796a67d7d6feeb4ae3b8d05323fddc82ccfc5d3a96b0a67c608f6468e37f1b03bb69db1e30ef1acf803	2021-06-22 05:02:32+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-userlogin	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d134b33630beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-createaccount	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d530343334353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-changecredentials	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d5303530b7343eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-removecredentials	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d5343030b5333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-activeusers	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d534353434353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-block	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d53430b4b2323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-unblock	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d532323331373eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-blocklist	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d53230b230363eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-autoblocklist	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d536363232363eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-botpasswords	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d536373630343eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-passwordreset	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d531343430b0beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-deletedcontributions	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d531353732323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.rcfilters.filters.ui:en:271abc30c5ec5d2163a78f0d213a2d59	\\x9d58516fdb3610fe2b8417a0291079759aa6a9f3301459b61648b722ed060cc80b2dd116619a54492aae91e6bfef3b9292655b76b23d24b6c9bbe3f178f7dd47f2f1d9f8418e5f5dcaf128fcb9f19bb3b377e3c1c3802b55f19970135e78e995188c075f4bc166f25e6846332c0cb325774cea7bae64c18c65252f18d718f1c2668aeb594da29888234b3997acb2622abf0feff447cf167cc572a33d979a191d2417c60a9697dcf21c2a8ef9927b9673ad8d6713c16a270a588bcbbbe1e06430c13a73cd17c2553c27478f3fc1dc4bccc031613d463e862fcc0925722f8dc65cabe030ffc7fac7c9e05b6d3c27a96cc1ed9ca6ef0647a3bb01a66c3e958abccae01c42917e41e47df8cd9a81bda259290bf2f1037d1c96cabc31cacb2a49b3cd2518b7821fb0e04ab384e617fa382cd55987a49f5ea7b8e73a174567f369a47ffb4ad1090bed1d326222142928c59ac16de142babc760ef1df94ef8c6fa8e44a704b8ad9daa12b1a6318ebf5a8e05e6495a9ea2a6b735b2e04ab8495a660de2051b8cdcb2da5550a177d83cad1883d3c7cbef9ebf6fdcdf868f403a3f4e71e1ff7a895a6b63d7a341cfef56a36fedd8a1cb16261e9ae9058547e95364e796c18df38bd216b426de5a4a6a40e07cac8233ddc34f53d5735b20e621eb96fa65318bc8e83a97244715043b70a52cffa55e267a359ac57e815232f95d473e49a358b361b4296022134f009a811e0c8b128c848f219b64c152abc317957bf7af5faca796bf42c7cbffebc6d348afcdc950136ad4313dc38bcb237cfd803c5ce9b270dfd870d448bffd77f259dcfa64214139ecfc91c958b4056d58e2d099b57a686214c303e31b527a3ae49c0b8b4516e9f610db477b5f22e666f033a5353ebbe94083a4d51fcd653db1d3172cec13132fd01d12e4c726d69ecfc970dad99350083e4493659652116e3c1ef34ced2389bac766354ca59a9f0e7531134be7d68c61bed7e2d5134a89591cf5d45518cd9d1a85f6d21749d954205cc0ee7c738aa5ca17d02bd5a313a16877e6b806c7e75c054e3f5a6ad4d0582a86d3c8a98d6154b5c600d491f133948035d592517d2675c1711919b54de02c85824e9032079c28e4e0f9989c05e48aecc2ce356f2d670cc97ee71ea7a31c18899b6a50833a0166d33e859681d826886dac576935580e0ba22775c424728dc102ea7d127a4e32209837f95ae52e0495aac1183132f122bf0adaa12fa99d6c889afb505d39a4e99dae74d5b9119dac654c9dcc7d26cc2164a134c2ce7a0620941a85bb2dc4aaa781e1a0c185aabdeb56ea0605169f75244e241d5f9270db238d80317df6a99cfd7cdfd0bbfdf4335ba821962968bd2a802eb15c2c1bb809814039c186c1070d964077bf01e601513c08ab4b50553888f3d613936320f9b9d1833275ec824f6178868d94bcd4e10226596c3e739d8245507025dd8e64a6cc60fa7e07140d8d194e3383a9ce736ceb034d31ba060f35b8d5312c4e38a4cd32934c54f31c96b6ba9b2b7c272c08ac2668b551c8cb704b711099624e28686ec2aa4700c7e1b7514510e290fe990e7f18c63c10e0f2c5e556a154a1f969a9034e57e150d6ec6e3295b5bca4f29e5c47bd55a2bfcdc2f9e7c6949c0de4cded0a243a2eb4abb0c5d579e21de4930829150039358b2556d2b837302f2d1cfa7b669c5c2dc8b6044097f606de40ef946d9a80f3ab93eafd0763c215a33b057a9d61b6ab7c1abbd9a0195b682905a4003a3c754e7d401e9e299606c6a5a50a02dbc7cc268b63013b9978e04e64f07925684d8df04725d2c771249b3ddea9da75e865ba903e3c8a6355da270878db424b669e2569d2b4ec422f4fb40669874119bb1058a906b5534eed927cc99289c765a42441b26a653480d59e43df08ba8b9dbe1219bceb97a826309a5bfc760db2d24fa47d347629788e49f2da52fe15037258d027cc26100a9351c91eeb082d31f7199f40156c08ebd5dad994fe49d7467a4afb57425d67eb9b311cf67597c8ec8ba0f08e3678865f1712160de2ef91e6be3fb08f77ec3f84ad9f1538f445b7d29e15f1c8d5e6c09d999f081b46ee5fb353dbb0053c38b0df9ce8e91de398e6f66ec6a33b7434b5e3f8b749e057a88531bad1d0b5678700c68b73d6a6de836ccd1c92ce8c527e50a15e0ae9d1490af7c36438288426e71e8562810e18cda7167a51b14aa8e6f49f156f20c3b7b375c3bca275265c1abaefa92fbbc0cf70d9aeffc6c79df35e9857647e394df4128ddb8f6590b6f4f42e8b59d4fc43aa8e03b249024c840a0e3691c78e3e98a43705d0b0a36675ee4a59639574c586b4068f49ad0e5a65644e898a2324387feac0427fe8382426e42ac0ce5446d030e0f77d74b8c31f297c6bba2b68d5a7a358ccf2b0bda62ba893594b1cf664cea7411dbcd639ceabd886f35a25dd30ae26be109273c1bf6fb4bfc1e29d12056c27d422c9a2918e686ec1fdc6ae9757249d841f6108d4202ce023d4a3a15b7f0253cb460959844cd8b1225cae3e0528e4ff177fef6dd9bd139bebcbe2cc6a3f3d3d7e717e7a76f2f86afdfbcbdb838bb7cfc17	2021-06-22 12:43:14+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-preferences	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d53134b630333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-resettokens	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d535323206d5d0b00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-contributions	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d5353530b0b23eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-listgrouprights	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d533343535353eb5a00	2021-06-15 15:57:12+00
WANCache:t:postgres-mediawiki-:user-quicktouched:id:1	\\x2bb63232b5520a080d727775b13234333236b330333435d3b3343134b7323454b20600	2022-06-14 15:55:56+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-listgrants	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d53333333230beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Editnotice-0	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a9aeb1998181a9a9858d70200	2021-06-15 15:55:57+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Editnotice-0-Main_Page	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b5998199a9aeb1998981a58985ad70200	2021-06-15 15:55:57+00
postgres-mediawiki-:MWSession:qu8mrckcdd8vt0sv8k1ubin3php26k1p	\\x95914d4ec3301085ef9213d8a9ffbb42b0a08b964a2d62c366624f8a95a6a96c17901077c74e4861c186e5bc79f3c6f3194c6d3ea261a67290a05a8251a5a6dc546f718731fae1b4431b3055cb6816b5a994724c52c9c842db4659860e95544a374a32ad5b517cf5eff16dd3b9b65e250c907219aba5379410428b3107de5cd2cb1a4e70c0608e1053a9576e741587fedbb1f73dc604fd79348a7a2194a05ce40955763f460cabbb394416693f74789aafa08c49c5485b0b6084009342b4503b4264432ca1aef828999336d06351f25937aef7630a65d7d009502cf468a197d7396ce172bc4293a0a9629c22e14273a62da004ab6ccd2de18ab36af9f939bebcc704f34fe4fd1fa3780ec3ab7718c6b4cc638dcec393effcf337e2e7db61e83ccec07fd9a9f8195f5fb337b9931b9702e94a5a4dc25fb7eaa9f56f823932608f7d531ed318f20db51d82c5fbfd7ebb9bd54c0cdfcf3e60fcf94e2db99c761f87c301ddc325952699b43386e86342572268c6f705	2021-06-14 16:55:57+00
WANCache:v:global:resourceloader-titleinfo:postgres-mediawiki-:f48c031f78d2bbbece0c4a4c48f1b09de2862852	\\x4bb432b1aaceb432b0ceb43204e3442b03abeada4c2b2320cfd8cc0024616c9d62656866646c666166686aae6768646e66606e5d0b00	2021-06-14 16:55:57+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-listusers	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d53730353134beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-userrights	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d5373630b0b43eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-passwordpolicies	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d53730b533333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-newimages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d530b2313434beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-log	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d530b534b5313eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-watchlist	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d530b4b635343eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-newpages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d534b135343eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-recentchanges	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d534b4b437353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-recentchangeslinked	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d33036343634beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-tags	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d330373034373eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-listfiles	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d3343434b2373eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mediastatistics	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d3343530b0b4beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mimesearch	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d33434b734353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-fileduplicatesearch	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d20616a68625d0b00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-upload	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d33230b337333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-listduplicatedfiles	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d336363734b0beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-apisandbox	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d33637373634beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-statistics	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d331343130b33eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-allmessages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d331333736373eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-version	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d335303735343eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-linksearch	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d335313534353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-randompage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d333303037363eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-randomincategory	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d33335373434beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-randomredirect	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d3373434b1373eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-randomrootpage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d337333534353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mostlinkedcategories	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d330b43634b73eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mostimages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d2065626c5d0b00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mostinterwikis	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d334b03634353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mostlinked	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d334b530b2333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mostlinkedtemplates	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d7303430b53eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mostcategories	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d7303530b73eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mostrevisions	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d734303736373eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-comparepages	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d7343530b53eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-export	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d73230343430beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-import	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d732313031333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-undelete	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d73234b134313eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-whatlinkshere	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d736313634b0beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-mergehistory	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d73630b430b73eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-expandtemplates	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d731323434323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-changecontentmodel	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d7313534b4b73eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-booksources	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d73134b13434beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-diff-form	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d735323332323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-editpage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d735353a08c752d00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-pagehistory	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d733343037333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-pageinfo	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d7333530b5323eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-purge	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d737303230353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-newsection	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d737313035333eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-permanentlink	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d7373734b0b0beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-redirect	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d730b4373630beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-search	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d730b53132353eb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-specialpagegroup-changeemail	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d730b4b23030beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:messages-big:f6c4f725a607bfe8fa0cf0c05ee4f470:Specialpages-helppage	\\x4bb432b1aaceb432b0ceb43204e3622b43232b25453f7f3fd708cfe01057bf1025a0b811105b98991880d4195ba758199a19199b590009233d734b13334beb5a00	2021-06-15 15:57:12+00
WANCache:v:postgres-mediawiki-:preprocess-hash:0a204779610ffde1806547dfc112ff79:0	\\xb557db4e2249187e953f642e7692a61b7074669135c1b333a22ca0c6a8314577419734559daa6a18dcddbbcdbecbdeedd53cc09a7daffdaa1b189d939acc6880aaeafff0fd5ffd0760f557f5df44bdb22eead5fc65ea2babb5d7f552a5f8ab5d5c94b452b6e45d941a718d44f4cb65693c2d4fb83642c97222422e0dbf2c6db47824d89918093a2cce1a415cdb6844624261c28c815e9a302113214706f2d7d747c7bde3adebeb4bd98b85a1a953c567aaa65cf388fa336a18ab951c6e5cc4d6a6a61e04d3e9d41f3b3f4ed8577a18d0d2ed5523988b7b14aa74a6c530b6f4efdf54ab54aae55aa556a5161bcacce0439a11f7685323023a15fd3ed71e1d724edb4c0a9ed09656e1c89df5c498ba9669601e7ab4a3c5885a771f92c43ddb637ded84cf44e88cddfd35619a9a5a0e6eee3ee8bb7f68f386e931334a7a74244660800ed97b20bcfb30f6685be111b584cd6e99f1a8a3fab415673a8c3d3acfb4a02604d92866506eea198f694ff3a182d7264388d40de32cb9c54e469a4f01456b6e2dec30315632a26eca47a31c7333e1ef9993a29db1e132cef258bb82f7358e41c52d4fb0f0e09e45b4afb48a15778098a477cc5a954d4183e613a5a9cdb40959e2889be1710f5c230409cc5d36a60ee730732a420bd153664422f8c459b27c8c943008b39d30aba488b871d0ad1292532b3346e54c2bbcddc46ae02daee19d90b739d56fb9565cd2b6bb2087675303eb5b0534f0bdc9b455e696b66f059faafffe342381ab0207080b49ea514be5f704ce94b50977a71ebdcb244b903cb165b0cfc6dcd0b64fbb0a441aeb04901c88f14c2503006a4608b01b2b5d7055f24a1717e038142ca99f1695106c21698535bf2b1be3e4ea8a1cbfcbccc5754a83f0799eb992dbc02d82defc1877555f66f2c2147da6b43c41ec57fea5bc940feaebf3ba2c0b39500f8a131536d04875a30676ca345fa799ca2844acce29d24ef433cb4958873fc0558e55240633779039ea08e111181a1b52837cb37774427b5c720d42db591f9e171d8090e3a93b317151d04e7cd779efcebd83715845fc4aae13178e3a9a8740b58583b9358f80e627661d604d2a754a2f8172468ea2a55e4ecb83783f86159190b9c958a588228631c4351549427d4e99e1830ce90d496af0f1c6d9416ffff8a447cda3733a6b763acda3de7923c08375a8d858418c4f7861508c53e47b44080a5764670efba27db5763a5bfb506e6e1e1c1e3813f37317cf4266f7a077b4d3edd2ee71879ad46e767a075b2787cd0eb54f3aede3eece52c9a72ee78ff13ec8ef0df446dc3291989c9373dcb301ea24a2984d38ee3be462c2e7498a1c4d14aa3b56c6065bc7edf383a33d6279277dfca291ec89eb068e1688ba2eaed550b3f13a89014985d634d5026965d53773c0a30319fa1ead5621c2e4087d17fd17c230b02b0630be9b28d7063781d289b79a84c65ead94ab2b95aa4727dda623f5a2981468f6f98c98d78209541295979b619a946b7ec58fed380117e8284805e5c613bff21b01ea6aa37847917d61f02dea07c575208d65180ad1b2a88ad167593fe1cbe274355c9cdc1f83855d33b96faf61359c5edae2bf61e38db6565116da4680f5c327f3eef3e00936cec043334e3c7af22485e827aaa8220da489d54058f55756fdca27624f719bc669defca8bddf7edccd6b7fc5afada2e65316c6bc867118611ebc7c865ff7b505f327751d026b6c0446803b15d2d6177719f5cb29126a88de5fce7452bac29f57a27671d6fdf5f0098c00e933f9001d0635e18b302ba35c6e78688b8b40e53fee706dc5af7ec56190a7d9c697b2964bab672906af755fc176dc8ef22d9d740ecd73d3f6cb86cbb93864eec1458b96436cb89ce73772f7abcfefc1caf3fa5bb2805dc804b951f7fa6696e7537731ba5bb34398cad89007f84e98e1e4c574d8d45684096f33789daf29c5a6b81267be11aa886f7cde3505e6e37b1f291ebca8d2831d74739dc2c47783da0db5486d8eb4583e1128053f02d032605aae9ec1d93dc27e0438968adccbfcf371600b85e0a3c67707e5be6be64e168bc7612d55827b3a9f029b3700d7c74af85157c3ebcddaab8afb91b7b21ed5ab6bb595b537787bed5757ab3fafacfff13f	2021-06-15 15:57:17+00
WANCache:v:global:user:id:postgres-mediawiki-:1	\\x6d90c16ec3200c86df85079830248638a7a8ea61971ea6be8015d88ad6245342a44955df7dc0cab4493b00e6fbeddf06a6966e81641f08ca620245b78d3489e9d989c2b69424a6134f5e7cc7839bc29ce32ef117cfd7aa4912f9c0848f1387eb2f66133b2ffb78f12e5fa121a1a40289d040db42d3d5c2f3f2ee8bb95624000d36cc129c75acddabb26035833206479d78b1ea6abb618f173fc73072cc5d4e59842afef83e0602fb47397e7e84d56f8f2a5d1ef616b6b8720ccbfcefc8b650996d5c8887659f632124647df130c665adff780fa4526074da74ef085069b4a88c7d0244a331f13667627fff02	2021-06-14 15:59:11+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:jquery.confirmable:en:0e66522d242595cb343f4a7191b58641	\\x5d8e310bc2301484ff4a7938b6d2244d5a5e06112c6e1ddc1ca38d10d046128b9498ffee435c74b8e3f8b88333d86072586b87eca3888cd70809ce7ebab87033a7abadbe1910b6c11629edfb61d71f70c55e8b9f732ee21cec06ca9fcde4a93ef83fbad848f8485ec2d387b18af66e8279f840b8800c7482939490b29114841e91292e54a778dbad795b7329757e03	2021-06-22 00:30:23+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.feedback:en:4dcb13d123d0106f822b2472aeb1a7fe	\\x95545d4f1b3110fc2bcb298f7022094ae8f1443f45a5aa558107043cf8ec4de2e2b323db474811ffbd635f935e0055ad94cbadbcbbb3e3ddd913d551f5a8abc3135d0df313aae1f8cda82a1e8b19b3aa85bc3b104a693b2faae2341bb4715074b414732ecbb2d8ff139efe10fc36bdfac7ed5c2e38bb3e7916718f3eb721523ea3b81091347e81ac8b240c22d49a9c6572337899ae0743bab36e650940e1b67c066d7905e0b30e8e5549df79e93c90089e94f22cde79d4e19432a3b56b4978a6ae262ea53848af6b467664b9b05a0a434bef6ac30d690b7f141a278645e898f94d3540df9637f62b28fb950ebc9fd1a5b0d422345d04396b9a39df50cdc6ad4aba72ad27e99a866da49536865265a558252e292535996e8aebc19806a3db9b621f0d7218c44ac745c2f709dc5bd1f04e5b5055b2c11ddf7546df655c48b77f8f0ef7cf9506f2fc40dbe81ddc577fe79ef885b66e30b8cc6203f31f771a0cfff93abfb9451d4da27ede15deb8fb91ecbdf343c47c48464597d6b37473ab7fa2bee7d01ae479d7d0e9b7b3177947fd3c819167993b4815efb9be67db5b80cca58ff0101373932476d08902668cce02f5a336bb928a22ecf06e3804b405a15f3aabea7bd1e91f2c6377f5643df7a21ddbbef45da0d484bc1dad55ec431456751bd7ac73ab09a530276dd36845d4cec296a6c51eec1c8adab539891f848c547bb7cad980734bf608c214c33a44acc93d0ae51c383702080bac99a2655b1b2dcdba1b7bd08a13e6563c2fa8bb599bc57a069e9ebb7978779ff2b693c0560a299d5749ea9d9292ca2e527efa845c865d31e1faf62e35e5221b7b9d62b7700b114018a34e837f651147341862115f81dcea33032739eff58352bb73b71171b96d7d553c15f8fa8ef04ca6e3f1740a637ca2aae164349e1c4f46d3e312cfd1e1e8e4e917	2021-06-22 11:00:55+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.htmlform:en:87aae6a3d20a24b31993b5cb638a1c64	\\x1d8c410ac3201000bf227baea56aaa667d465f20c6a2605c89de42fe1edbc3c01c86f1b8e099f1e5328a3f1d8d42382150a1ca7b6cfef0830e4040060f48632f5f3a761e12f558792b3ec444658bbfe4134b0c83f9caa88d4c152e985339d1ef7559cd14e536145a2a6db534f629ad30c2baeb06	2021-06-22 07:09:35+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.ForeignUpload:en:bb36660cdb75ce155469babe5104acf4	\\x5d505b8e83300cbc8a95ef8220b06914fe7b82bd40b6046a15c53431da5655efbede52b4ab7e587ecc68c6b677adbba3ab3a74f533b2d31f8d5377b5cc13f9bee8d14f344acafe6b0abd72ea80538015cdb0648c23f00933ac4cf029c0c6068a2bf68d672cd56e131d28051c6371f4918b7526c29f1b1324476238521c705c920831bd2c6110fbfcdbf329400a97256416c24bf209cb78a68c4ce9f667baedc4e1caef57fcdfb9540f259fd012c6d6a66aa568baded54637c61abdb7a5b6b6aadbeef103	2021-06-22 13:18:02+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.Upload.BookletLayout:en:4804b89f484ce91b5b17cbc3dd057643	\\x95565d6fdb3614fd2b8411a01b6079b1d3a589f2942de95e8ab6289a8721c9c3b544cb842552e3475c23f17fdfb9242d3b6bd66c011c5322efd7b9e71e9acab7e5a32a8f2f54398d1f57cede9e9d97a3c711555e195d84be35548fca515a08bf544e2c542b47e311f5aa90d61a5b04bdd266ad8b3559ad7483e337e98dc86f4a71373a9ade8d26c92c5975c1f9b96c4dd3c85a6918fd6982e097622e457a2d9416de88a3e933c35eda4e3987fc6aa995acb3696df41b2f96f420c5fec4de7c4e35559574ae68ac09bd83d5d7a514a950b18183686ae55f413acfb19d6855a7780927c149eb389fc7c7cf1f6ebe5c7e288f664f1e0ea2b727a3a5300b31bc70db6db90fcc8869ea2462becf4b447328546a512d493729c81e25b6286ad94a842f6aa0af2af26c7f19e1170aa57bbc6bd96ce88af8e9f6b63c9adedfff1cddf7563e28135cbb4991b2bfc99d66bcdcd284b6467859ade0827c74f1c6a5630c0adc7a63d978612c50b5a692dcab86835a99d921941f3296df60e29e25fc75480edf2486ad1d5c0bd3b666cd4ef7c84e9fd820fe6320b3f7e47c8fc15af965aa3d029ab605b55652bd198bbe95e464aeef2e1c1f9ffceebc35ba89ebeb8c54daf8e57047a80572f9e3fae3d5f597f209ccd86e05a17e6dbc70010bec335fd6a43d23911ac830dce9db5b24ef97a19bdfdfe7b439b9022428d08e85fa96791753de41c0d5b0478e9240653ce6b251daa532bfcf3f71e585f4c762bd54d532c1ad31c4b5749555bd570f39acdff44c1dd08230248d06f92878d391cfafe71b51ab4679d0ab82812587d23eeff034065f243ae6c477bec1142ec5c6a226871044548a3c069115ad312b1eb215bb8bdb9a1418ad3c4c458e579b08fc2040f914868798b72622e838f45aadd4447cc2b35d2b27070600f401e698a3336816e3134be824b1462d423b16a46b04942e868c7ac086fbd4520b7765f5d4ec49c94d1dd0c0f0f06644633f9d3c93999e79f4b1667dc1ecfd1f828ec53c78a4f8e21854c15a6803ba985243e7383517ba8e30cb4c336c4b0bbbb68d7552df4bb282c5f2851ad8de888e5632f575e7285b31da803ace437428939475a443e41204c3ffeb6cacc96551da8f751c8a5d35834a1e6859a202c3866eb930772cd9b1e21f0a9c841ebf2c65838e096a48696e2f0e7859c11743e0e537bfe36c6ceb4156f918bbe1149147ac983da3f786e1c9778c63bf29548124baa2255c7f85d20b131f0f8047b0ab83a7ff6a5678635aaf7a98ff66955c44447817172a52b31be08abcd0739a03689a1bd08881591bbb0268ef9131897e69bc19632c74e400ef77c417311bbb7453501c7da8084a1fc723a6aa882fdcb1889407c42d55f29592b3187ce4af570f1e547729825668fa33f989b291272e0dfb4e092331717fe3104fe0200413117f72d0866f774e1855b6d0f2c03d8e63e57a14e126e22a8990d2551b6ab9176d10436a2efb9542636eb1ab9eb5ebc5c3c1216cf18f9f0a710a7e707ce7f8869f46db117ec6cdf0393d3e3f9ebdc3e2e4a22ea7a7b393d3b3d3d9bbb3c9ec1c7fbf5e6cff06	2021-06-21 17:08:25+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.rcfilters.filters.dm:en:0d53b732dd4354dcf315000ccb1c6401	\\x258ccd0ac2301084df65f068a4f96113b6779fa297a01516a3c5647b2a7d77a33d7cccc0374ce6c09bf0300adb3f8d2932367cd645b3caf236af5c9f0d8c09273b0167d4db438aceb599238b34352a5ae6beba1e0a3bfa9deb50a4e47fc58f77b6e43c2572315d7c1842b4e3fe05	2021-06-22 11:58:30+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.apisandbox:en:6be5f1a850e5df716082f5a0273b8595	\\x9d587f4fdb4618fe2aa714699d84131218ed8cfa07629dba095a0654fb035075b12fc92de73befee4cb080efbee7bdb3131c02a59348629fdfdf3f9ef7353cdd4bef64ba7320d361f8b8746ff87e37edddf5b8ce7b698fd1cf768f973299185b709f9456785f97566a9f38cf7de5407631938e59e14aa39d600b53a99c8d054e7c65b5c8d942fa19fb747171ca220bdb1ab2ad51bf913c13aa4c4a6e79911495f2327182eebc80e4f3e692dd70550917255d553b3bbb47f3711e2e3edec7fbc1f28019cb2e2fcf4b9149aed2c3527e828641c1a57e435f839cc38aba14ee9e2b2face65ede88ebebc61e079fc7e636e1791eed81198779bef65009eb9389142a0ffe37063233619e82119e305c68e3e991ccd7a50701259f9297bf13b5634647663a65dc8a679933a3bdd415b11eb5971b09924c096e892cfc6ea6a1f883e4ee0e394d37103c3c20ec4ab1cb99f7a54b0783c562d12f442ef942ce65dfd8e9802e066dc04fea63aea7159c181c9efe91fe55095bbf69ec947afaed5f1c48e4b2957f0daf0553dc79540c1e3a7fc09e35267ad49a146e5a4148a3d189150af592b3505002e9756bc1cb056a38239a644503ff7f5b9e3fe25d63ad352f6496086b8d4dc4ad749e380f570c0c041070d5db1a5ea17b94153caf59a45cb7a311d631028526c90daebe6bc4ea792855c5c74245092bd6f455aca5e2999819950b2a95d38e2f5d01e29617a51264e9c7f6b24330113e9b25decc85265b2a6fd024481465389e76c8a9f42aab481ef5285352cfd724a20eacc1f3af409655777883a096a8a342681f518154442470e0d0d388052754a77fa33cd9428c9913f6466682a12e1bd0784cdbbfd2676202c721fdf2b258a4cf54f409402498714f3a71c2729355644928c1eb6b06b06493cae2b165b9f05c2a47d040a49503639f35e14bff6f575d20b416e76f0ebf394992425bd5f090db6c160c8881921e496280ee6c86e6639c65001e72602eea85b1f9759f9d0b25320fac673c2307c87f27042b0c30a84d398273a53f1b4f59e07e1bb5ed67a69ace6252f0c75993b2ed468c63b5a958c62dcc3295efc25bc16bc8cfe5a40e890b3e7713af0ccf63a7512569162e99c9b2ca5a9a2933a9801a2022b7a48ef389ac27df29d2105f8124f6628a81f3543e5821fcf8b542fafd0d368213a0e33029a88ccf4426e40d4923eee6fc095f982b61626010a8841acd9568429280d9f8f6102db33afcf945e638191f31c68335266dba401346f62307679c66d5f3a819e7b39285f4d4fc9af0616d0e17fcf6c924462555a17129e3b7b2a80a1664ac496f70bf5d32fe7100f216d0fe3cfff2f9456a00c892f8ebd9316b1ac15bcaee46c68efcb378c8484fba99de850669d4b57ce733b3680716a3958271f70cbf074c3dd244b72946dce9f1d7b3c3e3746b788fd415eee16133f763ff5a11f0f3892e27fce649ffb83ae3d5a6c7afeeb516f4629cdbb50f0d367c92d52878226fdb89706420105813ee69bb0c2d32a6aa7a91359900436953c20f0c42598549d30eda40f38c7665a65227ae2a31de9d13f96a5f8da1a4ca1f0b58535a93050a24126806be297604422e94b0a543e9b16b34cb6de5a21de3bae40e12ac5910d539da27f96225740243113fe9eb3e5be2e632788d953f4113909c40276b8232c3134571ce8d88fb23607a4ed661dea93a0e3b57c1f9c603b7cd00d01c6dd68eda0250867ec34aa454fd242cded6a114e8b7f3c809dda059901bd6ef70d26059387d82654dfad2de099f8b966a130946795866e3daec12c09b8bfbef69343f6b8b23a0859d23c09134140acc657c8ac9b551ffbaf030f7c8035388a5148cb386ac2bc20b8cb8ee46882070a0445b2c2fbd4e2cb903b3bb5fdeafd0142b81a40d00cb058ec79c6a278c43d1818180dcf11b68401b437c4b1a2baee7cb79009bded20a42089f99a2e0ed0b53e8de6d86e3a038384aa7f10d2bbe5b018543aa2216ebaa18a368a1a879bf82955d5c82196f5727a3fbad114e6838664a62e1415095320bb8339353da7602babb9ffbcf1841af5d49d4da9872b11683e1871885d187651c8a0a6d3aa6d72136455a68f4a09734dbda7d951aa97f580df61dd7e818bd52c70f7b33167e41b0b3350ae5fd1d67e238a3988d6b1fc6fd11d7040e6302663d5dc664d8d14fc4e10b9a5f293f9b71fb6af9448c6d4fd8d555a38976cb4e61b2de43ef40a6237cf6777efd6587fee3b07b90a7c3fdd1eefefbfdd1bbf7fddd77a39dbdbd8387ff00	2021-06-21 17:16:19+00
WANCache:v:postgres-mediawiki-:MessageBlobStore:mediawiki.special.watchlist:en:49cb898b5130f1959a94811ddb0437e2	\\xa593cf6e824010875f65b2f1d6620409a5ebc9f4eaa1b1697a400e5b769589c81276fd17e439fa407db18e58a931f68287cd0e99ccf7f1db05c17d5e211f8c90bbcd323c1c069c554c48a9e456d824b56a671967331645bce7c6f18c81c825a03520d1246b6350e750888582546c147c2a9543330e56c35eaf4b88a2b742252832fe71246668ec617baee2b8cf1eaf7c8e15d9f21fa9304613cb12ff5e69a9567a734fcc5f00cc4bbdea6ced16b693da6a9d592c9c4438ebbce99177da90c0a6684e923f643b7e73d651bb024bcc1704a9aad7c9fb743ca1000717a4d81f7acd66ea1a3235b780f915b20f2f1926cbe37d9db250e0dbefd87a9c9408866c6398ab2d344fdde9e7fc63292fc29f3f9fcbe86d7d716adf5fb71ab44b4ddd075633faa13c5ac120f0429f8ae1487237f0864118784f61df1ff8beff3caa7f00	2021-06-21 16:22:42+00
postgres-mediawiki-:specialversion-ext-version-text:/var/www/html/skins/MonoBook/skin.json:	\\x4bb432b6aaceb432b04e02e24c2b436b3f206904246b01	2021-06-15 15:58:54+00
postgres-mediawiki-:specialversion-ext-version-text:/var/www/html/skins/Timeless/skin.json:	\\x4bb432b6aaceb432b04e02e24c2b436b3f206904246b01	2021-06-15 15:58:54+00
postgres-mediawiki-:specialversion-ext-version-text:/var/www/html/skins/Vector/skin.json:	\\x4bb432b6aaceb432b04e02e24c2b436b3f206904246b01	2021-06-15 15:58:54+00
\.


--
-- Data for Name: oldimage; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.oldimage (oi_name, oi_archive_name, oi_size, oi_width, oi_height, oi_bits, oi_description_id, oi_actor, oi_timestamp, oi_metadata, oi_media_type, oi_major_mime, oi_minor_mime, oi_deleted, oi_sha1) FROM stdin;
\.


--
-- Data for Name: page; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.page (page_id, page_namespace, page_title, page_restrictions, page_is_redirect, page_is_new, page_random, page_touched, page_links_updated, page_latest, page_len, page_content_model, page_lang, titlevector) FROM stdin;
1	0	Main_Page		0	1	0.22978693996900	2021-06-14 15:51:48+00	\N	1	735	wikitext	\N	'main':1 'page':2
\.


--
-- Data for Name: page_props; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.page_props (pp_page, pp_propname, pp_value, pp_sortkey) FROM stdin;
\.


--
-- Data for Name: page_restrictions; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.page_restrictions (pr_id, pr_page, pr_type, pr_level, pr_cascade, pr_user, pr_expiry) FROM stdin;
\.


--
-- Data for Name: pagecontent; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.pagecontent (old_id, old_text, old_flags, textvector) FROM stdin;
1	<strong>MediaWiki has been installed.</strong>\n\nConsult the [https://www.mediawiki.org/wiki/Special:MyLanguage/Help:Contents User's Guide] for information on using the wiki software.\n\n== Getting started ==\n* [https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:Configuration_settings Configuration settings list]\n* [https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:FAQ MediaWiki FAQ]\n* [https://lists.wikimedia.org/mailman/listinfo/mediawiki-announce MediaWiki release mailing list]\n* [https://www.mediawiki.org/wiki/Special:MyLanguage/Localisation#Translation_resources Localise MediaWiki for your language]\n* [https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:Combating_spam Learn how to combat spam on your wiki]	utf-8	'/mailman/listinfo/mediawiki-announce':35 '/wiki/special:mylanguage/help:contents':9 '/wiki/special:mylanguage/localisation#translation_resources':42 '/wiki/special:mylanguage/manual:combating_spam':50 '/wiki/special:mylanguage/manual:configuration_settings':24 '/wiki/special:mylanguage/manual:faq':30 'combat':54 'configur':25 'consult':5 'faq':32 'get':20 'guid':12 'inform':14 'instal':4 'languag':47 'learn':51 'list':27,39 'lists.wikimedia.org':34 'lists.wikimedia.org/mailman/listinfo/mediawiki-announce':33 'localis':43 'mail':38 'mediawiki':1,31,36,44 'releas':37 'set':26 'softwar':19 'spam':55 'start':21 'use':16 'user':10 'wiki':18,58 'www.mediawiki.org':8,23,29,41,49 'www.mediawiki.org/wiki/special:mylanguage/help:contents':7 'www.mediawiki.org/wiki/special:mylanguage/localisation#translation_resources':40 'www.mediawiki.org/wiki/special:mylanguage/manual:combating_spam':48 'www.mediawiki.org/wiki/special:mylanguage/manual:configuration_settings':22 'www.mediawiki.org/wiki/special:mylanguage/manual:faq':28
\.


--
-- Data for Name: pagelinks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.pagelinks (pl_from, pl_from_namespace, pl_namespace, pl_title) FROM stdin;
\.


--
-- Data for Name: protected_titles; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.protected_titles (pt_namespace, pt_title, pt_user, pt_reason_id, pt_timestamp, pt_expiry, pt_create_perm) FROM stdin;
\.


--
-- Data for Name: querycache; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.querycache (qc_type, qc_value, qc_namespace, qc_title) FROM stdin;
\.


--
-- Data for Name: querycache_info; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.querycache_info (qci_type, qci_timestamp) FROM stdin;
\.


--
-- Data for Name: querycachetwo; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.querycachetwo (qcc_type, qcc_value, qcc_namespace, qcc_title, qcc_namespacetwo, qcc_titletwo) FROM stdin;
\.


--
-- Data for Name: recentchanges; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.recentchanges (rc_id, rc_timestamp, rc_actor, rc_namespace, rc_title, rc_comment_id, rc_minor, rc_bot, rc_new, rc_cur_id, rc_this_oldid, rc_last_oldid, rc_type, rc_source, rc_patrolled, rc_ip, rc_old_len, rc_new_len, rc_deleted, rc_logid, rc_log_type, rc_log_action, rc_params) FROM stdin;
\.


--
-- Data for Name: redirect; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.redirect (rd_from, rd_namespace, rd_title, rd_interwiki, rd_fragment) FROM stdin;
\.


--
-- Data for Name: revision; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.revision (rev_id, rev_page, rev_comment_id, rev_actor, rev_timestamp, rev_minor_edit, rev_deleted, rev_len, rev_parent_id, rev_sha1) FROM stdin;
1	1	0	0	2021-06-14 15:51:48+00	0	0	735	0	a5wehuldd0go2uniagwvx66n6c80irq
\.


--
-- Data for Name: revision_actor_temp; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.revision_actor_temp (revactor_rev, revactor_actor, revactor_timestamp, revactor_page) FROM stdin;
1	2	2021-06-14 15:51:48+00	1
\.


--
-- Data for Name: revision_comment_temp; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.revision_comment_temp (revcomment_rev, revcomment_comment_id) FROM stdin;
1	1
\.


--
-- Data for Name: site_identifiers; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.site_identifiers (si_type, si_key, si_site) FROM stdin;
\.


--
-- Data for Name: site_stats; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.site_stats (ss_row_id, ss_total_edits, ss_good_articles, ss_total_pages, ss_users, ss_active_users, ss_images) FROM stdin;
1	0	0	0	1	0	0
\.


--
-- Data for Name: sites; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.sites (site_id, site_global_key, site_type, site_group, site_source, site_language, site_protocol, site_domain, site_data, site_forward, site_config) FROM stdin;
\.


--
-- Data for Name: slot_roles; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.slot_roles (role_id, role_name) FROM stdin;
1	main
\.


--
-- Data for Name: slots; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.slots (slot_revision_id, slot_role_id, slot_content_id, slot_origin) FROM stdin;
1	1	1	1
\.


--
-- Data for Name: templatelinks; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.templatelinks (tl_from, tl_from_namespace, tl_namespace, tl_title) FROM stdin;
\.


--
-- Data for Name: updatelog; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.updatelog (ul_key, ul_value) FROM stdin;
filearchive-fa_major_mime-patch-fa_major_mime-chemical.sql	\N
image-img_major_mime-patch-img_major_mime-chemical.sql	\N
oldimage-oi_major_mime-patch-oi_major_mime-chemical.sql	\N
user_groups-ug_group-patch-ug_group-length-increase-255.sql	\N
user_former_groups-ufg_group-patch-ufg_group-length-increase-255.sql	\N
user_properties-up_property-patch-up_property.sql	\N
patch-textsearch_bug66650.sql	\N
MigrateComments	\N
MigrateActors	\N
site_stats-patch-site_stats-modify.sql	\N
populate externallinks.el_index_60	\N
DeduplicateArchiveRevId	\N
PopulateContentTables	\N
PopulateChangeTagDef	\N
DeleteDefaultMessages	\N
populate rev_len and ar_len	\N
populate rev_sha1	\N
populate img_sha1	\N
fix protocol-relative URLs in externallinks	\N
populate fa_sha1	\N
populate *_from_namespace	\N
FixDefaultJsonContentPages	\N
cleanup empty categories	\N
AddRFCandPMIDInterwiki	\N
populate pp_sortkey	\N
populate ip_changes	\N
RefreshExternallinksIndex v1+IDN	\N
PingBack	8f69b9db1634936d32fdb85703e98822
Pingback-1.35.0	1623686142
\.


--
-- Data for Name: uploadstash; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.uploadstash (us_id, us_user, us_key, us_orig_path, us_path, us_props, us_source_type, us_timestamp, us_status, us_chunk_inx, us_size, us_sha1, us_mime, us_media_type, us_image_width, us_image_height, us_image_bits) FROM stdin;
\.


--
-- Data for Name: user_former_groups; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.user_former_groups (ufg_user, ufg_group) FROM stdin;
\.


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.user_groups (ug_user, ug_group, ug_expiry) FROM stdin;
1	sysop	\N
1	bureaucrat	\N
1	interface-admin	\N
\.


--
-- Data for Name: user_newtalk; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.user_newtalk (user_id, user_ip, user_last_timestamp) FROM stdin;
\.


--
-- Data for Name: user_properties; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.user_properties (up_user, up_property, up_value) FROM stdin;
\.


--
-- Data for Name: watchlist; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.watchlist (wl_id, wl_user, wl_namespace, wl_title, wl_notificationtimestamp) FROM stdin;
\.


--
-- Data for Name: watchlist_expiry; Type: TABLE DATA; Schema: mediawiki; Owner: postgres
--

COPY mediawiki.watchlist_expiry (we_item, we_expiry) FROM stdin;
\.


--
-- Name: actor_actor_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.actor_actor_id_seq', 4, true);


--
-- Name: archive_ar_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.archive_ar_id_seq', 1, false);


--
-- Name: category_cat_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.category_cat_id_seq', 1, false);


--
-- Name: change_tag_ct_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.change_tag_ct_id_seq', 1, false);


--
-- Name: change_tag_def_ctd_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.change_tag_def_ctd_id_seq', 1, false);


--
-- Name: comment_comment_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.comment_comment_id_seq', 1, true);


--
-- Name: content_content_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.content_content_id_seq', 1, true);


--
-- Name: content_models_model_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.content_models_model_id_seq', 1, true);


--
-- Name: externallinks_el_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.externallinks_el_id_seq', 1, false);


--
-- Name: filearchive_fa_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.filearchive_fa_id_seq', 1, false);


--
-- Name: ip_changes_ipc_rev_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.ip_changes_ipc_rev_id_seq', 1, false);


--
-- Name: ipblocks_ipb_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.ipblocks_ipb_id_seq', 1, false);


--
-- Name: job_job_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.job_job_id_seq', 1, false);


--
-- Name: logging_log_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.logging_log_id_seq', 1, true);


--
-- Name: page_page_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.page_page_id_seq', 1, true);


--
-- Name: page_restrictions_pr_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.page_restrictions_pr_id_seq', 1, false);


--
-- Name: recentchanges_rc_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.recentchanges_rc_id_seq', 1, false);


--
-- Name: revision_rev_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.revision_rev_id_seq', 1, true);


--
-- Name: sites_site_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.sites_site_id_seq', 1, false);


--
-- Name: slot_roles_role_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.slot_roles_role_id_seq', 1, true);


--
-- Name: text_old_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.text_old_id_seq', 1, true);


--
-- Name: uploadstash_us_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.uploadstash_us_id_seq', 1, false);


--
-- Name: user_user_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.user_user_id_seq', 2, true);


--
-- Name: watchlist_expiry_we_item_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.watchlist_expiry_we_item_seq', 1, false);


--
-- Name: watchlist_wl_id_seq; Type: SEQUENCE SET; Schema: mediawiki; Owner: postgres
--

SELECT pg_catalog.setval('mediawiki.watchlist_wl_id_seq', 1, false);


--
-- Name: actor actor_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.actor
    ADD CONSTRAINT actor_pkey PRIMARY KEY (actor_id);


--
-- Name: archive archive_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.archive
    ADD CONSTRAINT archive_pkey PRIMARY KEY (ar_id);


--
-- Name: bot_passwords bot_passwords_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.bot_passwords
    ADD CONSTRAINT bot_passwords_pkey PRIMARY KEY (bp_user, bp_app_id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (cat_id);


--
-- Name: change_tag_def change_tag_def_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.change_tag_def
    ADD CONSTRAINT change_tag_def_pkey PRIMARY KEY (ctd_id);


--
-- Name: change_tag change_tag_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.change_tag
    ADD CONSTRAINT change_tag_pkey PRIMARY KEY (ct_id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (comment_id);


--
-- Name: content_models content_models_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.content_models
    ADD CONSTRAINT content_models_pkey PRIMARY KEY (model_id);


--
-- Name: content content_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.content
    ADD CONSTRAINT content_pkey PRIMARY KEY (content_id);


--
-- Name: externallinks externallinks_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.externallinks
    ADD CONSTRAINT externallinks_pkey PRIMARY KEY (el_id);


--
-- Name: filearchive filearchive_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.filearchive
    ADD CONSTRAINT filearchive_pkey PRIMARY KEY (fa_id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (img_name);


--
-- Name: interwiki interwiki_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.interwiki
    ADD CONSTRAINT interwiki_pkey PRIMARY KEY (iw_prefix);


--
-- Name: ip_changes ip_changes_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ip_changes
    ADD CONSTRAINT ip_changes_pkey PRIMARY KEY (ipc_rev_id);


--
-- Name: ipblocks ipblocks_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ipblocks
    ADD CONSTRAINT ipblocks_pkey PRIMARY KEY (ipb_id);


--
-- Name: ipblocks_restrictions ipblocks_restrictions_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ipblocks_restrictions
    ADD CONSTRAINT ipblocks_restrictions_pkey PRIMARY KEY (ir_ipb_id, ir_type, ir_value);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (job_id);


--
-- Name: log_search log_search_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.log_search
    ADD CONSTRAINT log_search_pkey PRIMARY KEY (ls_field, ls_value, ls_log_id);


--
-- Name: logging logging_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.logging
    ADD CONSTRAINT logging_pkey PRIMARY KEY (log_id);


--
-- Name: mwuser mwuser_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.mwuser
    ADD CONSTRAINT mwuser_pkey PRIMARY KEY (user_id);


--
-- Name: mwuser mwuser_user_name_key; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.mwuser
    ADD CONSTRAINT mwuser_user_name_key UNIQUE (user_name);


--
-- Name: objectcache objectcache_keyname_key; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.objectcache
    ADD CONSTRAINT objectcache_keyname_key UNIQUE (keyname);


--
-- Name: page page_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page
    ADD CONSTRAINT page_pkey PRIMARY KEY (page_id);


--
-- Name: page_props page_props_pk; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page_props
    ADD CONSTRAINT page_props_pk PRIMARY KEY (pp_page, pp_propname);


--
-- Name: page_restrictions page_restrictions_pk; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page_restrictions
    ADD CONSTRAINT page_restrictions_pk PRIMARY KEY (pr_page, pr_type);


--
-- Name: page_restrictions page_restrictions_pr_id_key; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page_restrictions
    ADD CONSTRAINT page_restrictions_pr_id_key UNIQUE (pr_id);


--
-- Name: pagecontent pagecontent_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.pagecontent
    ADD CONSTRAINT pagecontent_pkey PRIMARY KEY (old_id);


--
-- Name: protected_titles protected_titles_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.protected_titles
    ADD CONSTRAINT protected_titles_pkey PRIMARY KEY (pt_namespace, pt_title);


--
-- Name: querycache_info querycache_info_qci_type_key; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.querycache_info
    ADD CONSTRAINT querycache_info_qci_type_key UNIQUE (qci_type);


--
-- Name: recentchanges recentchanges_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.recentchanges
    ADD CONSTRAINT recentchanges_pkey PRIMARY KEY (rc_id);


--
-- Name: redirect redirect_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.redirect
    ADD CONSTRAINT redirect_pkey PRIMARY KEY (rd_from);


--
-- Name: revision_actor_temp revision_actor_temp_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.revision_actor_temp
    ADD CONSTRAINT revision_actor_temp_pkey PRIMARY KEY (revactor_rev, revactor_actor);


--
-- Name: revision_comment_temp revision_comment_temp_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.revision_comment_temp
    ADD CONSTRAINT revision_comment_temp_pkey PRIMARY KEY (revcomment_rev, revcomment_comment_id);


--
-- Name: revision revision_rev_id_key; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.revision
    ADD CONSTRAINT revision_rev_id_key UNIQUE (rev_id);


--
-- Name: site_identifiers site_identifiers_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.site_identifiers
    ADD CONSTRAINT site_identifiers_pkey PRIMARY KEY (si_type, si_key);


--
-- Name: site_stats site_stats_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.site_stats
    ADD CONSTRAINT site_stats_pkey PRIMARY KEY (ss_row_id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (site_id);


--
-- Name: slot_roles slot_roles_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.slot_roles
    ADD CONSTRAINT slot_roles_pkey PRIMARY KEY (role_id);


--
-- Name: slots slots_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.slots
    ADD CONSTRAINT slots_pkey PRIMARY KEY (slot_revision_id, slot_role_id);


--
-- Name: updatelog updatelog_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.updatelog
    ADD CONSTRAINT updatelog_pkey PRIMARY KEY (ul_key);


--
-- Name: uploadstash uploadstash_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.uploadstash
    ADD CONSTRAINT uploadstash_pkey PRIMARY KEY (us_id);


--
-- Name: user_former_groups user_former_groups_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.user_former_groups
    ADD CONSTRAINT user_former_groups_pkey PRIMARY KEY (ufg_user, ufg_group);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (ug_user, ug_group);


--
-- Name: watchlist_expiry watchlist_expiry_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.watchlist_expiry
    ADD CONSTRAINT watchlist_expiry_pkey PRIMARY KEY (we_item);


--
-- Name: watchlist watchlist_pkey; Type: CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.watchlist
    ADD CONSTRAINT watchlist_pkey PRIMARY KEY (wl_id);


--
-- Name: actor_name; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX actor_name ON mediawiki.actor USING btree (actor_name);


--
-- Name: actor_user; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX actor_user ON mediawiki.actor USING btree (actor_user);


--
-- Name: ar_revid_uniq; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX ar_revid_uniq ON mediawiki.archive USING btree (ar_rev_id);


--
-- Name: archive_actor; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX archive_actor ON mediawiki.archive USING btree (ar_actor);


--
-- Name: archive_name_title_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX archive_name_title_timestamp ON mediawiki.archive USING btree (ar_namespace, ar_title, ar_timestamp);


--
-- Name: category_pages; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX category_pages ON mediawiki.category USING btree (cat_pages);


--
-- Name: category_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX category_title ON mediawiki.category USING btree (cat_title);


--
-- Name: change_tag_log_tag_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX change_tag_log_tag_id ON mediawiki.change_tag USING btree (ct_log_id, ct_tag_id);


--
-- Name: change_tag_rc_tag_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX change_tag_rc_tag_id ON mediawiki.change_tag USING btree (ct_rc_id, ct_tag_id);


--
-- Name: change_tag_rev_tag_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX change_tag_rev_tag_id ON mediawiki.change_tag USING btree (ct_rev_id, ct_tag_id);


--
-- Name: change_tag_tag_id_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX change_tag_tag_id_id ON mediawiki.change_tag USING btree (ct_tag_id, ct_rc_id, ct_rev_id, ct_log_id);


--
-- Name: cl_from; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX cl_from ON mediawiki.categorylinks USING btree (cl_from, cl_to);


--
-- Name: cl_sortkey; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX cl_sortkey ON mediawiki.categorylinks USING btree (cl_to, cl_sortkey, cl_from);


--
-- Name: comment_hash; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX comment_hash ON mediawiki.comment USING btree (comment_hash);


--
-- Name: ctd_count; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ctd_count ON mediawiki.change_tag_def USING btree (ctd_count);


--
-- Name: ctd_name; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX ctd_name ON mediawiki.change_tag_def USING btree (ctd_name);


--
-- Name: ctd_user_defined; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ctd_user_defined ON mediawiki.change_tag_def USING btree (ctd_user_defined);


--
-- Name: el_from_index_60; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX el_from_index_60 ON mediawiki.externallinks USING btree (el_from, el_index_60, el_id);


--
-- Name: el_index_60; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX el_index_60 ON mediawiki.externallinks USING btree (el_index_60, el_id);


--
-- Name: externallinks_from_to; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX externallinks_from_to ON mediawiki.externallinks USING btree (el_from, el_to);


--
-- Name: externallinks_index; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX externallinks_index ON mediawiki.externallinks USING btree (el_index);


--
-- Name: fa_dupe; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX fa_dupe ON mediawiki.filearchive USING btree (fa_storage_group, fa_storage_key);


--
-- Name: fa_name_time; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX fa_name_time ON mediawiki.filearchive USING btree (fa_name, fa_timestamp);


--
-- Name: fa_notime; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX fa_notime ON mediawiki.filearchive USING btree (fa_deleted_timestamp);


--
-- Name: fa_nouser; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX fa_nouser ON mediawiki.filearchive USING btree (fa_deleted_user);


--
-- Name: fa_sha1; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX fa_sha1 ON mediawiki.filearchive USING btree (fa_sha1);


--
-- Name: il_from; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX il_from ON mediawiki.imagelinks USING btree (il_to, il_from);


--
-- Name: img_sha1; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX img_sha1 ON mediawiki.image USING btree (img_sha1);


--
-- Name: img_size_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX img_size_idx ON mediawiki.image USING btree (img_size);


--
-- Name: img_timestamp_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX img_timestamp_idx ON mediawiki.image USING btree (img_timestamp);


--
-- Name: ipb_address_unique; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX ipb_address_unique ON mediawiki.ipblocks USING btree (ipb_address, ipb_user, ipb_auto);


--
-- Name: ipb_parent_block_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ipb_parent_block_id ON mediawiki.ipblocks USING btree (ipb_parent_block_id);


--
-- Name: ipb_range; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ipb_range ON mediawiki.ipblocks USING btree (ipb_range_start, ipb_range_end);


--
-- Name: ipb_user; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ipb_user ON mediawiki.ipblocks USING btree (ipb_user);


--
-- Name: ipc_hex_time; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ipc_hex_time ON mediawiki.ip_changes USING btree (ipc_hex, ipc_rev_timestamp);


--
-- Name: ipc_rev_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ipc_rev_timestamp ON mediawiki.ip_changes USING btree (ipc_rev_timestamp);


--
-- Name: ir_type_value; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ir_type_value ON mediawiki.ipblocks_restrictions USING btree (ir_type, ir_value);


--
-- Name: iwl_from; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX iwl_from ON mediawiki.iwlinks USING btree (iwl_from, iwl_prefix, iwl_title);


--
-- Name: iwl_prefix_from_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX iwl_prefix_from_title ON mediawiki.iwlinks USING btree (iwl_prefix, iwl_from, iwl_title);


--
-- Name: iwl_prefix_title_from; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX iwl_prefix_title_from ON mediawiki.iwlinks USING btree (iwl_prefix, iwl_title, iwl_from);


--
-- Name: job_cmd_namespace_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX job_cmd_namespace_title ON mediawiki.job USING btree (job_cmd, job_namespace, job_title);


--
-- Name: job_cmd_token; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX job_cmd_token ON mediawiki.job USING btree (job_cmd, job_token, job_random);


--
-- Name: job_cmd_token_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX job_cmd_token_id ON mediawiki.job USING btree (job_cmd, job_token, job_id);


--
-- Name: job_sha1; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX job_sha1 ON mediawiki.job USING btree (job_sha1);


--
-- Name: job_timestamp_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX job_timestamp_idx ON mediawiki.job USING btree (job_timestamp);


--
-- Name: l10n_cache_lc_lang_key; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX l10n_cache_lc_lang_key ON mediawiki.l10n_cache USING btree (lc_lang, lc_key);


--
-- Name: langlinks_lang_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX langlinks_lang_title ON mediawiki.langlinks USING btree (ll_lang, ll_title);


--
-- Name: langlinks_unique; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX langlinks_unique ON mediawiki.langlinks USING btree (ll_from, ll_lang);


--
-- Name: log_type_action; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX log_type_action ON mediawiki.logging USING btree (log_type, log_action, log_timestamp);


--
-- Name: logging_actor_time; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_actor_time ON mediawiki.logging USING btree (log_actor, log_timestamp);


--
-- Name: logging_actor_time_backwards; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_actor_time_backwards ON mediawiki.logging USING btree (log_timestamp, log_actor);


--
-- Name: logging_actor_type_time; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_actor_type_time ON mediawiki.logging USING btree (log_actor, log_type, log_timestamp);


--
-- Name: logging_page_id_time; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_page_id_time ON mediawiki.logging USING btree (log_page, log_timestamp);


--
-- Name: logging_page_time; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_page_time ON mediawiki.logging USING btree (log_namespace, log_title, log_timestamp);


--
-- Name: logging_times; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_times ON mediawiki.logging USING btree (log_timestamp);


--
-- Name: logging_type_action; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_type_action ON mediawiki.logging USING btree (log_type, log_action, log_timestamp);


--
-- Name: logging_type_name; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX logging_type_name ON mediawiki.logging USING btree (log_type, log_timestamp);


--
-- Name: ls_log_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ls_log_id ON mediawiki.log_search USING btree (ls_log_id);


--
-- Name: md_module_skin; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX md_module_skin ON mediawiki.module_deps USING btree (md_module, md_skin);


--
-- Name: model_name; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX model_name ON mediawiki.content_models USING btree (model_name);


--
-- Name: new_name_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX new_name_timestamp ON mediawiki.recentchanges USING btree (rc_new, rc_namespace, rc_timestamp);


--
-- Name: objectcacache_exptime; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX objectcacache_exptime ON mediawiki.objectcache USING btree (exptime);


--
-- Name: oi_name_archive_name; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX oi_name_archive_name ON mediawiki.oldimage USING btree (oi_name, oi_archive_name);


--
-- Name: oi_name_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX oi_name_timestamp ON mediawiki.oldimage USING btree (oi_name, oi_timestamp);


--
-- Name: oi_sha1; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX oi_sha1 ON mediawiki.oldimage USING btree (oi_sha1);


--
-- Name: page_len_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_len_idx ON mediawiki.page USING btree (page_len);


--
-- Name: page_main_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_main_title ON mediawiki.page USING btree (page_title text_pattern_ops) WHERE (page_namespace = 0);


--
-- Name: page_mediawiki_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_mediawiki_title ON mediawiki.page USING btree (page_title text_pattern_ops) WHERE (page_namespace = 8);


--
-- Name: page_project_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_project_title ON mediawiki.page USING btree (page_title text_pattern_ops) WHERE (page_namespace = 4);


--
-- Name: page_random_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_random_idx ON mediawiki.page USING btree (page_random);


--
-- Name: page_talk_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_talk_title ON mediawiki.page USING btree (page_title text_pattern_ops) WHERE (page_namespace = 1);


--
-- Name: page_unique_name; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX page_unique_name ON mediawiki.page USING btree (page_namespace, page_title);


--
-- Name: page_user_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_user_title ON mediawiki.page USING btree (page_title text_pattern_ops) WHERE (page_namespace = 2);


--
-- Name: page_utalk_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX page_utalk_title ON mediawiki.page USING btree (page_title text_pattern_ops) WHERE (page_namespace = 3);


--
-- Name: pagelink_unique; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX pagelink_unique ON mediawiki.pagelinks USING btree (pl_from, pl_namespace, pl_title);


--
-- Name: pagelinks_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX pagelinks_title ON mediawiki.pagelinks USING btree (pl_title);


--
-- Name: pp_propname_page; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX pp_propname_page ON mediawiki.page_props USING btree (pp_propname, pp_page);


--
-- Name: pp_propname_sortkey_page; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX pp_propname_sortkey_page ON mediawiki.page_props USING btree (pp_propname, pp_sortkey, pp_page) WHERE (pp_sortkey IS NOT NULL);


--
-- Name: querycache_type_value; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX querycache_type_value ON mediawiki.querycache USING btree (qc_type, qc_value);


--
-- Name: querycachetwo_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX querycachetwo_title ON mediawiki.querycachetwo USING btree (qcc_type, qcc_namespace, qcc_title);


--
-- Name: querycachetwo_titletwo; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX querycachetwo_titletwo ON mediawiki.querycachetwo USING btree (qcc_type, qcc_namespacetwo, qcc_titletwo);


--
-- Name: querycachetwo_type_value; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX querycachetwo_type_value ON mediawiki.querycachetwo USING btree (qcc_type, qcc_value);


--
-- Name: rc_cur_id; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rc_cur_id ON mediawiki.recentchanges USING btree (rc_cur_id);


--
-- Name: rc_ip; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rc_ip ON mediawiki.recentchanges USING btree (rc_ip);


--
-- Name: rc_name_type_patrolled_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rc_name_type_patrolled_timestamp ON mediawiki.recentchanges USING btree (rc_namespace, rc_type, rc_patrolled, rc_timestamp);


--
-- Name: rc_namespace_title_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rc_namespace_title_timestamp ON mediawiki.recentchanges USING btree (rc_namespace, rc_title, rc_timestamp);


--
-- Name: rc_this_oldid; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rc_this_oldid ON mediawiki.recentchanges USING btree (rc_this_oldid);


--
-- Name: rc_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rc_timestamp ON mediawiki.recentchanges USING btree (rc_timestamp);


--
-- Name: rc_timestamp_bot; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rc_timestamp_bot ON mediawiki.recentchanges USING btree (rc_timestamp) WHERE (rc_bot = 0);


--
-- Name: redirect_ns_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX redirect_ns_title ON mediawiki.redirect USING btree (rd_namespace, rd_title, rd_from);


--
-- Name: rev_actor_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rev_actor_timestamp ON mediawiki.revision USING btree (rev_actor, rev_timestamp, rev_id);


--
-- Name: rev_page_actor_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rev_page_actor_timestamp ON mediawiki.revision USING btree (rev_page, rev_actor, rev_timestamp);


--
-- Name: rev_timestamp_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX rev_timestamp_idx ON mediawiki.revision USING btree (rev_timestamp);


--
-- Name: revactor_actor_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX revactor_actor_timestamp ON mediawiki.revision_actor_temp USING btree (revactor_actor, revactor_timestamp);


--
-- Name: revactor_page_actor_timestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX revactor_page_actor_timestamp ON mediawiki.revision_actor_temp USING btree (revactor_page, revactor_actor, revactor_timestamp);


--
-- Name: revactor_rev; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX revactor_rev ON mediawiki.revision_actor_temp USING btree (revactor_rev);


--
-- Name: revcomment_rev; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX revcomment_rev ON mediawiki.revision_comment_temp USING btree (revcomment_rev);


--
-- Name: revision_unique; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX revision_unique ON mediawiki.revision USING btree (rev_page, rev_id);


--
-- Name: role_name; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX role_name ON mediawiki.slot_roles USING btree (role_name);


--
-- Name: site_domain; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_domain ON mediawiki.sites USING btree (site_domain);


--
-- Name: site_forward; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_forward ON mediawiki.sites USING btree (site_forward);


--
-- Name: site_global_key; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX site_global_key ON mediawiki.sites USING btree (site_global_key);


--
-- Name: site_group; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_group ON mediawiki.sites USING btree (site_group);


--
-- Name: site_ids_key; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_ids_key ON mediawiki.site_identifiers USING btree (si_key);


--
-- Name: site_ids_site; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_ids_site ON mediawiki.site_identifiers USING btree (si_site);


--
-- Name: site_language; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_language ON mediawiki.sites USING btree (site_language);


--
-- Name: site_protocol; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_protocol ON mediawiki.sites USING btree (site_protocol);


--
-- Name: site_source; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_source ON mediawiki.sites USING btree (site_source);


--
-- Name: site_type; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX site_type ON mediawiki.sites USING btree (site_type);


--
-- Name: slot_revision_origin_role; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX slot_revision_origin_role ON mediawiki.slots USING btree (slot_revision_id, slot_origin, slot_role_id);


--
-- Name: templatelinks_from; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX templatelinks_from ON mediawiki.templatelinks USING btree (tl_from);


--
-- Name: templatelinks_unique; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX templatelinks_unique ON mediawiki.templatelinks USING btree (tl_namespace, tl_title, tl_from);


--
-- Name: ts2_page_text; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ts2_page_text ON mediawiki.pagecontent USING gist (textvector);


--
-- Name: ts2_page_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX ts2_page_title ON mediawiki.page USING gist (titlevector);


--
-- Name: us_key_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX us_key_idx ON mediawiki.uploadstash USING btree (us_key);


--
-- Name: us_timestamp_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX us_timestamp_idx ON mediawiki.uploadstash USING btree (us_timestamp);


--
-- Name: us_user_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX us_user_idx ON mediawiki.uploadstash USING btree (us_user);


--
-- Name: user_email_token_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX user_email_token_idx ON mediawiki.mwuser USING btree (user_email_token);


--
-- Name: user_groups_expiry; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX user_groups_expiry ON mediawiki.user_groups USING btree (ug_expiry);


--
-- Name: user_groups_group; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX user_groups_group ON mediawiki.user_groups USING btree (ug_group);


--
-- Name: user_newtalk_id_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX user_newtalk_id_idx ON mediawiki.user_newtalk USING btree (user_id);


--
-- Name: user_newtalk_ip_idx; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX user_newtalk_ip_idx ON mediawiki.user_newtalk USING btree (user_ip);


--
-- Name: user_properties_property; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX user_properties_property ON mediawiki.user_properties USING btree (up_property);


--
-- Name: user_properties_user_property; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX user_properties_user_property ON mediawiki.user_properties USING btree (up_user, up_property);


--
-- Name: we_expiry; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX we_expiry ON mediawiki.watchlist_expiry USING btree (we_expiry);


--
-- Name: wl_user; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX wl_user ON mediawiki.watchlist USING btree (wl_user);


--
-- Name: wl_user_namespace_title; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE UNIQUE INDEX wl_user_namespace_title ON mediawiki.watchlist USING btree (wl_namespace, wl_title, wl_user);


--
-- Name: wl_user_notificationtimestamp; Type: INDEX; Schema: mediawiki; Owner: postgres
--

CREATE INDEX wl_user_notificationtimestamp ON mediawiki.watchlist USING btree (wl_user, wl_notificationtimestamp);


--
-- Name: page page_deleted; Type: TRIGGER; Schema: mediawiki; Owner: postgres
--

CREATE TRIGGER page_deleted AFTER DELETE ON mediawiki.page FOR EACH ROW EXECUTE FUNCTION mediawiki.page_deleted();


--
-- Name: pagecontent ts2_page_text; Type: TRIGGER; Schema: mediawiki; Owner: postgres
--

CREATE TRIGGER ts2_page_text BEFORE INSERT OR UPDATE ON mediawiki.pagecontent FOR EACH ROW EXECUTE FUNCTION mediawiki.ts2_page_text();


--
-- Name: page ts2_page_title; Type: TRIGGER; Schema: mediawiki; Owner: postgres
--

CREATE TRIGGER ts2_page_title BEFORE INSERT OR UPDATE ON mediawiki.page FOR EACH ROW EXECUTE FUNCTION mediawiki.ts2_page_title();


--
-- Name: categorylinks categorylinks_cl_from_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.categorylinks
    ADD CONSTRAINT categorylinks_cl_from_fkey FOREIGN KEY (cl_from) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: externallinks externallinks_el_from_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.externallinks
    ADD CONSTRAINT externallinks_el_from_fkey FOREIGN KEY (el_from) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: filearchive filearchive_fa_deleted_user_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.filearchive
    ADD CONSTRAINT filearchive_fa_deleted_user_fkey FOREIGN KEY (fa_deleted_user) REFERENCES mediawiki.mwuser(user_id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;


--
-- Name: imagelinks imagelinks_il_from_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.imagelinks
    ADD CONSTRAINT imagelinks_il_from_fkey FOREIGN KEY (il_from) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ipblocks ipblocks_ipb_parent_block_id_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ipblocks
    ADD CONSTRAINT ipblocks_ipb_parent_block_id_fkey FOREIGN KEY (ipb_parent_block_id) REFERENCES mediawiki.ipblocks(ipb_id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ipblocks ipblocks_ipb_user_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ipblocks
    ADD CONSTRAINT ipblocks_ipb_user_fkey FOREIGN KEY (ipb_user) REFERENCES mediawiki.mwuser(user_id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ipblocks_restrictions ipblocks_restrictions_ir_ipb_id_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.ipblocks_restrictions
    ADD CONSTRAINT ipblocks_restrictions_ir_ipb_id_fkey FOREIGN KEY (ir_ipb_id) REFERENCES mediawiki.ipblocks(ipb_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: langlinks langlinks_ll_from_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.langlinks
    ADD CONSTRAINT langlinks_ll_from_fkey FOREIGN KEY (ll_from) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: oldimage oldimage_oi_name_fkey_cascaded; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.oldimage
    ADD CONSTRAINT oldimage_oi_name_fkey_cascaded FOREIGN KEY (oi_name) REFERENCES mediawiki.image(img_name) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: page_props page_props_pp_page_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page_props
    ADD CONSTRAINT page_props_pp_page_fkey FOREIGN KEY (pp_page) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: page_restrictions page_restrictions_pr_page_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.page_restrictions
    ADD CONSTRAINT page_restrictions_pr_page_fkey FOREIGN KEY (pr_page) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pagelinks pagelinks_pl_from_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.pagelinks
    ADD CONSTRAINT pagelinks_pl_from_fkey FOREIGN KEY (pl_from) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: protected_titles protected_titles_pt_user_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.protected_titles
    ADD CONSTRAINT protected_titles_pt_user_fkey FOREIGN KEY (pt_user) REFERENCES mediawiki.mwuser(user_id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;


--
-- Name: redirect redirect_rd_from_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.redirect
    ADD CONSTRAINT redirect_rd_from_fkey FOREIGN KEY (rd_from) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: revision_actor_temp revision_actor_temp_revactor_page_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.revision_actor_temp
    ADD CONSTRAINT revision_actor_temp_revactor_page_fkey FOREIGN KEY (revactor_page) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: revision revision_rev_page_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.revision
    ADD CONSTRAINT revision_rev_page_fkey FOREIGN KEY (rev_page) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: templatelinks templatelinks_tl_from_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.templatelinks
    ADD CONSTRAINT templatelinks_tl_from_fkey FOREIGN KEY (tl_from) REFERENCES mediawiki.page(page_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_groups user_groups_ug_user_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.user_groups
    ADD CONSTRAINT user_groups_ug_user_fkey FOREIGN KEY (ug_user) REFERENCES mediawiki.mwuser(user_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_newtalk user_newtalk_user_id_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.user_newtalk
    ADD CONSTRAINT user_newtalk_user_id_fkey FOREIGN KEY (user_id) REFERENCES mediawiki.mwuser(user_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_properties user_properties_up_user_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.user_properties
    ADD CONSTRAINT user_properties_up_user_fkey FOREIGN KEY (up_user) REFERENCES mediawiki.mwuser(user_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: watchlist watchlist_wl_user_fkey; Type: FK CONSTRAINT; Schema: mediawiki; Owner: postgres
--

ALTER TABLE ONLY mediawiki.watchlist
    ADD CONSTRAINT watchlist_wl_user_fkey FOREIGN KEY (wl_user) REFERENCES mediawiki.mwuser(user_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

