const LocalServer = require('./src/server.local')
const monitoring = require('./src/monitoring')

const env = process.env

monitoring.start((metric) => {
  const enrichedMetric = monitoring.enrichMetricsData(metric)
  localServer.setMetric(enrichedMetric)
})

const localServer = new LocalServer(env.LOCAL_METRICS_PORT)
localServer.listen()



