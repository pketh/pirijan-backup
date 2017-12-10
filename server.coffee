express = require 'express'
app = express()
server = require('http').Server(app)
io = require('socket.io')(server)
coffeeMiddleware = require 'coffee-middleware'
engines = require 'consolidate'
bodyParser = require 'body-parser'
stylish = require 'stylish'
autoprefixer = require 'autoprefixer-stylus'

PORT = process.env.PORT

app.use(express.static('public'))

# sets up pug
app.set('view engine', 'pug')

# sets up coffee-script support
app.use coffeeMiddleware
  bare: true
  src: "public"
require('coffee-script/register')

app.use bodyParser.urlencoded
  extended: false
app.use bodyParser.json()
app.use bodyParser.text()

# sets up stylus and autoprefixer
app.use stylish
  src: __dirname + '/public'
  setup: (renderer) ->
    renderer.use autoprefixer()
  watchCallback: (error, filename) ->
    if error
      console.log error
    else
      console.log "#{filename} compiled to css"

server.listen PORT, ->
  console.log "Your app is running on #{PORT}"

io.on 'connection', (socket) ->
  socket.on 'broadcastSplatter', (data) ->
    socket.broadcast.emit('drawRemoteSplatter', data)

  socket.on 'disconnect', (data) ->
    socket.broadcast.emit('userDisconnected', data)


# ROUTES

app.get '/', (request, response) ->
  response.render 'index'
