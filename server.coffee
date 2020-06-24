express = require 'express'
app = express()
server = require('http').Server(app)
io = require('socket.io')(server)
coffeeMiddleware = require 'coffee-middleware'
engines = require 'consolidate'
bodyParser = require 'body-parser'
stylish = require 'stylish'
autoprefixer = require 'autoprefixer-stylus'
totalUsers = 0

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


# socket instructions
  
io.on 'connection', (socket) ->
  totalUsers += 1
  socket.broadcast.emit('newUserConnected', totalUsers)
  
  socket.on 'broadcastShape', (data) ->
    socket.broadcast.emit('drawRemoteShape', data, totalUsers)

  socket.on 'disconnect', (data) ->
    totalUsers -= 1
    socket.broadcast.emit('userDisconnected', data, totalUsers)


# ROUTES

app.get '/', (request, response) ->
  response.render 'index'
