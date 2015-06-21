local class = require 'middleclass'
require 'Utils'

Core = class('Core')

function Core:initialize(players, board, nInputs)
  self.board = board
  self.players = {}
  self.playerIDs = {}
  local id = 1
  for _,player in ipairs(players) do
    player.id = #self.players+1
    self.players[#self.players+1] = player
    table.insert(self.playerIDs,player.id)
  end
  self.nInputs = nInputs or 0
end

function Core:getInput(playerID)
  local input = self:_getInput(playerID)
  if #input ~= self.nInputs then
    print("Core:_getInput(playerID) returns wrong number of inputs")
    return nil
  end
  return input
end

function Core:getFitness(playerID)
  return 0
end


function Core:update()
  local order = arrayCopy(self.playerIDs)
  order = scrambleArray(order)
  
  for _,id in ipairs(order) do
    local input = self:getInput(id)
    self.players[id]:update(self.board, input)
  end
end


function Core:draw()
  self.board:draw()
  for _,player in pairs(self.players) do
    player:draw()
  end
end

function Core:endRun(id)
  
    
end

  
  