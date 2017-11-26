# PALETTE = ['fuchsia', 'blue', 'cyan', 'red', 'yellow', 'lime']
# PALETTE = ['plum', 'cyan', 'pink']
palette = randomColor({luminosity: 'light', count: 3});
canvas = undefined
context = undefined
windowWidth = undefined
mouseDown = undefined
currentMousePosition = 
  x: undefined
  y: undefined
prevMousePosition = undefined
consecutiveSplatters = 1
MAX_CONSECUTIVE_SPLATTERS = 20
consecutiveRandomSplatters = 1
defaultSize = 50

window.onload = ->
  windowWidth = window.innerWidth
  canvas = document.getElementById('background')
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  context = canvas.getContext('2d')

window.onmousedown = ->
  consecutiveSplatters = 1
  consecutiveRandomSplatters = 1
  mouseDown = true
  
window.onmouseup = ->
  mouseDown = false

window.onmousemove = ->
  currentMousePosition = 
    x: event.clientX
    y: event.clientY




window.ontouchstart = ->
  # console.log 'touchstart', event
  consecutiveSplatters = 1
  consecutiveRandomSplatters = 1
  mouseDown = true
  
window.ontouchend = ->
  # console.log 'touchend'
  mouseDown = false
  
window.ontouchmove = (event) ->
  # console.log 'touchmove', event
  currentMousePosition = 
    x: event.touches[0].clientX
    y: event.touches[0].clientY

    
    
window.setInterval ->
  addRandomSplatter()
, 1500


window.onresize = -> #?
  console.log 'onresize'
  if window.innerWidth != windowWidth
    windowWidth = window.innerWidth
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight + 20
    context = canvas.getContext('2d')


window.setInterval ->
  # console.log 'yo'
  color = 'cyan' # 🔥
  # color = randomColor()
    # luminosity: 'light'
  if prevMousePosition and mouseDown and consecutiveSplatters < MAX_CONSECUTIVE_SPLATTERS
    consecutiveSplatters += 1
  size = Math.round defaultSize * (consecutiveSplatters * 0.1)
  prevMousePosition = currentMousePosition
  # console.log 'moustdown', mouseDown
  if mouseDown
    addSplatter currentMousePosition.x, currentMousePosition.y, size, color
, 25
    
addSplatter = (x, y, size, color) ->
  if x and y
    color = color or _.sample palette
    size = size or defaultSize
    context.beginPath()
    context.arc(x, y, size, 0, 2 * Math.PI)
    context.closePath()
    context.fillStyle = color
    context.fill()

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

