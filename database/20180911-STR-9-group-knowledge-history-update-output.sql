-- alter improveKnowledgeHistoryOutput's attribute types 

alter type improveKnowledgeHistoryOutput
	ALTER attribute "newKnowledgeHistory" type json,
	ALTER attribute "updatedKnowledgeHistory" type json;

-- change returned column types to match the new improveKnowledgeHistoryOutput type

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
			(select array_to_json(array_agg(newKnowledgeHistory)) from newKnowledgeHistory) as "newKnowledgeHistory",
			(
				select array_to_json(array_agg(updatedKnowledgeHistory))
				from (
					select * from updateKnowledgeHistory((select array_to_json(array_agg(newKnowledgeHistory)) FROM newKnowledgeHistory)::text, persistMode)
				) as updatedKnowledgeHistory
			) as "updatedKnowledgeHistory";
		
end;
$$ LANGUAGE plpgsql;

-- create function to group knowledgeHistory by Sentiment, Knowledge and KnowldegeModel adding each entity's information

create or replace FUNCTION groupKnowledgeHistoryBy_knowledgeModel_knowledge_sentiment(knowledgeHistoryRecords json)
returns table ("knowledgeModels" json) AS $$
begin
	return query
		with knowledgeHistoryBySentiment as (
			select
				khr."knowledgeModelId",
				khr."knowledgeId",
				khr."sentimentId",
				array_to_json(array_agg(row_to_json((
					select knowledgeHistoryInfo
					from (select khr.word, khr.occurrence, khr.persist, khr.acknowledged, khr."createdAt", khr."updatedAt") as knowledgeHistoryInfo
				)))) as "knowledgeHistory"
			from (select * from json_populate_recordset(null::knowledgeHistoryRow, knowledgeHistoryRecords)) as khr
			group by khr."knowledgeModelId", khr."knowledgeId",  khr."sentimentId"
			order by khr."sentimentId"
		),
		sentimentsByKnowledge as (
			select
				khbs."knowledgeModelId",
				khbs."knowledgeId",
				array_to_json(array_agg(
					row_to_json((select sentimentInfo from (select s.*, khbs."knowledgeHistory")as sentimentInfo))
				)) as sentiments
			from knowledgeHistoryBySentiment as khbs
				inner join sentiment as s on s."sentimentId" = khbs."sentimentId"
			group by khbs."knowledgeId", khbs."knowledgeModelId"
			order by khbs."knowledgeId"
		),
		knowledgeByKnowledgeModel as (
			select
				sbk."knowledgeModelId",
				array_to_json(array_agg(
					row_to_json((select knowledgeInfo from (select k.*, sbk.sentiments)as knowledgeInfo))
				)) as knowledge
			from sentimentsByKnowledge as sbk
				inner join knowledge as k on k."knowledgeId" = sbk."knowledgeId"
			group by sbk."knowledgeModelId"
			order by sbk."knowledgeModelId"
		),
		knowledgeModels as (
			select row_to_json((select knowledgeModelInfo from (select km.*, kbkm.knowledge)as knowledgeModelInfo)) as "knowledgeModels"
			from knowledgeByKnowledgeModel as kbkm
				inner join "knowledgeModel" as km on km."knowledgeModelId" = kbkm."knowledgeModelId"
		)
		select * from knowledgeModels;
end;
$$ LANGUAGE plpgsql;

-- create function for learning and returing the results with the default grouping: knowledgeModel_knowledge_sentiment

create or replace FUNCTION improveKnowledgeHistoryAndReturnResultsWithDefaultGrouping(knowledgeHistoryRecords text, persistValue boolean)
returns setof improveKnowledgeHistoryOutput AS $$
DECLARE persistMode boolean = case when(persistValue isnull) then false else persistValue end;
begin
	return query
		with improvedKnowledgeOutput as (
			select * from improveKnowledgeHistoryWithEncodedInput((select * from encodeKnowledgeHistoryInput(knowledgeHistoryRecords)), persistMode)
		)
		select
			(select array_to_json(
				((select array_agg(gkh."knowledgeModels") from groupKnowledgeHistoryBy_knowledgeModel_knowledge_sentiment(ikh."newKnowledgeHistory") as gkh))
			)) as "newKnowledgeHistory",
			(select array_to_json(
				((select array_agg(gkh."knowledgeModels") from groupKnowledgeHistoryBy_knowledgeModel_knowledge_sentiment(ikh."updatedKnowledgeHistory") as gkh))
			)) as "updatedKnowledgeHistory"
		from improvedKnowledgeOutput as ikh;
end;
$$ LANGUAGE plpgsql;


-- update improvement functions to group improvement to use default grouping

create or replace FUNCTION improveKnowledgeHistory(knowledgeHistoryRecords text)
returns setof improveKnowledgeHistoryOutput AS $$
begin
	return query
		select * from improveKnowledgeHistoryAndReturnResultsWithDefaultGrouping(knowledgeHistoryRecords, true);
end;
$$ LANGUAGE plpgsql;

--

create or replace FUNCTION improveAutomatedKnowledgeHistory(knowledgeHistoryRecords text)
returns setof improveKnowledgeHistoryOutput AS $$
begin
	return query
		select * from improveKnowledgeHistoryAndReturnResultsWithDefaultGrouping(knowledgeHistoryRecords, false);
end;
$$ LANGUAGE plpgsql;

-- create function for updating the knowledge and returing the results with the default grouping: knowledgeModel_knowledge_sentiment

create or replace FUNCTION updateKnowledgeHistoryFromAutomatedKnowledgeAndReturnResultsWithDefaultGrouping()
returns setof improveKnowledgeHistoryOutput AS $$
begin
	return query
		with improvedKnowledgeOutput as (select * from updateKnowledgeHistoryFromAutomatedKnowledge())
		select
			(select array_to_json(
				((select array_agg(gkh."knowledgeModels") from groupKnowledgeHistoryBy_knowledgeModel_knowledge_sentiment(ikh."newKnowledgeHistory") as gkh))
			)) as "newKnowledgeHistory",
			(select array_to_json(
				((select array_agg(gkh."knowledgeModels") from groupKnowledgeHistoryBy_knowledgeModel_knowledge_sentiment(ikh."updatedKnowledgeHistory") as gkh))
			)) as "updatedKnowledgeHistory"
		from improvedKnowledgeOutput as ikh;
end;
$$ LANGUAGE plpgsql;

-- create function to get all the knowledge history using the default grouping using persist mode

create or replace FUNCTION getKnowledgeHistory(persistValue boolean)
returns table ("knowledgeHistory" json) AS $$
DECLARE persistMode boolean = case when(persistValue isnull) then false else persistValue end;
begin
	return query
		select groupKnowledgeHistoryBy_knowledgeModel_knowledge_sentiment(
			(select array_to_json(array_agg(row_to_json(kh))) from "knowledgeHistory" as kh where persist = persistMode and acknowledged = persistMode)
		) as "knowledgeHistory";
		
end;
$$ LANGUAGE plpgsql;