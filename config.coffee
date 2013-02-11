module.exports =
  port: process.env.PORT || 3000
  env: process.env.ENV || 'development'
  secret: process.env.SECUREKEY_GOLD_KEY || 'foo'
