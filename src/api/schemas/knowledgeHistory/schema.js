const knowledgeHistorySchema = `
  # Configurations to be used during the learning process
  input KnowledgeHistoryImprovementInput {
    sentimentId: Int!
    knowledgeId: Int!
    knowledgeModelId: Int!
    text: [String]!
  }

  type KnowledgeHistory {
    sentimentId: Int
    knowledgeId: Int
    knowledgeModelId: Int
    word: String
    occurrence: Int
  }

  type KnowledgeHistoryWithMetadata {
    sentimentId: Int
    knowledgeId: Int
    knowledgeModelId: Int
    word: String
    occurrence: Int
    persist: Boolean
    acknowledged: Boolean
    createdAt: String
    updatedAt: String
  }

  type ImprovedKnowledgeHistory {
    newKnowledgeHistory: [KnowledgeHistory]
    updatedKnowledgeHistory: [KnowledgeHistoryWithMetadata]
  }

  extend type Mutation {
    improveKnowledgeHistory(
      knowledgeHistoryInput: [KnowledgeHistoryImprovementInput]!
    ): ImprovedKnowledgeHistory
  }
`

export default knowledgeHistorySchema
