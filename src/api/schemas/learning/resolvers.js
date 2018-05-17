import controlledLearning from '../../../helpers/controlledLearning'

const controlledLearningInputChecker = {
  configs: (configs) => {
    if(!configs.length) throw 'There must be at least 1 configuration'
    
    configs.forEach(({ percentiles, percentilesToTake }, index) => {
      if(percentiles <= 0) throw `Error at configs[${index}]: must provide a value greater than 0 for percentiles`
      if(percentilesToTake > percentiles) throw `Error at configs[${index}]: percentilesToTake must be greater or equal to percentiles`
    })
  },
  textsWithSentiment: (textsWithSentiment) => {
    if(textsWithSentiment.length !== 2) throw 'There must be 2 sentiments for learning'
  },
}
const defaultInputChecker = () => {}

function validateArguments(args) {
  Object.keys(args).forEach((inputKey) => {
    (controlledLearningInputChecker[inputKey] || defaultInputChecker)(args[inputKey])
  })
}

const resolvers = {
  Mutation: {
    controlledLearning: (root, args) => {
      validateArguments(args)

      const { configs, textsWithSentiment } = args

      return configs.map((config) => {
        const { percentiles, percentilesToTake } = config
        const results = controlledLearning({ textsWithSentiment, percentiles, percentilesToTake })

        return { config, results }
      })
    }
  },
}

export default  resolvers