import x2ntimentResult from '../../../mock/x2ntimentResults'

const resolvers = {
  Query: {
    analysis: () => x2ntimentResult,
  }
}

export default  resolvers