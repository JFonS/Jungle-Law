local class = require 'middleclass'
require 'Neat'

Player = class('Player') 

function Player:initialize(x, y)
  self.x = x or 1
  self.y = y or 1
  self.neat = Neat:new(0,8*8,4)
end


function Player:update(board) 
  print("sdafdssd")
  local inputs = {}
  for i=1, Board.static.size do
    for j=1, Board.static.size do
      inputs[#inputs + 1] = board.cells[i][j]
    end
  end

  local outputs = self.neat:evaluateCurrent(inputs)

  if(outputs[1] and not outputs[3]) then 
    self.y = self.y - 1
  elseif(not outputs[1] and outputs[3]) then 
    self.y = self.y + 1 
  end

  if(outputs[2] and not outputs[4]) then 
    self.x = self.x + 1
  elseif(not outputs[2] and outputs[4]) then 
    self.x = self.x - 1 
  end

  local lastX, lastY = self.x, self.y

  if(self.x > Board.static.size) then 
    self.x = lastX
    return -1
  elseif(self.x < 1) then 
    self.x = lastY
    return -1 
  end

  if(self.y > Board.static.size) then 
    self.y = lastY
    return -1 
  elseif(self.y < 1) then 
    self.y = lastY
    return -1 
  end
  
  board.cells[lastX][lastY] = Board.static.air_cell
  board.cells[self.x][self.y] = Board.static.player_cell
  
end

function getFitness()
  --local distance = math.abs(self.y - destRow) + math.abs(self.x - destCol)
  local distance = getDistanceToDestiny()
  if(distance == 0) then distance = 0.1 end --evitem dividir entre 0
  return (1/distance) / rounds
end

