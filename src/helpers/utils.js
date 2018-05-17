import tokenizer from 'lodash/words'

export function tokenizeText(text) {
  return tokenizer(text.toLowerCase())
}

export function removeStopWords(words, stopWords) {
  return words.filter((word) => !stopWords.includes(word))
}

export function getOccurrencesByWord(words) {
  const occurrencesByWord = words.reduce((occurrences, word) => {
    occurrences[word] = (occurrences[word] || 0) + 1

    return occurrences
  }, {})

  return Object.keys(occurrencesByWord).map((word) => ({ word, occur: occurrencesByWord[word] }))
}

export function sortByOccurrence(collection) {
  return [...collection].sort(({ occur }, { occur: occurB }) => occurB - occur)
}
