const si = require('systeminformation');
const env = process.env

INTERVAL_ID = null

const readTestMetrics = (onData) => {
  const calls = [
    si.currentLoad(),
    si.mem(),
  ]

  Promise.all(calls).then(([cpu, mem]) => {
    const data = {
      cpu: cpu.currentload,
      mem: ((mem.active / mem.total) * 100),
    }
    onData(data)
  })
}

const start = (onData) => {
  if (INTERVAL_ID) {
    return
  }
  INTERVAL_ID = setInterval(() => readTestMetrics(onData), process.env.METRICS_INTERVAL)
}

const enrichMetricsData = (data) => ({
  ...data,
  companyName: env.COMPANY_NAME,
  hardwareType: env.HARDWARE_TYPE,
  clientId: env.CLIENT_ID,
  installationId: env.INSTALLATION_ID,
  random: Math.random(),
  timestamp: (new Date()).toISOString(),
})

module.exports = {
  start,
  readTestMetrics,
  enrichMetricsData
}