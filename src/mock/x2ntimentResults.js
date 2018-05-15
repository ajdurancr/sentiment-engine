export default {
    sentiment: 'Neutral',
    alpha: 0.5,
    kCategories: 4,
    text: 'This is a test',
    sentimentDetails: { pos: false, neg: false },
    occurrences: [{ word: 'test', occur: 1 }],
    expectedFrequencyDistribution: {
      neg: [{ word: 'test', freq: 0.2 }],
      pos: [{ word: 'test', freq: 0.4 }],
    },
    observedFrequencyDistribution: {
      neg: [{ word: 'test', freq: 0.4 }],
      pos: [{ word: 'test', freq: 0.2 }],
    }
  }