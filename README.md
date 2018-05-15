# x2ntiment-engine
A text analyzer to tell the sentiment in a given text


## Getting started

```
git clone https://github.com/ajdurancr/x2ntiment-engine.git
cd x2ntiment-engine
npm install
npm run start
```

Then open [http://localhost:3000/graphiql](http://localhost:3000/graphiql)

A full example of the x2ntimentAnalysis query is:
```
{
  x2ntimentAnalysis {
    sentiment
    alpha
    kCategories
    text
    sentimentDetails {
      pos
      neg
    }
    occurrences {
      word
      occur
    }
    expectedFrequencyDistribution {
      pos {
        word
        freq
      }
      neg {
        word
        freq
      }
    }
    observedFrequencyDistribution {
      pos {
        word
        freq
      }
      neg {
        word
        freq
      }
    }
  }
}
```