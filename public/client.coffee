socket = io()
clientColor = undefined
canvas = undefined
context = undefined
mouseDown = undefined
currentMousePosition = 
  x: undefined
  y: undefined
prevMousePosition = undefined
consecutiveShapes = 1
clientToolSize = 15 # 10?, 25, 50
paintInterval = 10
canvasImage = undefined # TODO i can use this at any time to save the canvas circles/shapes
totalUsers = 1
clientShape = 'circle' # circle, tree
previousColors = ['white']
clientHistory = []
clientUndoHistory = [] # clears when you add a new shape
currentStroke = [] # all shapes in the current drag

palette = document.querySelectorAll('.color')
copyUrlButton = document.querySelector('#copy-url')
toolButtons = document.querySelectorAll('.tools button')
circleShapeButton = document.querySelector('#circle-shape')
treeShapeButton = document.querySelector('#tree-shape')
newPaletteButton = document.querySelector('#new-palette')
previousColorsDetails = document.querySelector('#previous-colors')
sizeSlider = document.querySelector('#size-slider')

undoButton = document.querySelector('#undo')
redoButton = document.querySelector('#redo')


# init and remote updates

socket.on 'newUserConnected', (totalUsers) ->
  updateConnectedUsers totalUsers

socket.on 'drawRemoteShape', (data, totalUsers) ->
  updateConnectedUsers totalUsers
  addShape data.shape, data.x, data.y, data.size, data.color

socket.on 'userDisconnected', (data, totalUsers) ->
  updateConnectedUsers totalUsers

window.onload = ->
  canvas = document.getElementById('background')
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  context = canvas.getContext('2d')
  updatePalette()
  
  canvas.onmousedown = ->
    startDragging()
  canvas.onmouseup = ->
    stopDragging()
  canvas.onmousemove = (event) ->
    drag event
  canvas.ontouchstart = ->
    startDragging()  
  canvas.ontouchend = (event) ->
    stopDragging()
  canvas.ontouchmove = (event) ->
    drag event

window.onresize = -> 
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  context.clearRect(0,0, window.innerWidth, window.innerHeight)
  context.putImageData(canvasImage, 0, 0)

clearPaletteSelectedColor = ->
  palette.forEach (color) ->
    color.className = 'color'
  
updatePalette = ->
  clearPaletteSelectedColor()
  randomColors = randomColor({count: 5})
  palette.forEach (color, index) ->
    color.style.backgroundColor = randomColors[index]
  palette[0].classList.toggle 'selected'
  clientColor = palette[0].style.backgroundColor

initPalettes = ->
  palette = document.querySelectorAll('.color')
  palette.forEach (color) -> 
    color.onclick = (event) ->
      clearPaletteSelectedColor()
      clientColor = event.target.style.backgroundColor
      event.target.classList.add 'selected'

initPalettes()

newPaletteButton.onclick = ->
  updatePalette()

broadcastShape = (shape, x, y, size, color) ->
  socket.emit 'broadcastShape',
    shape: shape
    x: currentMousePosition.x
    y: currentMousePosition.y
    size: size
    color: color

    
# size

sizeSlider.oninput = (event) ->
  clientToolSize = event.target.value
  sizeValue = document.querySelector('#size-value')
  sizeValue.innerText = clientToolSize
    

# previous colors
  
updatePreviousColors = ->
  previousColors = _.uniq previousColors 
  colorsInPopOver = previousColorsDetails.querySelector('.pop-over .colors')
  colorsInPopOver.innerHTML = ""  
  previousColors.forEach (previousColor) ->
    color = document.createElement('button')
    color.setAttribute('class', 'color')
    color.style.backgroundColor = previousColor
    if previousColor is clientColor
      color.classList.add 'selected'
    colorsInPopOver.appendChild color
  initPalettes()

previousColorsDetails.ontoggle = ->
  updatePreviousColors()


# drawing

addShape = (shape, x, y, size, color) ->
  currentStroke.push
    shape: shape
    x:x
    y:y
    size:size
    color:color
  
  if shape is 'circle'
    addCircle x, y, size, color
  else if shape is 'tree'
    addTree x, y, size, color
  
startDragging = ->
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
  consecutiveShapes = 1
  previousColors.push clientColor
  updatePreviousColors()
  clientHistory.push currentStroke
  currentStroke = []
  clientUndoHistory = []
  console.log event # required for ios

initDragging = ->
  if mouseDown and prevMousePosition and consecutiveShapes <= 25
    consecutiveShapes += 1
  if mouseDown
    clientSize = Math.round clientToolSize * (consecutiveShapes * 0.1) # 0.01 = smallest, 0.5 = big
    prevMousePosition = currentMousePosition
    addShape(clientShape, currentMousePosition.x, currentMousePosition.y, clientSize, clientColor)
    broadcastShape(clientShape, currentMousePosition.x, currentMousePosition.y, clientSize, clientColor)

interval = window.setInterval initDragging, paintInterval


# select shape

clearSelectedTools = ->
  toolButtons.forEach (button) ->
    button.classList.remove 'active'

setPaintIntervals = (intervalTime) -> 
  clearInterval(interval)
  interval = window.setInterval initDragging, intervalTime

circleShapeButton.onclick = ->
  clientShape = 'circle'
  clearSelectedTools()
  circleShapeButton.classList.add 'active'
  setPaintIntervals 10

treeShapeButton.onclick = ->
  clientShape = 'tree'
  clearSelectedTools()
  treeShapeButton.classList.add 'active'
  setPaintIntervals 200


# about this site

updateConnectedUsers = (connectedUsers) ->
  totalUsers = connectedUsers
  count = document.getElementById('count')
  if totalUsers is 1
    friendPlural = "friend"
  else
    friendPlural = "friends"
  count.textContent = totalUsers


# SHAPE: circles ⏺
  
addCircle = (x, y, size, color) ->
  # color = color or _.sample palette
  context.beginPath()
  context.arc(x, y, size, 0, 2 * Math.PI)
  context.closePath()
  context.fillStyle = color
  context.fill()
  canvasImage = context.getImageData(0, 0, window.innerWidth, window.innerHeight)
    

# SHAPE: trees 🌲

treePoint = (position, newPosition) ->
  position + newPosition - 40
  
addTree = (x, y, size, color) ->
  context.beginPath  
  context.moveTo(treePoint(94.12, x), treePoint(51.11, y))
  context.lineTo(treePoint(65.51, x), treePoint(51.11, y))
  context.lineTo(treePoint(94.12, x), treePoint(83.29, y))
  context.lineTo(treePoint(56, x),    treePoint(83.29, y))
  context.lineTo(treePoint(56, x),    treePoint(106, y))
  context.lineTo(treePoint(38, x),    treePoint(106, y))
  context.lineTo(treePoint(38, x),    treePoint(83.29, y))
  context.lineTo(treePoint(-0.12, x), treePoint(83.29, y))
  context.lineTo(treePoint(28.49, x), treePoint(51.11, y))
  context.lineTo(treePoint(-0.12, x), treePoint(51.11, y))
  context.lineTo(treePoint(47, x),    treePoint(0, y))
  context.lineTo(treePoint(94.12, x), treePoint(51.11, y))  
  context.fillStyle = color
  context.fill()
  context.closePath()
  
  # canvasImage = context.getImageData(0, 0, window.innerWidth, window.innerHeight)


# copy url

copyUrlButton.onclick = ->
  urlInput = document.querySelector('#url')
  copyUrlButton.innerText = "Copied"
  copyUrlButton.classList += ' copied'
  urlInput.setSelectionRange(0, 999)
  document.execCommand("copy")
  urlInput.blur()
  


undoButton.onclick = ->
  console.log '🌹', clientHistory.length
  lastStroke = clientHistory.slice(-1)
  clientUndoHistory.push(lastStroke)
  clientHistory.pop()
  console.log '🍡', clientHistory.length
  
  context.clearRect(0, 0, canvas.width, canvas.height)
  lastStroke[0].forEach (data) ->
    # console.log data
    addShape data.shape, data.x, data.y, data.size, data.color


redoButton.onclick = ->
  context.clearRect(0, 0, canvas.width, canvas.height)
  clientHistory.push clientUndoHistory.slice(-1)
