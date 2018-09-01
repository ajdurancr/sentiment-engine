const sentimentSchema = `
  type Sentiment {
    sentimentId: Int
    name: String
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
