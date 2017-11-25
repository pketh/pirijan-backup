PALETTE = ['fuchsia', 'blue', 'cyan', 'red', 'yellow', 'lime']
canvas = undefined
context = undefined
windowWidth = undefined

mouseDown = undefined
currentMousePosition = 
  x: undefined
  y: undefined
prevMousePosition = undefined
consecutiveSplatters = 1
maxConsecutiveSplatters = 20
defaultSize = 50

prevColor = undefined

window.onload = ->
  windowWidth = window.innerWidth
  canvas = document.getElementById('background')
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  context = canvas.getContext('2d')

window.onmousedown = ->
  consecutiveSplatters = 1
  mouseDown = true

window.onmouseup = ->
  mouseDown = false
  
window.onmousemove = ->
  currentMousePosition = 
    x: event.clientX
    y: event.clientY

window.setInterval ->
  addRandomSplatter()
, 1000


window.setInterval ->
  color = 'cyan'
  # color = randomColor()
    # luminosity: 'light'
  if prevMousePosition and mouseDown and consecutiveSplatters < maxConsecutiveSplatters
    consecutiveSplatters += 1
  size = Math.round defaultSize * (consecutiveSplatters * 0.1)
  prevMousePosition = currentMousePosition
  if mouseDown
    addSplatter currentMousePosition.x, currentMousePosition.y, size, color
, 25

window.onresize = -> #?
  if window.innerWidth != windowWidth
    windowWidth = window.innerWidth
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight + 20
    context = canvas.getContext('2d')


    
addSplatter = (x, y, size, color) ->
  if x and y
    color = color or _.sample PALETTE
    size = size or defaultSize
    context.beginPath()
    context.arc(x, y, size, 0, 2 * Math.PI)
    context.closePath()
    context.fillStyle = color
    context.fill()

addRandomSplatter = ->
  # console.log 'addRandomSplatter'
  maxX = window.innerWidth
  maxY = window.innerHeight
  x = _.random 0, maxX
  y = _.random 0, maxY
  # 🐸🐸🐸🐸🐸🐸
  addSplatter x, y



autoSplatter = ->
  currentDelay = 0
  AUTO_SPLATTERS.forEach (delay) ->
    setTimeout addRandomSplatter, currentDelay + delay
    currentDelay = currentDelay + delay

# drawSplatter = (event) ->
#   console.log 'drawsplatter', event
    
    
    
    
    
# randomKoamoji = ->
#   KAOMOJI = [
#     '( ^_^)／'
#     '~ヾ(＾∇＾)'
#     '＼(°o°；）'
#     '＼(￣O￣)'
#   ]
#   _.sample(KAOMOJI) + ' '
