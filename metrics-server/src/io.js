const sio = require('socket.io')
const { v4: uuid } = require('uuid')
const redisAdapter = require('socket.io-redis');

const listen = (server, redis, ioConfig) => {
  const io = sio(server, {
    serveClient: false,
    adapter: redisAdapter({ pubClient: redis, subClient: redis.duplicate() }),
  })

  io.use((socket, next) => {
    if (socket.handshake.query.token === ioConfig.token) {
      return next();
    }
    console.error('Authentication error')
    next(new Error('Authentication error'));
  });

  io.of('/').adapter.on('error', (err) => console.error(err));

  io.on('connection', async (socket) => {
    redis.hset(`socket-${socket.id}`, "client_id", socket.handshake.query.client_id)
    redis.hset(`socket-${socket.id}`, "installation_id", socket.handshake.query.installation_id)
    redis.hset(`socker-${socket.id}`, "company_name", socket.handshake.query.company_name)
    redis.hset(`socker-${socket.id}`, "hardware_type", socket.handshake.query.hardware_type)

    socket.on('disconnect', (reason) => {
      console.log(`Client left: ${socket.id}. Reason: ${reason}`);
      redis.del(`socket-${socket.id}`)
    });
  })

  console.log("WebSockets are listening")
  return io
}

const sendCommand = (client, cmd, args) => new Promise((resolve, reject) => {
  const id = uuid()

  const successListener = (message) => {
    console.log(message)
    client.off(`success-${id}`, successListener)
    client.off(`error-${id}`, errorListener)
    return resolve(message)
  }
  const errorListener = (message) => {
    console.error(message)
    client.off(`success-${id}`, successListener)
    client.off(`error-${id}`, errorListener)
    return reject(message)
  }

  client.emit('cmd', cmd, { ...args, id })
  client.on(`success-${id}`, successListener)
  client.on(`error-${id}`, errorListener)
})

module.exports = {
  listen,
  sendCommand
}