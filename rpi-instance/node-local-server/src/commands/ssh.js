const ngrok = require('ngrok');
const { success, error } = require('./utils')

let tunnel = null
let closeTunnelTimeout = null

const closeTunnel = () => {
  ngrok.disconnect(tunnel)
  tunnel = null
  closeTunnelTimeout = null
}

module.exports = async (args) => {
  try {
    switch (args.action) {
      case 'open': {
        if (tunnel) {
          return success(args.id, `Tunnel already exists: pi@${tunnel}.`)
        }
  
        tunnel = await ngrok.connect({ authtoken: process.env.NGROK_AUTH_TOKEN, proto: 'tcp', addr: 22});
        closeTunnelTimeout = setTimeout(closeTunnel, args.expires)
        return success(args.id, `Tunnel is created: pi@${tunnel}. This tunnel will be closed in ${args.expires / (1000 * 60)} minutes.`)
      }
  
      case 'close': {
        if (!tunnel) {
          return success(args.id, `Tunnel was already closed`)
        }
  
        clearTimeout(closeTunnelTimeout)
        closeTunnel()

        return success(args.id, `Tunnel is closed`)
      }
    }
  } catch (e) {
    console.error(e)
    return error(args.id, e.message)
  }
}