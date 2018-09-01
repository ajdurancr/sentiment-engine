import { resolveArguments } from '../../../helpers/utils'

import { addKnowledge, getKnowledge, updateKnowledge } from './model'

const resolvers = {
  Query: {
    getKnowledge: resolveArguments(getKnowledge),
  },

  Mutation: {
    addKnowledge: resolveArguments(addKnowledge),

    updateKnowledge: resolveArguments(updateKnowledge),
  },
}

export default resolvers