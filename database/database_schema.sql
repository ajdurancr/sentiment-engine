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
-- Name: improveknowledgehistoryoutput; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.improveknowledgehistoryoutput AS (
	"newKnowledgeHistory" text,
	"updatedKnowledgeHistory" text
);


--
-- Name: knowledgehistoryrecordinput; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.knowledgehistoryrecordinput AS (
	"sentimentId" integer,
	"knowledgeId" integer,
	"knowledgeModelId" integer,
	word text,
	occurrence bigint
);


--
-- Name: knowledgehistoryrow; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.knowledgehistoryrow AS (
	"sentimentId" integer,
	"knowledgeId" integer,
	"knowledgeModelId" integer,
	word character varying,
	occurrence bigint,
	persist boolean,
	acknowledged boolean,
	"createdAt" timestamp without time zone,
	"updatedAt" timestamp without time zone
);


--
-- Name: rawknowledgehistoryinput; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.rawknowledgehistoryinput AS (
	"sentimentId" integer,
	"knowledgeId" integer,
	"knowledgeModelId" integer,
	words text
);


--
-- Name: decodeknowledgehistoryinput(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.decodeknowledgehistoryinput(knowledgehistoryrecords text) RETURNS SETOF public.knowledgehistoryrecordinput
    LANGUAGE plpgsql
    AS $$
begin
	return query
		select khr."sentimentId", khr."knowledgeId", khr."knowledgeModelId", lower(khr.word) as word, khr.occurrence 
		from json_populate_recordset(null::knowledgeHistoryRecordInput, knowledgeHistoryRecords::json) as khr;
end;
$$;


--
-- Name: encodeknowledgehistoryinput(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.encodeknowledgehistoryinput(rawknowledgehistoryrecords text) RETURNS TABLE(encondedknowledgehistoryinput text)
    LANGUAGE plpgsql
    AS $$
begin
	return query
		with knwoledgeHistoryInput as (
			select
				rawInput."sentimentId",
				rawInput."knowledgeId",
				rawInput."knowledgeModelId",
				lower(trim(jsonb_array_elements(rawInput.words::jsonb)::text, '"')) as word,
				sum(1) as occurrence
			from json_populate_recordset(null::rawKnowledgeHistoryInput, rawKnowledgeHistoryRecords::json) as rawInput
			group by rawInput."sentimentId", rawInput."knowledgeId", rawInput."knowledgeModelId", word
		)
		select array_to_json(array_agg(knwoledgeHistoryInput))::text as encondedKnowledgeHistoryInput FROM knwoledgeHistoryInput;
end;
$$;


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
-- Name: improveautomatedknowledgehistory(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.improveautomatedknowledgehistory(knowledgehistoryrecords text) RETURNS SETOF public.improveknowledgehistoryoutput
    LANGUAGE plpgsql
    AS $$
begin
	return query
		select * from improveKnowledgeHistoryWithEncodedInput((select * from encodeKnowledgeHistoryInput(knowledgeHistoryRecords)), false);		
end;
$$;


--
-- Name: improveknowledgehistory(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.improveknowledgehistory(knowledgehistoryrecords text) RETURNS SETOF public.improveknowledgehistoryoutput
    LANGUAGE plpgsql
    AS $$
begin
	return query
		select * from improveKnowledgeHistoryWithEncodedInput((select * from encodeKnowledgeHistoryInput(knowledgeHistoryRecords)), true);		
end;
$$;


--
-- Name: improveknowledgehistorywithencodedinput(text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.improveknowledgehistorywithencodedinput(encodedknowledgehistoryinput text, persistvalue boolean) RETURNS SETOF public.improveknowledgehistoryoutput
    LANGUAGE plpgsql
    AS $$
DECLARE persistMode boolean = case when(persistValue isnull) then false else persistValue end;
begin
	CREATE TEMPORARY TABLE newKnowledgeHistory (
		"knowledgeId" integer,
	    "sentimentId" integer,
		"knowledgeModelId" integer,
	    word varchar(255),
	    occurrence bigint
	) ON COMMIT DROP;

	INSERT INTO newKnowledgeHistory select * from decodeKnowledgeHistoryInput(encodedKnowledgeHistoryInput);

	return query 
		select
			(select array_to_json(array_agg(newKnowledgeHistory))::text from newKnowledgeHistory) as "newKnowledgeHistory",
			(
				select array_to_json(array_agg(updatedKnowledgeHistory))::text
				from (
					select * from updateKnowledgeHistory((select array_to_json(array_agg(newKnowledgeHistory)) FROM newKnowledgeHistory)::text, persistMode)
				) as updatedKnowledgeHistory
			) as "updatedKnowledgeHistory";
		
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
-- Name: updateknowledgehistory(text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.updateknowledgehistory(knowledgehistoryrecords text, persistvalue boolean) RETURNS SETOF public.knowledgehistoryrow
    LANGUAGE plpgsql
    AS $$
DECLARE persistMode boolean = case when(persistValue isnull) then false else persistValue end;
begin
	CREATE TEMPORARY TABLE knowledgeHistoryInput (
		"knowledgeId" integer,
	    "sentimentId" integer,
		"knowledgeModelId" integer,
	    word varchar(255),
	    occurrence bigint
	) ON COMMIT DROP;

	INSERT INTO knowledgeHistoryInput select * from decodeKnowledgeHistoryInput(knowledgeHistoryRecords);

	INSERT INTO "knowledgeHistory" as khTable ("knowledgeId", "sentimentId", "knowledgeModelId", word, occurrence, persist, acknowledged)
	(
		select
			khinputTable."knowledgeId",
			khinputTable."sentimentId",
			khinputTable."knowledgeModelId",
			khinputTable.word,
			khinputTable.occurrence,
			persistMode,
			persistMode
		from knowledgeHistoryInput as khinputTable
	)
	on conflict on constraint "sentimentId_knowledgeId_knowledgeModelId_word_persist"
	do update
	set
		occurrence = case when (persistMode = false and khTable.acknowledged = true) then 0 else khTable.occurrence end + excluded.occurrence,
		acknowledged = persistMode,
		"updatedAt" = current_timestamp;

	return query
		select khTable.*
		from knowledgeHistoryInput as khInput
		inner join "knowledgeHistory" as khTable
			on khInput."knowledgeId" = khTable."knowledgeId"
				and khInput."sentimentId" = khTable."sentimentId"
				and khInput."knowledgeModelId" = khTable."knowledgeModelId"
				and khInput.word = khTable.word
		where khTable.persist = persistMode;
end;
$$;


--
-- Name: updateknowledgehistoryfromautomatedknowledge(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.updateknowledgehistoryfromautomatedknowledge() RETURNS SETOF public.improveknowledgehistoryoutput
    LANGUAGE plpgsql
    AS $$
begin
	CREATE TEMPORARY TABLE automatedKnowledge (
		"knowledgeId" integer,
	    "sentimentId" integer,
		"knowledgeModelId" integer,
	    word varchar(255),
	    occurrence bigint
	) ON COMMIT DROP;

	INSERT INTO automatedKnowledge
		select kh."knowledgeId", kh."sentimentId", kh."knowledgeModelId", kh.word, kh.occurrence
		from "knowledgeHistory" as kh
		where kh.persist = false and kh.acknowledged = false;

	update "knowledgeHistory" as kh
	set acknowledged = true,
		"updatedAt" = current_timestamp
	from automatedKnowledge as ak
	where
		kh."sentimentId" = ak."sentimentId"
		and kh."knowledgeId" = ak."knowledgeId"
		and kh."knowledgeModelId" = ak."knowledgeModelId"
		and kh.word = ak.word
		and kh.persist = false;

	return query
		select * from improveKnowledgeHistoryWithEncodedInput((select array_to_json(array_agg(automatedKnowledge)) FROM automatedKnowledge)::text, true);
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
    occurrence bigint NOT NULL,
    persist boolean NOT NULL,
    acknowledged boolean NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
-- Name: knowledgeHistory sentimentId_knowledgeId_knowledgeModelId_word_persist; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."knowledgeHistory"
    ADD CONSTRAINT "sentimentId_knowledgeId_knowledgeModelId_word_persist" PRIMARY KEY ("sentimentId", "knowledgeId", "knowledgeModelId", word, persist);


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

