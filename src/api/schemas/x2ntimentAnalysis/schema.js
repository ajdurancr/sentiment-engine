import { schema } from 'dcr-graphql'

import resolvers from './resolvers'

const typeDefs = `
type WordFrequency {
  # Word
  word: String

  # Frequency
  freq: Float
}

type FrequencyDistribution {
  # Positive words frequencies
  pos: [WordFrequency]

  # Negative words frequencies
  neg: [WordFrequency]
}

type WordOccurrence {
  #Word
  word: String

  # Number of occurrences
  occur: Int
}

type SentimentResults {
  # Text is positive
  pos: Boolean

  # Text is negative
  neg: Boolean
}

type X2ntimentResult {
  # Sentiment in the text
  sentiment: String

  # Significance level used in this analysis
  alpha: Float

  # Number of categories used to generate the model collections for this analysis
  kCategories: Int

  # Text analyzed
  text: String
  
  sentimentDetails: SentimentResults
  occurrences: [WordOccurrence]
  expectedFrequencyDistribution: FrequencyDistribution
  observedFrequencyDistribution: FrequencyDistribution
}

type Query {
  x2ntimentAnalysis: X2ntimentResult
}
`

export default schema({ typeDefs, resolvers })
