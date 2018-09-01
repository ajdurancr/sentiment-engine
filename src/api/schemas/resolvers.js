import { mergeResolvers } from 'dcr-graphql'

import AnalysisResolver from './analysis/resolvers'
import KnowledgeResolver from './knowledge/resolvers'
import KnowledgeModelResolver from './knowledgeModel/resolvers'
import LearningResolver from './learning/resolvers'
import SentimentResolver from './sentiment/resolvers'

export default mergeResolvers(
    AnalysisResolver,
    KnowledgeResolver,
    KnowledgeModelResolver,
    LearningResolver,
    SentimentResolver,
)
