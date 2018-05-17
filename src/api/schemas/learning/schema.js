const learningSchema = `
  # Configurations to be used during the learning process
  input LearningConfigurationInput {
    percentiles: Int!
    percentilesToTake: Int!
  }

  input TextWithSentimentInput {
    sentiment: String!
    text: String!
  }

  type KnowledgeBySentiment {
    sentiment: String
    words: [WordOccurrence]
  }

  type LearningStatistic {
    type: String
    value: Float
  }

  type LearningStatisticBySentiment {
    sentiment: String
    statistics: [LearningStatistic]
  }

  type LearningStatistics {
    percentiles: Int
    percentilesTaken: Int
    #occurrences: Int
    #occurrencesTaken: Int
    alpha: Float
    criticalZValue: Float
    statisticsBySentiment: [LearningStatisticBySentiment]
  }

  type LearningResults {
    sentiments: [String]
    statistics: LearningStatistics
    modelKnowledge: [KnowledgeBySentiment]
    updatedHistoricalKnowledge: [KnowledgeBySentiment]
  }

  type LearningConfiguration {
    percentiles: Int
    percentilesToTake: Int
  }

  type LearningResultByConfig {
    config: LearningConfiguration
    results: LearningResults
  }

  extend type Mutation {
    controlledLearning(
      configs: [LearningConfigurationInput!],
      textsWithSentiment: [TextWithSentimentInput!]
    ): [LearningResultByConfig]
  }
`

export default learningSchema
