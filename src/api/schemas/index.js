import { schema } from 'dcr-graphql'

import resolvers from './resolvers'
import schemas from './schemas'

export default schema({ typeDefs: schemas, resolvers })
