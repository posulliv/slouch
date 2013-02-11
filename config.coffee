module.exports =
  port: process.env.PORT || 3000
  env: process.env.ENV || 'development'
  ak_host: process.env.ENV || 'localhost'
  ak_rest_port: process.env.ENV || '8091'
  ak_schema: process.env.ENV || 'test'
  ak_table: process.env.ENV || 'hopes'
  secret: process.env.SECUREKEY_GOLD_KEY || 'foo'
