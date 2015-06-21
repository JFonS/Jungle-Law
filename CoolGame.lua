local class = require 'middleclass'
require  'Core'

CoolGame = class('CoolGame',Core)

function CoolGame:_getInput(id)
  local input = {}

  for i=1,8 do
    if i == self.players[id].x then
      input[i] = 2
    else 
      input[i] = 0
    end
  end

  for i=9,16 do
    if i-8 == self.players[id].y then
      input[i] = 2
    else 
      input[i] = 0
    end
  end
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
