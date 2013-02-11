express = require('express')
config = require('./config')
uuid = require('node-uuid')
app = express.createServer()
_ = require('underscore')
akiban = require('./akiban_rest')
ak = new akiban.AkibanClient()

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

app.get '/', (request, response) ->
  response.render('index', title: 'hom3e')

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

app.get '/list', (request, response) ->
  ak.get 'test', 'hopes', '', (res) ->
    log('retrieved')(res)
    response.send(res.body)

app.post '/list', (request, response) ->
  hope = request.body
  hope.id = uuid()
  #ak.post 'test', 'hopes', JSON.stringify(hope), (res) ->
  ak.post 'test', 'hopes', {id: hope.id, desc: hope.desc, date: hope.date, bumpCount: hope.bumpCount}, (res) ->
    log('posted an hope')(res)
  response.send( JSON.stringify(hope) )

app.get '/list/:id', (request, response) ->
  ak.get 'test', 'hopes', request.params.id, (res) ->
    log('retrieved an hope')(res)
    response.send JSON.stringify(res)

app.put '/list/:id', (request, response) ->
  hope = request.body
  ak.put 'test', 'hopes', {id: hope.id, desc: hope.desc, date: hope.date, bumpCount: hope.bumpCount}, request.params.id, (res) ->
    response.send res

app.delete '/list/:id', (request, response) ->
  ak.del 'test', 'hopes', request.params.id, (res) ->
    response.send 'ok'

console.log("port: #{config.port}")
app.listen config.port

