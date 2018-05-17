import { Server } from 'dcr-engine'
import { createApi } from 'dcr-graphql'
import schema from './src/api/schemas'

const init = async () => {
  const server =  new Server({ port: 3000 }, createApi)
  
  await server.createApi({ api: 'x2ntiment', graphiql: true, schema })
  
  server.start()
}

init()
