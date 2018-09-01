import { TYPE_NUMBER, TYPE_STRING } from '../../../constants/dbTypes'
import { getFirstRow } from '../../../helpers/utils'
import { executeStoreProcedure } from '../../../helpers/postgresqlAdapter'

const alphaArgDef = { alpha: TYPE_NUMBER }
const knowledgeModelIdArgDef = { knowledgeModelId: TYPE_NUMBER }
const nameArgDef = { name: TYPE_STRING }
const percentilesArgDef = { percentiles: TYPE_NUMBER }
const percentilesToTakeArgDef = { percentilesToTake: TYPE_NUMBER }

const argsDefinitionAddKnowledgeModel = [nameArgDef, alphaArgDef, percentilesArgDef, percentilesToTakeArgDef]
const argsDefinitionGetKnowledgeModel = [knowledgeModelIdArgDef]
const argsDefinitionUpdateKnowledgeModelName = [
	knowledgeModelIdArgDef,
	nameArgDef,
	alphaArgDef,
	percentilesArgDef,
	percentilesToTakeArgDef,
]

const addKnowledgeModel = async ({ name, alpha, percentiles, percentilesToTake }) => getFirstRow(
	await executeStoreProcedure(
		'insertKnowledgeModel',
		argsDefinitionAddKnowledgeModel,
		{ name, alpha, percentiles, percentilesToTake },
	)
)

const getKnowledgeModels = ({ knowledgeModelId }) => (
	executeStoreProcedure('getKnowledgeModels', argsDefinitionGetKnowledgeModel, { knowledgeModelId })
)

const updateKnowledgeModel = async ({ knowledgeModelId, name, alpha, percentiles, percentilesToTake }) => getFirstRow(
	await executeStoreProcedure(
		'updateKnowledgeModel',
		argsDefinitionUpdateKnowledgeModelName,
		{ knowledgeModelId, name, alpha, percentiles, percentilesToTake },
	)
)

export { addKnowledgeModel, getKnowledgeModels, updateKnowledgeModel }
