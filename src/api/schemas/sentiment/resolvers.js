import { resolveArguments } from '../../../helpers/utils'

import { addSentiment, getSentiments, updateSentiment } from './model'

const resolvers = {
  Query: {
    getSentiments: resolveArguments(getSentiments),
  },
  Mutation: {
    addSentiment: resolveArguments(addSentiment),
    
    updateSentiment: resolveArguments(updateSentiment),
  },
}

export default resolvers