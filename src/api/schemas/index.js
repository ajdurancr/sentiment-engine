import { schema, mergeResolvers } from 'dcr-graphql'

import AnalysisSchema from './analysis/schema'
import AnalysisResolver from './analysis/resolvers'
import LearningSchema from './learning/schema'
import LearningResolver from './learning/resolvers'

const resolvers = mergeResolvers(AnalysisResolver, LearningResolver)
const typeDefs = [AnalysisSchema, LearningSchema]

export default schema({ typeDefs, resolvers })
