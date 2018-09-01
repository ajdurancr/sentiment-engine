import { resolveArguments } from '../../../helpers/utils'

import { addKnowledgeModel, getKnowledgeModels, updateKnowledgeModel } from './model'

const resolvers = {
  Query: {
    getKnowledgeModels: resolveArguments(getKnowledgeModels),
  },

  Mutation: {
    addKnowledgeModel: resolveArguments(addKnowledgeModel),

    updateKnowledgeModel: resolveArguments(updateKnowledgeModel),
  }
}

export default resolvers