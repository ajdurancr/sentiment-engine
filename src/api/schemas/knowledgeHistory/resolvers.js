import { flatten } from 'lodash'

import { tokenizeText, resolveArguments } from '../../../helpers/utils'
import {
  getKnowledgeHistory,
  improveKnowledgeHistory,
  improveAutomatedKnowledgeHistory,
  updateKnowledgeHistoryFromAutomatedKnowledge,
} from './model'

const _createImproveKnowledgeHistoryResolver = (improvementFunction) => (_, { knowledgeHistoryInput }) => {
  const knowledgeHistoryRecords = knowledgeHistoryInput.reduce((validInputs, { text: intputTexts, ...inputValues }) => {
    const words = flatten(intputTexts.filter((text) => text.length).map((text) => tokenizeText(text)))
    if(!words.length)  return validInputs

    return [...validInputs, { words, ...inputValues }]
  }, [])

  return knowledgeHistoryRecords.length ? improvementFunction({ knowledgeHistoryRecords }) : null
}

const resolvers = {
  Query: {
    getKnowledgeHistory: resolveArguments(getKnowledgeHistory),
  },
  Mutation: {
    improveKnowledgeHistory: _createImproveKnowledgeHistoryResolver(improveKnowledgeHistory),
    improveAutomatedKnowledgeHistory: _createImproveKnowledgeHistoryResolver(improveAutomatedKnowledgeHistory),
    updateKnowledgeHistoryFromAutomatedKnowledge,
  },
}

export default  resolvers