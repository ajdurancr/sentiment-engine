-- alter "knowledgeHistory" structure and primary key

alter table "knowledgeHistory" add column persist boolean not null;
alter table "knowledgeHistory" add column acknowledged boolean not null;
alter table "knowledgeHistory" add column "createdAt" timestamp not null default current_timestamp;
alter table "knowledgeHistory" add column "updatedAt" timestamp not null default current_timestamp;
ALTER TABLE "knowledgeHistory" DROP CONSTRAINT "knowledgeId_sentimentId_word";
alter table "knowledgeHistory" add constraint "sentimentId_knowledgeId_knowledgeModelId_word_persist" primary key("sentimentId", "knowledgeId", "knowledgeModelId", "word", "persist");

-- create type for DECODING the knowledgeHistoryRecords to be saved/updated

CREATE TYPE knowledgeHistoryRecordInput AS ("sentimentId" int, "knowledgeId" int, "knowledgeModelId" int, "word" text, "occurrence" bigint);

-- create type for ENCODING the knowledgeHistoryRecords to be saved/updated

create type rawKnowledgeHistoryInput as ("sentimentId" int, "knowledgeId" int, "knowledgeModelId" int, "words" text);

-- create knowledge history row type

CREATE type knowledgeHistoryRow as (
	"sentimentId" int,
	"knowledgeId" int,
	"knowledgeModelId" int,
	"word" varchar,
	"occurrence" bigint,
	persist boolean,
	acknowledged boolean,
	"createdAt" timestamp,
	"updatedAt" timestamp
);

-- create function to transform knowledge history records
-- from raw TEXT knowledgeHistoryRecordInput to ENCODED TEXT raw knowledgeHistoryRecordInput

create or replace FUNCTION encodeKnowledgeHistoryInput(rawKnowledgeHistoryRecords text)
returns table (encondedKnowledgeHistoryInput text) AS $$
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
$$ LANGUAGE plpgsql;

-- create function to transform knowledge history records
-- from ENCODED TEXT raw knowledgeHistoryRecordInput to a SETOF TYPE knowledgeHistoryRecordInput

create or replace FUNCTION decodeKnowledgeHistoryInput(knowledgeHistoryRecords text)
returns setof knowledgeHistoryRecordInput  AS $$
begin
	return query
		select khr."sentimentId", khr."knowledgeId", khr."knowledgeModelId", lower(khr.word) as word, khr.occurrence 
		from json_populate_recordset(null::knowledgeHistoryRecordInput, knowledgeHistoryRecords::json) as khr;
end;
$$ LANGUAGE plpgsql;

-- create function to update knowledge history depending on if the input is persistMode or not

create or replace FUNCTION updateKnowledgeHistory(knowledgeHistoryRecords text, persistValue boolean)
returns setof knowledgeHistoryRow AS $$
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
$$ LANGUAGE plpgsql;

-- create type for returing knowledge history results of the improvement process

create type improveKnowledgeHistoryOutput as ("newKnowledgeHistory" text, "updatedKnowledgeHistory" text);

-- create function to save/update persited knowledge history taking ENCODED input records

create or replace FUNCTION improveKnowledgeHistoryWithEncodedInput(encodedKnowledgeHistoryInput text, persistValue boolean)
returns setof improveKnowledgeHistoryOutput AS $$
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
$$ LANGUAGE plpgsql;

-- create function to save/update persited knowledge history taking non ENCODED input records

create or replace FUNCTION improveKnowledgeHistory(knowledgeHistoryRecords text)
returns setof improveKnowledgeHistoryOutput AS $$
begin
	return query
		select * from improveKnowledgeHistoryWithEncodedInput((select * from encodeKnowledgeHistoryInput(knowledgeHistoryRecords)), true);		
end;
$$ LANGUAGE plpgsql;

-- create function to save/update automated knowledge results taking non ENCODED input records

create or replace FUNCTION improveAutomatedKnowledgeHistory(knowledgeHistoryRecords text)
returns setof improveKnowledgeHistoryOutput AS $$
begin
	return query
		select * from improveKnowledgeHistoryWithEncodedInput((select * from encodeKnowledgeHistoryInput(knowledgeHistoryRecords)), false);		
end;
$$ LANGUAGE plpgsql;

-- create function to update persisted knowledge history using the automated knowledge saved results

create or replace FUNCTION updateKnowledgeHistoryFromAutomatedKnowledge()
returns setof improveKnowledgeHistoryOutput AS $$
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
$$ LANGUAGE plpgsql;