-- Database: test

-- DROP DATABASE test;

CREATE DATABASE test
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'English_United States.1252'
       LC_CTYPE = 'English_United States.1252'
       CONNECTION LIMIT = -1;


-- Table: public.dicomdata

-- DROP TABLE public.dicomdata;

CREATE TABLE public.dicomdata
(
  suid character varying(100) NOT NULL,
  seriesuid character varying(100) NOT NULL,
  sopuid character varying(100) NOT NULL,
  header jsonb,
  report jsonb,
  CONSTRAINT dicomdata_pkey PRIMARY KEY (suid, seriesuid, sopuid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.dicomdata
  OWNER TO postgres;