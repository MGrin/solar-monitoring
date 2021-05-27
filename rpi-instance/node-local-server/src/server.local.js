const http = require('http')

let LAST_METRIC = undefined

class LocalServer {
  constructor(port) {
    this.port = port
    this.server = http.createServer(this.handler)
  }

  listen() {
    this.server.listen(this.port, (err) => {
      if (err) {
        throw err
      }
      console.log(`Local server started at port ${this.port}`)
    })
  }

  handler(request, response) {
    if (request.url !== `/metrics`) {
      response.statusCode = 404
      return response.end()
    }
    response.end(JSON.stringify(LAST_METRIC))
  }

  setMetric(metric) {
    LAST_METRIC = metric
  }
}

module.exports = LocalServer