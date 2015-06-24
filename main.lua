require 'Board'
require 'Player'
require 'bfs'
require 'Utils'
require 'CoolGame'

local class = require 'middleclass'
local game 

function love.load()
  local board = Board:new()
  
  --[[board.cells[1][1] = Board.static.goal_cell
  
  
  board.cells[8][5] = Board.static.death_cell
  board.cells[7][5] = Board.static.death_cell
  board.cells[6][5] = Board.static.death_cell
  board.cells[5][5] = Board.static.death_cell
  board.cells[4][5] = Board.static.death_cell
  board.cells[3][5] = Board.static.death_cell
  
  board.cells[1][2] = Board.static.death_cell
  board.cells[2][2] = Board.static.death_cell
  board.cells[3][2] = Board.static.death_cell
  board.cells[4][2] = Board.static.death_cell
  board.cells[5][2] = Board.static.death_cell
  board.cells[6][2] = Board.static.death_cell
  board.cells[7][2] = Board.static.death_cell]]
  
  local inputSize = 7*7
  
  local player = Player:new(1,1, inputSize, 4, "aa00ff")
  local player2 = Player:new(12,12, inputSize, 4, "33ff33")
  
  local players = {player, player2}
  
  game = CoolGame:new(players, board, inputSize)
  frame = 0
end


function love.update(dt)
 --if frame%30 == 0 then game:update() end
 game:update()
 frame = frame + 1
end

-- Draw a coloured rectangle.
function love.draw()
  game:draw()
end

