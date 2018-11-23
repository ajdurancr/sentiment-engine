const knowledgeModelSchema = `

  type KnowledgeModel {
    knowledgeModelId: Int
    name: String
    alpha: Float
    percentiles: Int
    percentilesToTake: Int
  }

  type KnowledgeModelWithKnowledge {
    knowledgeModelId: Int
    name: String
    alpha: Float
    percentiles: Int
    percentilesToTake: Int
    knowledge: [KnowledgeWithSentiments]
  }

  extend type Query {
    getKnowledgeModels(knowledgeModelId: [Int]): [KnowledgeModel]
  }

  extend type Mutation {
    addKnowledgeModel(
      name: String!
      alpha: Float!
      percentiles: Int!
      percentilesToTake: Int!
    ): KnowledgeModel

    updateKnowledgeModel(
      knowledgeModelId: Int!
      name: String
      alpha: Float
      percentiles: Int
      percentilesToTake: Int
    ): KnowledgeModel
  }
`

export default knowledgeModelSchema
