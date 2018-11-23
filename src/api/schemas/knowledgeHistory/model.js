import { getFirstRow } from '../../../helpers/utils'
import { TYPE_OBJECT } from '../../../constants/dbTypes'
import { executeStoreProcedure } from '../../../helpers/postgresqlAdapter'

const persistModeArgDef = { persistMode: 'boolean' }
const argsDefinitionGetKnowledgeHistory = [persistModeArgDef]

const knowledgeHistoryRecordsArgDef = { knowledgeHistoryRecords: TYPE_OBJECT, useJsonFormat: true }
const argsDefinitionImproveKnowledgeHistory = [knowledgeHistoryRecordsArgDef]


const getKnowledgeHistory = async ({ persistMode }) => {
	const rows = await executeStoreProcedure(
		'getKnowledgeHistory',
		argsDefinitionGetKnowledgeHistory,
		{ persistMode },
	)
	return rows.map(({ knowledgeHistory }) => knowledgeHistory)
}

const improveKnowledgeHistoryByProcedure = (procedureName) => async ({ knowledgeHistoryRecords }) => getFirstRow(
	await executeStoreProcedure(
		procedureName,
		argsDefinitionImproveKnowledgeHistory,
		{ knowledgeHistoryRecords },
	),
)

const improveKnowledgeHistory = improveKnowledgeHistoryByProcedure('improveKnowledgeHistory')

const improveAutomatedKnowledgeHistory = improveKnowledgeHistoryByProcedure('improveAutomatedKnowledgeHistory')

const updateKnowledgeHistoryFromAutomatedKnowledge = async () => getFirstRow(
	await executeStoreProcedure('updateKnowledgeHistoryFromAutomatedKnowledgeAndReturnResultsWithDefaultGrouping'),
)

export {
	getKnowledgeHistory,
	improveKnowledgeHistory,
	improveAutomatedKnowledgeHistory,
	updateKnowledgeHistoryFromAutomatedKnowledge,
}
