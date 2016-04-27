require! {
  'when': wn
  'express'
  'http'
  'socket.io'
  './core/init': initCorePromise
}

<- initCorePromise.then
lib = require './lib'
namespaces = require './namespaces'

app = express()
server = http.createServer app
io = socket server
# test Socket Server:
# soc.emit('callee', {fn: 'testModule/test', params: {name: "pouria"}})
io.on 'connection', (socket) ->
  socket.emit \message,
    title: '-- Hello Dude --'

  socket.on \callee, (data) ->
    try
      requestKey = data.requestKey or "invalid_key"
      namespaces[data.fn](data.params)
      .then (result) ->
        response = {requestKey, result}
        socket.send(response)
      .catch (error) ->
        console.log error
        result = {success: false, msg: "Wrong function call"}
        response = {requestKey, result}
        socket.send(response)
    catch error
      # baby I'm hard to break
      # TODO: use error handler to store log file in server
      # TODO: use pretty-error to show error in server console
      console.log error
      requestKey = data.requestKey or "invalid_key"
      result = {success: false, msg: "Wrong function call"}
      response = {requestKey, result}
      socket.send(response)

# test REST Server:
# http://localhost:3000/testModule/test?name=pouria
server.listen 3000, ->
  app.get \*, (req, res) ->
    try
      params = req.query
      requestKey = params.requestKey
      fn = req.path.substring(1)
      if namespaces[fn]?
        namespaces[fn](params)
        .then (result) ->
          response = {requestKey, result}  
          res.json response
      else
        res.json {success: false, msg: "404"}
    catch error
      res.json({success: false, msg: "Wrong function call"})

  console.log 'REST/Socket Server is online over port 3000'
