express = require('express')
config = require('./config')
uuid = require('node-uuid')
app = express.createServer()
_ = require('underscore')
akiban = require('./akiban_rest')
pg = require('pg').native
ak = new akiban.AkibanClient(config.ak_host, config.ak_rest_port)

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
    response.send res.body

app.post '/list', (request, response) ->
  hope = request.body
  ak.post config.ak_schema, config.ak_table, {desc: hope.desc, date: hope.date, bumpcount: hope.bumpcount}, (res) ->
    log('posted a hope')(res)
    response.send res.body

app.get '/list/:id', (request, response) ->
  ak.get config.ak_schema, config.ak_table, request.params.id, (res) ->
    log('retrieved an hope')(res)
    response.send res.body

app.put '/list/:id', (request, response) ->
  hope = request.body
  ak.put config.ak_schema, config.ak_table, request.params.id, {desc: hope.desc, date: hope.date, bumpcount: hope.bumpcount}, (res) ->
    log('updated a hope')(res)
    response.send res.body

app.delete '/list/:id', (request, response) ->
  ak.del config.ak_schema, config.ak_table, request.params.id, (res) ->
    response.send 'ok'

console.log("port: #{config.port}")
app.listen config.port

