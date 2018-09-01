import { getFirstRow } from '../../../helpers/utils'
import { TYPE_NUMBER, TYPE_STRING } from '../../../constants/dbTypes'
import { executeStoreProcedure } from '../../../helpers/postgresqlAdapter'

const nameArgDef = { name: TYPE_STRING }
const sentimentIdArgDef = { sentimentId: TYPE_NUMBER }

const argsDefinitionAddSentiment = [nameArgDef]
const argsDefinitionGetSentiment = [sentimentIdArgDef]
const argsDefinitionUpdateSentiment = [sentimentIdArgDef, nameArgDef]

const addSentiment = async ({ name }) => getFirstRow(
	await executeStoreProcedure('insertSentiment', argsDefinitionAddSentiment, { name })
)

const getSentiments = ({ sentimentId }) => (
	executeStoreProcedure('getSentiments', argsDefinitionGetSentiment, { sentimentId })
)

const updateSentiment = async ({ sentimentId, name }) => getFirstRow(
	await executeStoreProcedure('updateSentiment', argsDefinitionUpdateSentiment, { sentimentId, name })
)

export { addSentiment, getSentiments, updateSentiment }
