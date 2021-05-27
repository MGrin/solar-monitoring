const sio = require('socket.io-client')
const ssh = require('./commands/ssh')

module.exports = (env) => {
  console.log(`Connecting to ${env.METRICS_WS_SERVER}`)
  const socket = sio(env.METRICS_WS_SERVER, {
    query: {
      token: env.SOCKET_AUTH_TOKEN,
      company_name: env.COMPANY_NAME,
      hardware_type: env.HARDWARE_TYPE,
      client_id: env.CLIENT_ID,
      installation_id: env.INSTALLATION_ID,
    }
  })
  
  socket.on('connect', () => {
    console.log('Connected to metrics io server')
  })
  socket.on('error', (e) => {
    // console.error(e)
  })
  
  socket.on('cmd', async (cmd, args) => {
    let output;
    switch (cmd) {
      case 'ssh': {
        output = await ssh(args)
        break
      }
      default: {
        output = {
          event: `error-${args.id}`,
          message: `Command ${cmd} is unknown`,
          id: args.id
        }
      }
    }

    socket.emit(output.event, output.message)
  })

  return socket
}