module.exports = {
  success: (id, message) => ({
    event: `success-${id}`,
    message,
    id
  }),
  error: (id, message) => ({
    event: `error-${id}`,
    message,
    id
  })
}