local class = require 'middleclass'
require  'Core'
require 'Utils'

CoolGame = class('CoolGame',Core)

function CoolGame:_getInput(id)
  local input = {}
  local size = 7
  local s = 3
  local pI, pJ = self.players[id].x, self.players[id].y
  for i=1,size do
    for j=1,size do

      if Board.static.valid(pI+i-(s+1),pJ+j-(s+1)) then
        input[posToInt(i,j,size)] = self.board.cells[pI+i-(s+1)][pJ+j-(s+1)]
      else 
        input[posToInt(i,j,size)] = Board.static.death_cell
      end
    end
  end
  
  for _,otherId in ipairs(self.playerIDs) do
    if id ~= otherId then
      local other = self.players[otherId]
      local dI,dJ = other.x - pI, other.y - pJ
      if math.abs(dI) <= s and math.abs(dJ) <= s then
        input[posToInt(dI+(s+1),dJ+(s+1),size)] = 20
      end
    end
  end
  print("=========")
  printArray(input, size)
  
  return input
end

function CoolGame:getFitness(id)
  local distance = 0
  for _,otherId in ipairs(self.playerIDs) do
    if id ~= otherId then 
      distance = distance + BFS(self.players[id].x,self.players[id].y,self.board,self.players[otherId].x,self.players[otherId].y)
    end
  end
  distance = distance / #self.players
  if(distance == 0) then distance = 0.001 end --evitem dividir entre 0
  return (1/distance)
end

function CoolGame:updatePlayer(id)
  local player = self.players[id]

  local outputs = player:update(self:getInput(id))

  local lastX, lastY = player.x, player.y

  if(outputs[1] and not outputs[3]) then 
    player.y = player.y - 1
  elseif(not outputs[1] and outputs[3]) then 
    player.y = player.y + 1 
  end

  if(outputs[2] and not outputs[4]) then 
    player.x = player.x + 1
  elseif(not outputs[2] and outputs[4]) then 
    player.x = player.x - 1 
  end

  if(player.x > Board.static.size) then 
    player.x = lastX
  elseif(player.x < 1) then 
    player.x = lastX
  end

  if(player.y > Board.static.size) then 
    player.y = lastY
  elseif(player.y < 1) then 
    player.y = lastY
  end

  local currentCell = self.board.cells[player.x][player.y]

  if (player.x == lastX and player.y == lastY) then
    player.timeoutStuck = player.timeoutStuck - 1
    if player.timeoutStuck < 1 then
      player.alive = false
    end
  else
    player.timeoutStuck = Player.static.timeoutStuckConstant
  end 

  local fit = self:getFitness(id)
  
  if (fit > player.maxFitness) then
    player.maxFitness = fit
    player.timeoutRepeat = Player.static.timeoutRepeatConstant
  else
    player.timeoutRepeat = player.timeoutRepeat - 1
    if player.timeoutRepeat < 1 then
      player.alive = false
    end
  end

  if currentCell ~= Board.static.air_cell then
    player.alive = false
    player.x, player.y = lastX, lastY
  end 
end
