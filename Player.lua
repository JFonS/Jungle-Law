local class = require 'middleclass'
require 'Neat'
require 'bfs'

Player = class('Player') 

Player.static.timeoutStuckConstant = 5
Player.static.timeoutRepeatConstant = 50

function Player:initialize(x, y, nInputs, nOutputs, color)
  self.id = -1
  self.x = x or 1
  self.y = y or 1
  self.start = {}
  self.start.x, self.start.y = self.x, self.y

  self.color = color or "ffffff"
  
  self.neat = Neat:new(self.id,nInputs, nOutputs)
  self:revive()
end

function Player:revive()
  self.alive = true
  self.deathCause = nil
  self.rounds = 0
  self.x, self.y = self.start.x,self.start.y--math.random(1,Board.static.size), math.random(1,Board.static.size)
  self.timeoutStuck = Player.static.timeoutStuckConstant
  self.timeoutRepeat = Player.static.timeoutRepeatConstant
  self.maxFitness = 0
end

function Player:update(input) 

  self.rounds = self.rounds + 1

  return self.neat:evaluateCurrent(input)
end

function Player:draw()
  draw_square(self.x, self.y,self.color)
end

function Player:endRun()

  self.neat:endRun(self.fitness)


end

function Player:setID(id)
  self.id = id
  self.neat:setID(id)
end

