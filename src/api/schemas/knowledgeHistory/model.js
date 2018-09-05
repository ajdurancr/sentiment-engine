import { getFirstRow } from '../../../helpers/utils'
import { TYPE_OBJECT } from '../../../constants/dbTypes'
import { executeStoreProcedure } from '../../../helpers/postgresqlAdapter'

const knowledgeHistoryRecordsArgDef = { knowledgeHistoryRecords: TYPE_OBJECT, useJsonFormat: true }

const argsDefinitionImproveKnowledgeHistory = [knowledgeHistoryRecordsArgDef]

const improveKnowledgeHistory = async ({ knowledgeHistoryRecords }) => {
	const { newKnowledgeHistory, updatedKnowledgeHistory } = getFirstRow(
		await executeStoreProcedure('improveKnowledgeHistory', argsDefinitionImproveKnowledgeHistory, { knowledgeHistoryRecords })
	) || {}

	return {
		newKnowledgeHistory: newKnowledgeHistory && JSON.parse(newKnowledgeHistory),
		updatedKnowledgeHistory: updatedKnowledgeHistory && JSON.parse(updatedKnowledgeHistory),
	}
}

export { improveKnowledgeHistory }
