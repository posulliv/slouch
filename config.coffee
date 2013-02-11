module.exports =
  port: process.env.PORT || 3000
  env: process.env.ENV || 'development'
  ak_host: process.env.ENV || 'localhost'
  ak_rest_port: process.env.ENV || '8091'
  ak_sql_port: process.env.ENV || '15432'
  ak_schema: process.env.ENV || 'test'
  ak_table: process.env.ENV || 'hopes'
  ak_db_url: 'postgres://localhost:15432/test'
  secret: process.env.SECUREKEY_GOLD_KEY || 'foo'
