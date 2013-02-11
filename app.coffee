express = require('express')
config = require('./config')
uuid = require('node-uuid')
app = express.createServer()
_ = require('underscore')
akiban = require('./akiban_rest')
pg = require('pg').native
ak = new akiban.AkibanClient(config.ak_host, config.ak_rest_port)
#db = new pg.Client(config.ak_db_url)
db = new pg.Client(
  host: config.ak_host,
  port: config.ak_sql_port,
  database: config.ak_schema
)
db.connect()

app.configure( ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.logger())
  app.use(express.cookieParser())
  app.use(express.session({ secret: 'foobar' }))
  app.use(express.bodyParser())
  app.use(require('connect-assets')() )
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))
)

log = (msg) ->
  () ->
    console.log("========")
    console.log(msg)
    console.log("--------")
    unless arguments[0].error
      _(arguments[0].body).forEach (x) ->
        console.log(x)
    console.log(arguments) if arguments[0].error
    console.log("--------")

app.get '/', (request, response) ->
  response.render('index', title: 'Home')

app.get '/list', (request, response) ->
  ak.get config.ak_schema, config.ak_table, '', (res) ->
    log('retrieved')(res)
    response.send(res.body)

app.post '/list', (request, response) ->
  hope = request.body
  #ak.post config.ak_schema, config.ak_table, JSON.stringify(hope), (res) ->
  ak.post config.ak_schema, config.ak_table, {desc: hope.desc, date: hope.date, bumpcount: hope.bumpcount}, (res) ->
    log('posted a hope')(res)
  response.send( JSON.stringify(hope) )

app.get '/list/:id', (request, response) ->
  ak.get config.ak_host, config.ak_table, request.params.id, (res) ->
    log('retrieved an hope')(res)
    response.send JSON.stringify(res)

app.put '/list/:id', (request, response) ->
  hope = request.body
  # TODO - PUT to update an entity not supported at the moment
  # once that support is added, modify this
  db.query(
    "update #{config.ak_table} set bumpcount = #{hope.bumpcount} where id = #{hope.id}"
  )
  response.send( JSON.stringify(hope) )

app.delete '/list/:id', (request, response) ->
  ak.del config.ak_schema, config.ak_table, request.params.id, (res) ->
    response.send 'ok'

console.log("port: #{config.port}")
app.listen config.port

