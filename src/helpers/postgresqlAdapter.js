import Sequelize from 'sequelize'
import { isNil } from 'lodash'

import databaseConfig from '../constants/database'
import { TYPE_STRING, TYPE_OBJECT } from '../constants/dbTypes'

const sequelize = new Sequelize(databaseConfig)

const _defaultTypeFormatFuntion = (value) => value
const _formatStringType = (value) => `'${value}'`
const _formatObjectType = (object) => String(object ? JSON.stringify(object) : null)

const ARGUMENT_FORMATTER_FUNCTIONS_BY_TYPE = { [TYPE_STRING]: _formatStringType, [TYPE_OBJECT]: _formatObjectType }

const _formatArrayArgument = (arrayArg, typeFormatFuntion = _defaultTypeFormatFuntion, useJsonFormat) => {
	if(!arrayArg.length) return null

	const arrayValues = arrayArg.map(typeFormatFuntion).join(', ')

	return String(useJsonFormat ?  `'[${arrayValues}]'` : `'{${arrayValues}}'`)
}

const _formatArgumentType = (value, type, useJsonFormat) => {
	const typeFormatFuntion = ARGUMENT_FORMATTER_FUNCTIONS_BY_TYPE[type]
	
	if(Array.isArray(value)) return _formatArrayArgument(value, typeFormatFuntion, useJsonFormat)

	return typeFormatFuntion ? typeFormatFuntion(value) : value
}

const _mapArgsDefinition = (args) => (args || []).map(({ useJsonFormat, ...argDef }) => {
	const [argumentName, type] = Object.entries(argDef)[0]

	return { argumentName, type, useJsonFormat }
})

const _buildProcedureArguments = (args, values) => _mapArgsDefinition(args)
	.reduce((argsCollection, { argumentName, type, useJsonFormat }) => (
		[...argsCollection, String(isNil(values[argumentName]) ? null : _formatArgumentType(values[argumentName], type, useJsonFormat))]
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
