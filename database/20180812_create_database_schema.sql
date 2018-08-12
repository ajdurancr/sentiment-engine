-- create database schema
CREATE DATABASE "knowledge";

\connect "knowledge"

CREATE TABLE "sentiment" (
    "sentimentId" SERIAL primary KEY,
    "name" varchar(255) not null,
    unique ("name")
);

CREATE TABLE "knowledge" (
    "knowledgeId" SERIAL primary KEY,
    "name" varchar(255) not null,
    unique ("name")
);

CREATE TABLE "knowledgeModel" (
    "knowledgeModelId" SERIAL primary KEY,
    "name" varchar(255) not null,
    "alpha" numeric(3, 2) not null,
    "percentiles" integer not null,
    "percentilesToTake" integer not null,
    unique ("name"),
    unique ("alpha", "percentiles", "percentilesToTake")
);

CREATE TABLE "knowledgeHistory" (
    "knowledgeId" integer,
    "sentimentId" integer,
	"knowledgeModelId" integer,
    word varchar(255),
    occurrence bigint not null,
    CONSTRAINT "knowledgeId_sentimentId_word" PRIMARY KEY("sentimentId", "knowledgeId", "knowledgeModelId", "word")
);

-- sentiment table functions

CREATE or replace FUNCTION getSentiments(sentimentIds integer[])
RETURNS TABLE("sentimentId" integer, "name" varchar(255))
AS $$
begin	
	return query
		select sentiment."sentimentId", sentiment."name"
		from public.sentiment
		where sentimentIds isnull or sentiment."sentimentId" = ANY(sentimentIds);
end;
$$ LANGUAGE plpgsql;

--

CREATE or replace FUNCTION insertSentiment(sentimentName varchar(255))
RETURNS TABLE("sentimentId" integer, "name" varchar(255))
AS $$
begin
	INSERT INTO public.sentiment ("name") VALUES(sentimentName);
	
	return query
		select sentiment."sentimentId", sentiment."name"
		from public.sentiment
		where sentiment."name" = sentimentName;
end;
$$ LANGUAGE plpgsql;

--

CREATE or replace FUNCTION updateSentiment(sentimentIdValue integer, sentimentName varchar(255))
RETURNS TABLE("sentimentId" integer, "name" varchar(255))
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
$$ LANGUAGE plpgsql;

-- knowledge table functions

CREATE or replace FUNCTION getKnowledge(knowledgeIds integer[])
RETURNS TABLE("knowledgeId" integer, "name" varchar(255))
AS $$
begin	
	return query
		select knowledge."knowledgeId", knowledge."name"
		from public.knowledge
		where knowledgeIds isnull or knowledge."knowledgeId" = any (knowledgeIds);
end;
$$ LANGUAGE plpgsql;

--

CREATE or replace FUNCTION insertKnowledge(knowledgeName varchar(255))
RETURNS TABLE("knowledgeId" integer, "name" varchar(255))
AS $$
begin
	INSERT INTO public.knowledge ("name") VALUES(knowledgeName);
	
	return query
		select knowledge."knowledgeId", knowledge."name"
		from public.knowledge
		where knowledge."name" = knowledgeName;
end;
$$ LANGUAGE plpgsql;

--

CREATE or replace FUNCTION updateKnowledge(knowledgeIdValue integer, knowledgeName varchar(255))
RETURNS TABLE("knowledgeId" integer, "name" varchar(255))
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
$$ LANGUAGE plpgsql;

-- knowledgeModel table functions

CREATE or replace FUNCTION getKnowledgeModels(knowledgeModelIds integer[])
RETURNS TABLE(
	"knowledgeModelId" integer,
	"name" varchar(255),
	"alpha" numeric(3, 2),
    "percentiles" integer,
    "percentilesToTake" integer
) AS $$
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
$$ LANGUAGE plpgsql;

--

CREATE or replace FUNCTION insertKnowledgeModel(
	nameValue varchar(255),
	alphaValue numeric(3, 2),
    percentilesValue integer,
    percentilesToTakeValue integer
) RETURNS TABLE(
	"knowledgeModelId" integer,
	"name" varchar(255),
	"alpha" numeric(3, 2),
    "percentiles" integer,
    "percentilesToTake" integer
) AS $$
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
$$ LANGUAGE plpgsql;

--

CREATE or replace FUNCTION updateKnowledgeModel(
	knowledgeModelIdValue integer,
	nameValue varchar(255),
	alphaValue numeric(3, 2),
    percentilesValue integer,
    percentilesToTakeValue integer
) RETURNS TABLE(
	"knowledgeModelId" integer,
	"name" varchar(255),
	"alpha" numeric(3, 2),
    "percentiles" integer,
    "percentilesToTake" integer
) AS $$
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
$$ LANGUAGE plpgsql;

-- insert sample data
select * from public.insertSentiment('Positive');
select * from public.insertSentiment('Negative');

select * from public.insertKnowledge('Historical');

select * from public.insertKnowledgeModel('Default model a1.96 - p9 - pt3', 1.96, 9, 3);
select * from public.insertKnowledgeModel('Default model a1.96 - p7 - pt3', 1.96, 7, 3);
