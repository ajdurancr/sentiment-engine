import { flatten } from 'lodash'

import { tokenizeText } from '../../../helpers/utils'
import { improveKnowledgeHistory } from './model'

const _improveKnowledgeHistory = (_, { knowledgeHistoryInput }) => {
  const knowledgeHistoryRecords = knowledgeHistoryInput.reduce((validInputs, { text: intputTexts, ...inputValues }) => {
    const words = flatten(intputTexts.filter((text) => text.length).map((text) => tokenizeText(text)))
    if(!words.length)  return validInputs

    return [...validInputs, { words, ...inputValues }]
  }, [])

  return knowledgeHistoryRecords.length ? improveKnowledgeHistory({ knowledgeHistoryRecords }) : null
}

const resolvers = {
  Mutation: {
    improveKnowledgeHistory: _improveKnowledgeHistory,
  },
}

export default  resolvers