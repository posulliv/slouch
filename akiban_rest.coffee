exports = this
request = require('request')
_       = require('underscore')

class AkibanClient
  constructor: (@host, @port) ->
    @host = @host || 'localhost'
    @port = @port || '8091'
    @base = "http://#{@host}:#{@port}/v1/entity"

  _do_request : (method, path, body, options, cc) ->
    req_opts =
  	  uri     : @base + path
  	  method  : method
  	  body    : body
  	  is_json : if (options && options.is_json) then options.is_json else true
  	  headers : if (options && options.headers) then options.headers else {"Content-Type" : "application/json","Accept" : "application/json"}
  	  timeout : 5000
    ret_val = new AkibanResult(req_opts, cc)
    x = request(req_opts, ret_val._handler())
    # console.log x
    x

  _get : (path, options, cc) =>
    @_do_request('GET', path, null, options, cc)

  _post : (path, body, options, cc) =>
    @_do_request('POST', path, (if !options || options.is_json then JSON.stringify(body) else body), options, cc)

  _put : (path, body, options, cc) =>
    @_do_request('PUT', path, (if !options || options.is_json then JSON.stringify(body) else body), options, cc)

  _delete : (path, options, cc) =>
    @_do_request('DELETE', path, null, options, cc)

  version  : (cc) => @_get("/version", null, cc)
  schemata : (cc) => @_get("/schemata", null, cc)
  execute  : (sql, cc)    => @_post("/execute", sql, {is_json:false}, cc)
  query    : (query, cc)  => @_get("/query?q=#{escape(query)}", null, cc)
  groups   : (schema, cc) => @_get("/groups/#{schema}", null, cc)
  tables   : (schema, cc) => @_get("/tables/#{schema}", null, cc)
  table    : (schema, table, cc) => @_get("/tables/#{schema}.#{table}", null, cc)
  page     : (schema, table, offset, limit, cc) => @_get("/#{schema}.#{table}?offset=#{offset || 0}&limit=#{limit || 100}", null, cc)
  mget     : (schema, table, ids, cc)        => @_get("/#{schema}.#{table}/#{ids.join(';')}", null, cc)
  get      : (schema, table, id, cc)         => @_get("/#{schema}.#{table}/#{id}", null, cc)
  post     : (schema, table, object, cc)     => @_post("/#{schema}.#{table}", object, null, cc)
  put      : (schema, table, id, object, cc) => @_put("/#{schema}.#{table}/#{id}", object, null, cc)
  mdel     : (schema, table, ids, cc)        => @_delete("/#{schema}.#{table}/#{ids.join(';')}", null, cc)
  del      : (schema, table, id, cc)         => @_delete("/#{schema}.#{table}/#{id}", null, cc)

class AkibanResult
  constructor: (@request, @cc) ->
    @finished     = false
    @error        = false
    @error_detail = null
    @statusCode   = null
    @reason       = null
    @content_type = null
    @t1           = Date.now()
    @t2           = null

  _handler : () ->
    ret = this
    (error, response, result) ->
      ret._decode(error, response, result)
      ret.finished = true
      ret.t2 = Date.now()
      ret.cc(ret) if ret.cc

  _decode : (error, response, result) ->
	  if (!error)
      @status = response.statusCode
      @content_type = response.headers['content-type']
      if @status >= 200 && @status < 300
        @error = false
        @body  = if (result && result.length > 1) then (if (@content_type == "application/json") then JSON.parse(result) else result) else null
      else
        if @status >= 400 && @status < 500
          @error  = true
          @reason = if (result && result.length > 0) then result else null
          @body   = null
        else
          @error = true
          @reason = result
    else
      @error = true
      @error_detail = error
      @status = null
      @reason = error["message"]
      @body   = null

  isError       : () -> !!@finished && !!@error
  isFinished    : () -> !!@finished
  requestTimeMS : () -> if @isfinished() then (@t2 - @t1) else undefined

exports.AkibanClient = AkibanClient
