local class = require 'middleclass'
require 'Neat'
require 'bfs'

Player = class('Player') 

Player.static.timeoutStuckConstant = 5
Player.static.timeoutRepeatConstant = 50

function Player:initialize(x, y)
  self.x = x or 1
  self.y = y or 1
  self.start = {}
  self.start.x, self.start.y = self.x, self.y
  self.timeoutStuck = Player.static.timeoutStuckConstant
  self.timeoutRepeat = Player.static.timeoutRepeatConstant
  self.rounds = 0
  self.maxFitness = 0
  self.neat = Neat:new(0,8+8,4)
end

function printTable(table)
  for _,value in pairs(table) do
    if value then
      io.write("T, ")
    else
      io.write("F, ")
    end
  end
  print(" ")
end


function Player:update(board) 
  
  self.rounds = self.rounds + 1
  
  local inputs = {}
  --[[for i=1, Board.static.size do
    for j=1, Board.static.size do
      inputs[#inputs + 1] = board.cells[i][j]
    end
  end]]
  
  for i=1,8 do
    if i == self.x then
      inputs[i] = 2
    else 
      inputs[i] = 0
    end
  end
  
  for i=9,16 do
    if i-8 == self.y then
      inputs[i] = 2
    else 
      inputs[i] = 0
    end
  end
  
  local outputs = self.neat:evaluateCurrent(inputs)
  --io.write("outputs: ")
  --printTable(outputs)
  
  local lastX, lastY = self.x, self.y
  
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

  if(self.x > Board.static.size) then 
    self.x = lastX
  elseif(self.x < 1) then 
    self.x = lastX
  end

  if(self.y > Board.static.size) then 
    self.y = lastY
  elseif(self.y < 1) then 
    self.y = lastY
  end
  
  local currentCell = board.cells[self.x][self.y]
  
  if (self.x == lastX and self.y == lastY) then
    self.timeoutStuck = self.timeoutStuck - 1
    if self.timeoutStuck < 1 then
      self:endRun(currentCell)
    end
  else
    self.timeoutStuck = Player.static.timeoutStuckConstant
  end
  
  
  
  local fit = self:getFitness()
  
  if fit > self.maxFitness then
    self.maxFitness = fit
  end
  
  
  if fit <= self.maxFitness then
    self.timeoutRepeat = self.timeoutRepeat - 1
    if self.timeoutRepeat < 1 then
      self:endRun(currentCell)
    end
  else
    self.timeoutRepeat = Player.static.timeoutRepeatConstant
  end
  
  if currentCell ~= Board.static.air_cell then
    self:endRun(currentCell)
  end 
end

function Player:draw()
  draw_square(self.x, self.y,Board.static.player_cell)
end

function Player:endRun(cellValue)
  local fitness = self:getFitness()
  fitness = fitness/self.rounds
  --if cellValue == Board.static.death_cell then
    --fitness = fitness/3
  if cellValue == Board.static.goal_cell then
    fitness = fitness*2
  end
  self.neat:endRun(fitness)
  
  self.x, self.y = self.start.x, self.start.y
  self.timeoutStuck = Player.static.timeoutStuckConstant
  self.timeoutRepeat = Player.static.timeoutRepeatConstant
  self.maxFitness = 0
  self.rounds = 0
end


function Player:getFitness()
  local distance = BFS(self.x,self.y,board) --math.abs(self.y - 1) + math.abs(self.x - 1)
  --local distance = getDistanceToDestiny()
  if(distance == 0) then distance = 0.001 end --evitem dividir entre 0
  return (1/distance)
end

