require 'Board'
require 'Player'
require 'bfs'
require 'Utils'
require 'CoolGame'

local class = require 'middleclass'
local game 

function love.load()
  local board = Board:new()
  board.cells[1][1] = Board.static.goal_cell
  
  
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
  board.cells[7][2] = Board.static.death_cell
  
  local player = Player:new(8,7, "aa00ff")
  
  local players = {player}
  
  game = CoolGame:new(players, board, 16)
  
  frame = 0
  maxFitness = 0
end


function love.update(dt)
 game:update()
  --[[if frame%1 == 0 then
  player:update(board)
  --end
  if player:getFitness() > maxFitness then maxFitness = player:getFitness() end
  frame = frame + 1]]
end

-- Draw a coloured rectangle.
function love.draw()
  game:draw()
  --[[board:draw()
  player:draw()
  love.graphics.printf("Rounds: " .. player.rounds, Board.static.fullSize, 0, 500, "left")
  love.graphics.printf("Stuck: " .. player.timeoutStuck, Board.static.fullSize, 20, 500, "left")
  love.graphics.printf("Repeat: " .. player.timeoutRepeat, Board.static.fullSize, 40, 500, "left")
  love.graphics.printf("Fitness: " .. player:getFitness(), Board.static.fullSize, 60, 500, "left")
  love.graphics.printf("MaxFitness: " .. maxFitness .. " (" .. player.maxFitness .. ")", Board.static.fullSize, 80, 500, "left")]]
end

