const sentimentSchema = `
  type Sentiment {
    sentimentId: Int
    name: String
  }

  type SentimentsWithKnowledgeHistory {
    sentimentId: Int
    name: String
    knowledgeHistory: [KnowledgeHistory]
  }

  extend type Query {
    getSentiments(sentimentId: [Int]): [Sentiment]
  }

  extend type Mutation {
    addSentiment(name: String!): Sentiment

    updateSentiment(
      sentimentId: Int!

      name: String
    ): Sentiment
  }
`

export default sentimentSchema
