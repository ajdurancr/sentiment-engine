const knowledgeSchema = `
  type Knowledge {
    knowledgeId: Int
    name: String
  }

  extend type Query {
    getKnowledge(knowledgeId: [Int]): [Knowledge]
  }

  extend type Mutation {
    addKnowledge(name: String!): Knowledge

    updateKnowledge(
      knowledgeId: Int!

      name: String
    ): Knowledge
  }
`

export default knowledgeSchema
