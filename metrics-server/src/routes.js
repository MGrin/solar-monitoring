const { sendCommand } = require('./io')

const getTunnelHandler = (app) => async (req, res) => {
  const clientId = req.query.client
  const expires = req.query.expires || 1000 * 60 * 15

  if (!clientId) {
    return res.status(400).send({ message: 'No client id provided' })
  }
  if (!app.io.of('/').sockets.has(clientId)) {
    return res.status(400).send({ message: `Client ${clientId} is not connected` })
  }

  const client = app.io.of('/').sockets.get(clientId)
  try {
    const result = await sendCommand(client, 'ssh', { expires, action: 'open' })
    res.send({ message: result })
  } catch (e) {
    res.status(500).send({ message: e })
  }
}

const getConnectedClients = (app) => async (req, res) => {
  try {
    const keys = await app.redis.keys('socket-*')

    const calls = keys.map(async (socketId) => {
      const clientId = await app.redis.hget(socketId, "client_id")
      const installationId = await app.redis.hget(socketId, "installation_id")
      return {
        id: socketId.split("socket-")[1],
        clientId,
        installationId,
      }
    })
    const clients = await Promise.all(calls)
    res.set("Content-Range", `clients 0-${clients.length}/${clients.length}`)
    return res.send(clients)
  } catch (e) {
    return res.status(500).send({ message: e.message })
  }  
}

module.exports = (app) => {
  app.get('/tunnel', getTunnelHandler(app))
  app.get('/clients', getConnectedClients(app))
}