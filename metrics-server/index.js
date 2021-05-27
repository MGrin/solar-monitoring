const express = require('express')
const bodyParser = require('body-parser')
const Redis = require('ioredis');
const cors = require('cors')

const io = require('./src/io')
const routes = require('./src/routes')

const env = process.env
require('elastic-apm-node').start({
  // // Use if APM Server requires a token
  secretToken: env.APM_SERVER_SECRET,
  // Set custom APM Server URL (default: http://localhost:8200)
  serverUrl: env.APM_SERVER_HOST
})
const start = async () => {
  const app = express()
  app.use(cors())

  const redisConfig = {
    host: env.REDIS_HOST,
    port: env.REDIS_PORT,
    name: env.REDIS_NAME,
    password: env.REDIS_PASSWORD,
  }
  
  app.redis = new Redis({
    sentinels: [
        {host: redisConfig.host, port: redisConfig.port}
    ],
    name: redisConfig.name,
    password: redisConfig.password,
    role: 'master'
  });

  process.on('SIGINT', () => {
    app.redis.keys("socket-*").then((keys) => {
      const pipeline = app.redis.pipeline()
      keys.forEach((k) => {
        pipeline.del(k)
      })
      pipeline.exec((err, result) => {
        if (err) {
          console.error(err)
          process.exit(1);
        }
        console.log(result)
        process.exit(0);
      })
      
    }).catch((e) => {
      console.error(e)
      process.exit(1)
    })
 });

  app.use(bodyParser.json());
  routes(app)
  const server = app.listen(env.PORT)

  const ioConfig = { token: env.SOCKET_AUTH_TOKEN }
  app.io = io.listen(server, app.redis, ioConfig)
}

start().catch((e) => {
  console.error(e)
})