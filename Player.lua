local class = require 'middleclass'
require 'Neat'
require 'bfs'

Player = class('Player') 

Player.static.timeoutStuckConstant = 5
Player.static.timeoutRepeatConstant = 50

function Player:initialize(x, y, color)
  self.id = -1
  self.x = x or 1
  self.y = y or 1
  self.start = {}
  self.start.x, self.start.y = self.x, self.y
  self.timeoutStuck = Player.static.timeoutStuckConstant
  self.timeoutRepeat = Player.static.timeoutRepeatConstant
  self.rounds = 0
  self.maxFitness = 0
  self.neat = Neat:new(0,8+8,4)
  self.color = color or "ffffff"
  self.alive = true
end


function Player:update(board, input) 
  
  self.rounds = self.rounds + 1
  
  local outputs = self.neat:evaluateCurrent(input)

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
      self:endRun(currentCell, board)
    end
  else
    self.timeoutStuck = Player.static.timeoutStuckConstant
  end
  
  
  
  local fit = self:getFitness(board)
  
  if fit > self.maxFitness then
    self.maxFitness = fit
  end
  
  
  
  
  if currentCell ~= Board.static.air_cell then
    self:endRun(currentCell, board)
  end 
end

function Player:draw()
  draw_square(self.x, self.y,self.color)
end

function Player:endRun(cellValue, board)
  local fitness = self:getFitness(board)
  --fitness = fitness/self.rounds
  if cellValue == Board.static.death_cell then
    fitness = fitness/3
  elseif cellValue == Board.static.goal_cell then
    fitness = fitness+100-self.rounds
    print("Reached, fitness: " .. fitness)
  end
  self.neat:endRun(fitness)
  
  self.x, self.y = self.start.x, self.start.y
  self.timeoutStuck = Player.static.timeoutStuckConstant
  self.timeoutRepeat = Player.static.timeoutRepeatConstant
  self.maxFitness = 0
  self.rounds = 0
end

