import { getOccurrencesByWord, removeStopWords, tokenizeText } from './utils'
import generateModelKnowledge from './generateKnowledgeModel'

// TODO: Load stopWords from database
import stopWords from '../mock/stopWords'

const OUTPUT_TYPES_KNOWLEDGE = ['words']
const OUTPUT_TYPES_STATISTICS = ['percentiles', 'percentilesTaken', 'occurrences', 'maxOccurrencesToTake', 'occurrencesTaken', 'alpha', 'criticalZValue']

function outputToArray(sentiments, output, types) {
  return sentiments.map((sentiment) => {
    const outputMap = { sentiment }

    types.forEach((type) => {
      outputMap[type] = output[sentiment]
    })

    return outputMap
  })
}

function _addOccurrences(currentWords = [], wordsToAdd = []) {
  const occurrencesByWord = currentWords.concat(wordsToAdd).reduce((occurrences, { word, occur }) => {
    occurrences[word] = (occurrences[word] || 0) + occur

    return occurrences
  }, {})

  return Object.keys(occurrencesByWord).map((word) => ({ word, occur: occurrencesByWord[word] }))
}

function _updateHistoricalKnowledge(historicalKnowledge, newKnowledge, sentiments) {
  const updatedKnowledge = {}
  
  return sentiments.reduce((updatedKnowledge, sentiment) => {
    updatedKnowledge[sentiment] = _addOccurrences(historicalKnowledge[sentiment], newKnowledge[sentiment])

    return updatedKnowledge
  }, {})
}

function _getTokenizedWordsBySentiment(textsWithSentiment) {
  return textsWithSentiment.reduce((wordsBySentiment, { sentiment, text }) => {
    const tokenizedWords = tokenizeText(text)

    if(!wordsBySentiment[sentiment]) {
      wordsBySentiment[sentiment] = tokenizedWords

      return wordsBySentiment
    }
    // TODO: change to wordsBySentiment[sentiment].push(...tokenizedWords)
    // wordsBySentiment[sentiment] = wordsBySentiment[sentiment].concat(tokenizedWords)
    wordsBySentiment[sentiment].push(...tokenizedWords)

    return wordsBySentiment
  }, {})
}

function _getWordsWithOccurrencesBySentiment(textsWithSentiment, stopWords) {
  const wordsWithOccurrencesBySentiment = {}
  const tokenizedWordsBySentiment = _getTokenizedWordsBySentiment(textsWithSentiment)

  Object.keys(tokenizedWordsBySentiment).forEach((sentiment) => {
    const filteredWords = removeStopWords(tokenizedWordsBySentiment[sentiment], stopWords)

    wordsWithOccurrencesBySentiment[sentiment] = getOccurrencesByWord(filteredWords)
  })

  return wordsWithOccurrencesBySentiment
}

function _commonLearning({ textsWithSentiment, sentiments, percentiles, percentilesToTake }) {
  // TODO: Load historicalKnowledge collections from database
  const historicalKnowledgeBySentiment = sentiments.reduce((knowledgeBySentiment, sentiment) => Object.assign(
    knowledgeBySentiment,
    { [sentiment]: [] },
  ), {})

  const updatedHistoricalKnowledge = _updateHistoricalKnowledge(
    historicalKnowledgeBySentiment,
    textsWithSentiment,
    sentiments,
  )
  const { modelKnowledge, statistics } = generateModelKnowledge({
    sentiments,
    historicalKnowledge: updatedHistoricalKnowledge,
    percentiles,
    percentilesToTake,
  })

  // TODO: Update historicalKnowledge collections in database
  // TODO: Update modelKnowledge collections in database (if necessary)
  
  return { sentiments, modelKnowledge, updatedHistoricalKnowledge, statistics }
}

function controlledLearning({ textsWithSentiment, percentiles, percentilesToTake }) {
  const wordsWithOccurrencesBySentiment = _getWordsWithOccurrencesBySentiment(textsWithSentiment, stopWords)
  const { sentiments, statistics, modelKnowledge, updatedHistoricalKnowledge } =  _commonLearning({
    sentiments: Object.keys(wordsWithOccurrencesBySentiment),
    textsWithSentiment: wordsWithOccurrencesBySentiment,
    percentiles,
    percentilesToTake,
  })

  return {
    sentiments,
    statistics,
    modelKnowledge: outputToArray(sentiments, modelKnowledge, OUTPUT_TYPES_KNOWLEDGE),
    updatedHistoricalKnowledge: outputToArray(sentiments, updatedHistoricalKnowledge, OUTPUT_TYPES_KNOWLEDGE),
  }
}

export default controlledLearning