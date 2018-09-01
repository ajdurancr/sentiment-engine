import { getFirstRow } from '../../../helpers/utils'
import { TYPE_NUMBER, TYPE_STRING } from '../../../constants/dbTypes'
import { executeStoreProcedure } from '../../../helpers/postgresqlAdapter'

const nameArgDef = { name: TYPE_STRING }
const knowledgeIdArgDef = { knowledgeId: TYPE_NUMBER }

const argsDefinitionAddKnowledge = [nameArgDef]
const argsDefinitionGetKnowledge = [knowledgeIdArgDef]
const argsDefinitionUpdateKnowledge = [knowledgeIdArgDef, nameArgDef]

const addKnowledge = async ({ name }) => getFirstRow(
	await executeStoreProcedure('insertKnowledge', argsDefinitionAddKnowledge, { name })
)

const getKnowledge = ({ knowledgeId }) => (
	executeStoreProcedure('getKnowledge', argsDefinitionGetKnowledge, { knowledgeId })
)

const updateKnowledge = async ({ knowledgeId, name }) => getFirstRow(
	await executeStoreProcedure('updateKnowledge', argsDefinitionUpdateKnowledge, { knowledgeId, name })
)

export { addKnowledge, getKnowledge, updateKnowledge }