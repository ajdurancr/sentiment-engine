import Sequelize from 'sequelize'
import { isNil } from 'lodash'

import databaseConfig from '../constants/database'
import { TYPE_STRING } from '../constants/dbTypes'

const sequelize = new Sequelize(databaseConfig)

const _defaultTypeFormatFuntion = (value) => value
const _formatStringType = (value) => `'${value}'`

const ARGUMENT_FORMATTER_FUNCTIONS_BY_TYPE = { [TYPE_STRING]: _formatStringType }

const _formatArrayArgument = (valuesArray, typeFormatFuntion = _defaultTypeFormatFuntion) => (
	String(valuesArray.length ? `'{${valuesArray.map(typeFormatFuntion).join(', ')}}'` : null)
)

const _formatArgumentType = (value, type) => {
	const typeFormatFuntion = ARGUMENT_FORMATTER_FUNCTIONS_BY_TYPE[type]
	
	if(Array.isArray(value)) return _formatArrayArgument(value, typeFormatFuntion)

	return typeFormatFuntion ? typeFormatFuntion(value) : value
}

const _mapArgsDefinition = (args) => (args || []).map((argDef) => {
	const [argumentName, type] = Object.entries(argDef)[0]

	return { argumentName, type }
})

const _buildProcedureArguments = (args, values) => _mapArgsDefinition(args)
	.reduce((argsCollection, { argumentName, type }) => (
		[...argsCollection, String(isNil(values[argumentName]) ? null : _formatArgumentType(values[argumentName], type))]
	), [])

const _buildProcedureQueryString = (procedureName, argsDefs, values = {}) => {
	const procedureArgs = _buildProcedureArguments(argsDefs, values)

	return `select * from ${procedureName}(${procedureArgs.join(', ')})`
}

const executeStoreProcedure = async (procedureName, argsDefs, values) => (
	sequelize.query(
		_buildProcedureQueryString(procedureName, argsDefs, values),
		{ type: sequelize.QueryTypes.SELECT },
	)
)

export { executeStoreProcedure }
