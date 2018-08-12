--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5
-- Dumped by pg_dump version 10.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: getknowledge(integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getknowledge(knowledgeids integer[]) RETURNS TABLE("knowledgeId" integer, name character varying)
    LANGUAGE plpgsql
    AS $$
begin	
	return query
		select knowledge."knowledgeId", knowledge."name"
		from public.knowledge
		where knowledgeIds isnull or knowledge."knowledgeId" = any (knowledgeIds);
end;
$$;


--
-- Name: getknowledgemodels(integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getknowledgemodels(knowledgemodelids integer[]) RETURNS TABLE("knowledgeModelId" integer, name character varying, alpha numeric, percentiles integer, "percentilesToTake" integer)
    LANGUAGE plpgsql
    AS $$
begin	
	return query
		select
			"knowledgeModel"."knowledgeModelId",
			"knowledgeModel".name,
			"knowledgeModel".alpha,
			"knowledgeModel".percentiles,
			"knowledgeModel"."percentilesToTake"
		from public."knowledgeModel"
		where knowledgeModelIds isnull or "knowledgeModel"."knowledgeModelId" = any(knowledgeModelIds);
end;
$$;


--
-- Name: getsentiments(integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getsentiments(sentimentids integer[]) RETURNS TABLE("sentimentId" integer, name character varying)
    LANGUAGE plpgsql
    AS $$
begin	
	return query
		select sentiment."sentimentId", sentiment."name"
		from public.sentiment
		where sentimentIds isnull or sentiment."sentimentId" = ANY(sentimentIds);
end;
$$;


--
-- Name: insertknowledge(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insertknowledge(knowledgename character varying) RETURNS TABLE("knowledgeId" integer, name character varying)
    LANGUAGE plpgsql
    AS $$
begin
	INSERT INTO public.knowledge ("name") VALUES(knowledgeName);
	
	return query
		select knowledge."knowledgeId", knowledge."name"
		from public.knowledge
		where knowledge."name" = knowledgeName;
end;
$$;


--
-- Name: insertknowledgemodel(character varying, numeric, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insertknowledgemodel(namevalue character varying, alphavalue numeric, percentilesvalue integer, percentilestotakevalue integer) RETURNS TABLE("knowledgeModelId" integer, name character varying, alpha numeric, percentiles integer, "percentilesToTake" integer)
    LANGUAGE plpgsql
    AS $$
begin
	INSERT INTO public."knowledgeModel" (name, alpha, percentiles, "percentilesToTake")
	VALUES(nameValue, alphaValue, percentilesValue, percentilesToTakeValue);
	
	return query
		SELECT
			"knowledgeModel"."knowledgeModelId",
			"knowledgeModel".name,
			"knowledgeModel".alpha,
			"knowledgeModel".percentiles,
			"knowledgeModel"."percentilesToTake"
		FROM public."knowledgeModel"
		where "knowledgeModel".name = nameValue;

end;
$$;


--
-- Name: insertsentiment(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insertsentiment(sentimentname character varying) RETURNS TABLE("sentimentId" integer, name character varying)
    LANGUAGE plpgsql
    AS $$
begin
	INSERT INTO public.sentiment ("name") VALUES(sentimentName);
	
	return query
		select sentiment."sentimentId", sentiment."name"
		from public.sentiment
		where sentiment."name" = sentimentName;
end;
$$;


--
-- Name: updateknowledge(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.updateknowledge(knowledgeidvalue integer, knowledgename character varying) RETURNS TABLE("knowledgeId" integer, name character varying)
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE public.knowledge
	SET "name"=coalesce(knowledgeName, knowledge.name)
	WHERE knowledge."knowledgeId"=knowledgeIdValue;

	
	return query
		select knowledge."knowledgeId", knowledge."name"
		from public.knowledge
		where knowledge."knowledgeId" = knowledgeIdValue;
end;
$$;


--
-- Name: updateknowledgemodel(integer, character varying, numeric, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.updateknowledgemodel(knowledgemodelidvalue integer, namevalue character varying, alphavalue numeric, percentilesvalue integer, percentilestotakevalue integer) RETURNS TABLE("knowledgeModelId" integer, name character varying, alpha numeric, percentiles integer, "percentilesToTake" integer)
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE public."knowledgeModel"
	SET
		"name"=coalesce(nameValue, "knowledgeModel".name),
		alpha=coalesce(alphaValue, "knowledgeModel".alpha),
		percentiles=coalesce(percentilesValue, "knowledgeModel".percentiles),
		"percentilesToTake"=coalesce(percentilesToTakeValue, "knowledgeModel"."percentilesToTake")
	WHERE "knowledgeModel"."knowledgeModelId"=knowledgeModelIdValue;


	
	return query
		SELECT
			"knowledgeModel"."knowledgeModelId",
			"knowledgeModel"."name",
			"knowledgeModel".alpha,
			"knowledgeModel".percentiles,
			"knowledgeModel"."percentilesToTake"
		from public."knowledgeModel"
		where "knowledgeModel"."knowledgeModelId" = knowledgeModelIdValue;
end;
$$;


--
-- Name: updatesentiment(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.updatesentiment(sentimentidvalue integer, sentimentname character varying) RETURNS TABLE("sentimentId" integer, name character varying)
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE public.sentiment
	SET "name"=coalesce(sentimentName, sentiment.name)
	WHERE sentiment."sentimentId"=sentimentIdValue;

	return query
		select sentiment."sentimentId", sentiment."name"
		from public.sentiment
		where sentiment."sentimentId" = sentimentIdValue;
end;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: knowledge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge (
    "knowledgeId" integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: knowledgeHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."knowledgeHistory" (
    "knowledgeId" integer NOT NULL,
    "sentimentId" integer NOT NULL,
    "knowledgeModelId" integer NOT NULL,
    word character varying(255) NOT NULL,
    occurrence bigint NOT NULL
);


--
-- Name: knowledgeModel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."knowledgeModel" (
    "knowledgeModelId" integer NOT NULL,
    name character varying(255) NOT NULL,
    alpha numeric(3,2) NOT NULL,
    percentiles integer NOT NULL,
    "percentilesToTake" integer NOT NULL
);


--
-- Name: knowledgeModel_knowledgeModelId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."knowledgeModel_knowledgeModelId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledgeModel_knowledgeModelId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."knowledgeModel_knowledgeModelId_seq" OWNED BY public."knowledgeModel"."knowledgeModelId";


--
-- Name: knowledge_knowledgeId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."knowledge_knowledgeId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_knowledgeId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."knowledge_knowledgeId_seq" OWNED BY public.knowledge."knowledgeId";


--
-- Name: sentiment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sentiment (
    "sentimentId" integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: sentiment_sentimentId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."sentiment_sentimentId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sentiment_sentimentId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."sentiment_sentimentId_seq" OWNED BY public.sentiment."sentimentId";


--
-- Name: knowledge knowledgeId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge ALTER COLUMN "knowledgeId" SET DEFAULT nextval('public."knowledge_knowledgeId_seq"'::regclass);


--
-- Name: knowledgeModel knowledgeModelId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."knowledgeModel" ALTER COLUMN "knowledgeModelId" SET DEFAULT nextval('public."knowledgeModel_knowledgeModelId_seq"'::regclass);


--
-- Name: sentiment sentimentId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sentiment ALTER COLUMN "sentimentId" SET DEFAULT nextval('public."sentiment_sentimentId_seq"'::regclass);


--
-- Name: knowledgeHistory knowledgeId_sentimentId_word; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."knowledgeHistory"
    ADD CONSTRAINT "knowledgeId_sentimentId_word" PRIMARY KEY ("sentimentId", "knowledgeId", "knowledgeModelId", word);


--
-- Name: knowledgeModel knowledgeModel_alpha_percentiles_percentilesToTake_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."knowledgeModel"
    ADD CONSTRAINT "knowledgeModel_alpha_percentiles_percentilesToTake_key" UNIQUE (alpha, percentiles, "percentilesToTake");


--
-- Name: knowledgeModel knowledgeModel_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."knowledgeModel"
    ADD CONSTRAINT "knowledgeModel_name_key" UNIQUE (name);


--
-- Name: knowledgeModel knowledgeModel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."knowledgeModel"
    ADD CONSTRAINT "knowledgeModel_pkey" PRIMARY KEY ("knowledgeModelId");


--
-- Name: knowledge knowledge_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge
    ADD CONSTRAINT knowledge_name_key UNIQUE (name);


--
-- Name: knowledge knowledge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge
    ADD CONSTRAINT knowledge_pkey PRIMARY KEY ("knowledgeId");


--
-- Name: sentiment sentiment_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sentiment
    ADD CONSTRAINT sentiment_name_key UNIQUE (name);


--
-- Name: sentiment sentiment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sentiment
    ADD CONSTRAINT sentiment_pkey PRIMARY KEY ("sentimentId");


--
-- PostgreSQL database dump complete
--

