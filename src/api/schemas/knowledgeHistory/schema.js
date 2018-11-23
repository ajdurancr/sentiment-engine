const knowledgeHistorySchema = `
  # Configurations to be used during the learning process
  input KnowledgeHistoryImprovementInput {
    sentimentId: Int!
    knowledgeId: Int!
    knowledgeModelId: Int!
    text: [String]!
  }

  type KnowledgeHistory {
    word: String
    occurrence: Int
    persist: Boolean
    acknowledged: Boolean
    createdAt: String
    updatedAt: String
  }

  type KnowledgeHistoryImprovement {
    # Knowledge to be added to knowledge history
    newKnowledgeHistory: [KnowledgeModelWithKnowledge]

    # Knowledge after knowledge history was updated
    updatedKnowledgeHistory: [KnowledgeModelWithKnowledge]
  }

  extend type Query {
    getKnowledgeHistory(persistMode: Boolean!): [KnowledgeModelWithKnowledge]
  }

  extend type Mutation {
    improveKnowledgeHistory(
      knowledgeHistoryInput: [KnowledgeHistoryImprovementInput]!
    ): KnowledgeHistoryImprovement

    improveAutomatedKnowledgeHistory(
      knowledgeHistoryInput: [KnowledgeHistoryImprovementInput]!
    ): KnowledgeHistoryImprovement

    updateKnowledgeHistoryFromAutomatedKnowledge: KnowledgeHistoryImprovement
  }
`

export default knowledgeHistorySchema
