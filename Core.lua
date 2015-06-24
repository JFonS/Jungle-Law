local class = require 'middleclass'
require 'Utils'

Core = class('Core')

function Core:initialize(players, board, nInputs)
  self.board = board
  self.players = {}
  self.playerIDs = {}
  local id = 1
  for _,player in ipairs(players) do
    player:setID(#self.players+1)
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

function Core:updatePlayer(id)

end

function Core:update()
  local order = arrayCopy(self.playerIDs)
  order = scrambleArray(order)

  local stillAlive = false
  for _,id in ipairs(order) do
    if self.players[id].alive then
      stillAlive = true
      self:updatePlayer(id)
      if not self.players[id].alive then
        self.players[id].fitness = self:getFitness(id)
      end
    end
  end

  if not stillAlive then
    self:endRun()
  end
end




function Core:draw()
  self.board:draw()
  for _,player in pairs(self.players) do
    player:draw()
  end
end

function Core:endRun(id)
  print("REKT")
  for _,id in ipairs(self.playerIDs) do
    self.players[id]:endRun()
  end

  for _,id in ipairs(self.playerIDs) do
    self.players[id]:revive()
  end
end


