express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'
engines = require 'consolidate'
bodyParser = require 'body-parser'
stylish = require 'stylish'
autoprefixer = require 'autoprefixer-stylus'

PORT = process.env.PORT

# ENVIRONMENT = process.env.ENVIRONMENT
# production = undefined
# if ENVIRONMENT is 'production'
#   production = true

# PODCAST = 
#   title: 'Good Goods'
#   soundcloud: 'https://soundcloud.com/good-goods'
#   itunes: 'https://itunes.apple.com/us/podcast/good-goods/id1217665170?mt=2'

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

app.listen PORT, ->
  console.log "Your app is running on #{PORT}"

# ROUTES

app.get '/', (request, response) ->
  response.render 'index' #,
    # title: PODCAST.title
    # production: production
