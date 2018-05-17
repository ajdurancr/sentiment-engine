import { getOccurrencesSum } from '../helpers/math'
import { sortByOccurrence } from '../helpers/utils'

const CRITICAL_Z_VALUE = 1.96

function getObservedZValue(proportionA, proportionB, totalElementsA, totalElementsB){
  const qA = 1 - proportionA
  const qB = 1 - proportionB
  const proportionDifference = proportionA - proportionB

  return proportionDifference / Math.sqrt(((proportionA*qA)/totalElementsA) + ((proportionB*(qB))/totalElementsB))
}

export function _getOccurrencesInfo(array, percentiles, percentilesToTake) {
  const totalOccurrences = getOccurrencesSum(array)

  return { maxOccurrencesToTake: Math.abs( (totalOccurrences/percentiles) * percentilesToTake), totalOccurrences }
}


function _isNormalizedValue({ observedZValue, criticalZValue }) {
  const positiveCriticalZValue = Math.abs(criticalZValue)
  const negativeCriticalZValue = positiveCriticalZValue * -1

  return observedZValue >= negativeCriticalZValue && observedZValue <= positiveCriticalZValue
}

function _getRepeatedWordsWithOccurrences(knowledgeBySentiment, sentiments) {
  const [sentimentA, sentimentB] = sentiments
  const isALengthGreater = knowledgeBySentiment[sentimentA].length > knowledgeBySentiment[sentimentB].length
  const wordListA = isALengthGreater ? knowledgeBySentiment[sentimentB] : knowledgeBySentiment[sentimentA]
  const wordListB = isALengthGreater ? knowledgeBySentiment[sentimentA] : knowledgeBySentiment[sentimentB]

  return wordListA.reduce((repeatedWords, { word, occur: occurA }) => {
    const { occur: occurB } = wordListB.find(({ word: currentWord }) => word === currentWord) || {}
    
    if(!occurB) return repeatedWords

    const sentimentAOccurrences = isALengthGreater ? occurB : occurA
    const sentimentBOccurrences = isALengthGreater ? occurA : occurB

    repeatedWords.push({
      word,
      [`${sentimentA}Occurrences`]: sentimentAOccurrences,
      [`${sentimentB}Occurrences`]: sentimentBOccurrences,
    })

    return repeatedWords
  }, [])
}

function _getWordsToExcludeBySentiment(args) {
  const {
    repeatedWordsWithOccurrences,
    totalOccurrencesBySentiment,
    sentiments,
  } = args
  const [sentimentA, sentimentB] = sentiments
  const sentimentAOccurrencesKey = `${sentimentA}Occurrences`
  const sentimentBOccurrencesKey = `${sentimentB}Occurrences`

  return repeatedWordsWithOccurrences.reduce((excludedWords, repeatedWord) => {
    const {
      word,
      [sentimentAOccurrencesKey]: sentimentAOccurrences,
      [sentimentBOccurrencesKey]: sentimentBOccurrences,
    } = repeatedWord
    const proportionA = sentimentAOccurrences / totalOccurrencesBySentiment[sentimentA]
    const proportionB = sentimentBOccurrences / totalOccurrencesBySentiment[sentimentB]
    const observedZValue = getObservedZValue(
      proportionA,
      proportionB,
      totalOccurrencesBySentiment[sentimentA],
      totalOccurrencesBySentiment[sentimentB],
    )
    const isObservedValueNormalized = _isNormalizedValue({ observedZValue, criticalZValue: CRITICAL_Z_VALUE })
    const isProportionAGreater = proportionA > proportionB
  
    if(isObservedValueNormalized){
      excludedWords[sentimentA].push(word)
      excludedWords[sentimentB].push(word)

      return excludedWords
    }

    if(isProportionAGreater) {
      excludedWords[sentimentB].push(word)
    } else {
      excludedWords[sentimentA].push(word)
    }

    return excludedWords
  }, { [sentimentA]: [], [sentimentB]: [] })
}

function _excludeWords(knowledge, wordsToExclude) {
  if(!wordsToExclude.length) return knowledge

  return knowledge.filter(({ word }) => !wordsToExclude.includes(word))
}

function _filterKnowledgeByFrequency({ representativeWords, sentiments }) {
  const totalOccurrencesBySentiment = sentiments.reduce((occurrencesBySentiment, sentiment) => {
    occurrencesBySentiment[sentiment] = getOccurrencesSum(representativeWords[sentiment])

    return occurrencesBySentiment
  }, {})

  const repeatedWordsWithOccurrences = _getRepeatedWordsWithOccurrences(representativeWords, sentiments)
  const wordsToExcludeBySentiment = _getWordsToExcludeBySentiment({
    repeatedWordsWithOccurrences,
    totalOccurrencesBySentiment,
    sentiments,
  })

  return sentiments.reduce((modelKnowledge, sentiment) => {
    modelKnowledge[sentiment] = _excludeWords(representativeWords[sentiment], wordsToExcludeBySentiment[sentiment])

    return modelKnowledge
  }, {})
}

function _getMostRepresentativeWords(words, maxOccurrencesToTake) {
  const representativeWords = []
  let occurrencesTaken = 0
  let index = 0

  while(occurrencesTaken < maxOccurrencesToTake){
    representativeWords.push(words[index])

    occurrencesTaken += words[index].occur
    index = index + 1
  }

  return { representativeWords, occurrencesTaken }
}

export default function generateModel(args) {
  const { historicalKnowledge, sentiments, percentiles, percentilesToTake } = args
  const sortedHistoricalKnowledge = {}
  const totalOccurrencesMap = {}
  const maxOccurrencesMap = {}
  const occurrencesTakenMap = {}

  sentiments.forEach((sentiment) => {
    sortedHistoricalKnowledge[sentiment] = sortByOccurrence(historicalKnowledge[sentiment])
    
    const {
      totalOccurrences,
      maxOccurrencesToTake,
    } = _getOccurrencesInfo(
      sortedHistoricalKnowledge[sentiment],
      percentiles,
      percentilesToTake,
    )
    
    totalOccurrencesMap[sentiment] = totalOccurrences
    maxOccurrencesMap[sentiment] = maxOccurrencesToTake
  })
  
  const representativeWords = {}
  
  sentiments.forEach((sentiment) => {
    const {
      representativeWords: currentRepresentativeWords,
      occurrencesTaken,
    } = _getMostRepresentativeWords(
      sortedHistoricalKnowledge[sentiment],
      maxOccurrencesMap[sentiment],
    )

    representativeWords[sentiment] = currentRepresentativeWords
    occurrencesTakenMap[sentiment] = occurrencesTaken
  })

  const statisticsMap = {  
    totalOccurrences: totalOccurrencesMap,
    maxOccurrencesToTake: maxOccurrencesMap,
    occurrencesTaken: occurrencesTakenMap,
  }


  const modelKnowledge = _filterKnowledgeByFrequency({ representativeWords, sentiments })

  return {
    modelKnowledge,
    statistics: {
      percentiles,
      percentilesTaken: percentilesToTake,
      statisticsBySentiment: getStatisticsBySentiment(sentiments, statisticsMap)
    },
  }
}

function getStatisticsBySentiment(sentiments, statistics) {
  const statisticsTypes = Object.keys(statistics)

  return sentiments.map((sentiment) => {
    const statsBySentiment = statisticsTypes.map((type) => ({ type, value: statistics[type][sentiment] }))

    return { sentiment, statistics: statsBySentiment }
  })

}