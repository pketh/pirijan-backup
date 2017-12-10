socket = io()
socket.on 'newUserConnected', (data) ->
  console.log 'user', data.color

socket.on 'drawRemoteSplatter', (data) ->
  addSplatter data.x, data.y, data.size, data.color

clientColor = randomColor({luminosity: 'light'})
palette = randomColor({luminosity: 'light', count: 3});
canvas = undefined
context = undefined
# windowWidth = window.innerWidth
# windowHeight = window.innerHeight
mouseDown = undefined
currentMousePosition = 
  x: undefined
  y: undefined
prevMousePosition = undefined
consecutiveSplatters = 1
MAX_CONSECUTIVE_SPLATTERS = 20
consecutiveRandomSplatters = 1
defaultSize = 50
# oldCanvas = undefined
canvasImage = undefined
# splatterHistory = []

window.onload = ->
  canvas = document.getElementById('background')
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  context = canvas.getContext('2d')

window.onresize = -> #? playback changes w history instead of scaling
#   console.log context
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  # context = canvas.getContext('2d')
  context.clearRect(0,0, window.innerWidth, window.innerHeight)
#   splatterHistory.forEach ({x, y, size, color}) ->
#     addSplatter x, y, size, color
  # image = new Image()
  # image.src = canvasImage
  console.log canvasImage
  context.putImageData(canvasImage, 0, 0)

window.onmousedown = ->
  startDragging()  

window.onmouseup = ->
  stopDragging()

window.onmousemove = (event) ->
  drag event
      
window.ontouchstart = ->
  startDragging()  
  
window.ontouchend = ->
  stopDragging()
  
window.ontouchmove = (event) ->
  drag event
    
window.setInterval ->
  addRandomSplatter()
, 1500

window.setInterval ->
  color = 'cyan'
  if prevMousePosition and mouseDown and consecutiveSplatters < MAX_CONSECUTIVE_SPLATTERS
    consecutiveSplatters += 1
  size = Math.round defaultSize * (consecutiveSplatters * 0.1)
  prevMousePosition = currentMousePosition
  if mouseDown
    addSplatter currentMousePosition.x, currentMousePosition.y, size, color
    socket.emit 'broadcastSplatter',
      x: currentMousePosition.x
      y: currentMousePosition.y
      size: size
      color: clientColor
, 25

startDragging = ->
  consecutiveSplatters = 1
  consecutiveRandomSplatters = 1
  mouseDown = true

drag = (event) ->
  if event.touches
    currentMousePosition = 
      x: event.touches[0].clientX
      y: event.touches[0].clientY
  else
    currentMousePosition = 
      x: event.clientX
      y: event.clientY

stopDragging = ->
  mouseDown = false

addSplatter = (x, y, size, color) ->
  if x and y
    color = color or _.sample palette
    size = size or defaultSize
    # console.log splatterHistory
    # splatterHistory.push {x, y, size, color}
    context.beginPath()
    context.arc(x, y, size, 0, 2 * Math.PI)
    context.closePath()
    context.fillStyle = color
    context.fill()
    canvasImage = context.getImageData(0, 0, window.innerWidth, window.innerHeight)

addRandomSplatter = ->
  maxX = window.innerWidth
  maxY = window.innerHeight
  x = _.random 0, maxX
  y = _.random 0, maxY
  if consecutiveRandomSplatters < MAX_CONSECUTIVE_SPLATTERS
    consecutiveRandomSplatters += 1
    addSplatter x, y

autoSplatter = ->
  currentDelay = 0
  AUTO_SPLATTERS.forEach (delay) ->
    setTimeout addRandomSplatter, currentDelay + delay
    currentDelay = currentDelay + delay

