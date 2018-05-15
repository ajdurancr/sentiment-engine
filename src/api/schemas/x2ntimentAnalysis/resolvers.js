import x2ntimentResult from '../../../mock/x2ntimentResults'

const resolvers = {
  Query: {
    x2ntimentAnalysis: () => x2ntimentResult,
  }
}

export default  resolvers