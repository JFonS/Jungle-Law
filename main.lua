require 'Board'
require 'Player'
class = require 'middleclass'


function love.load()
  board = Board:new()
  board.cells[1][1] = Board.static.goal_cell
  board.cells[2][1] = Board.static.death_cell
  board.cells[1][2] = Board.static.death_cell
  board.cells[5][5] = Board.static.death_cell

  player = Player:new(8,8)
  frame = 0
  maxFitness = 0
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  if frame%1 == 0 then
  player:update(board)
end
  if player:getFitness() > maxFitness then maxFitness = player:getFitness() end
  frame = frame + 1
end


function draw_square(row,col,val)
  if (val == Board.static.death_cell) then love.graphics.setColor(255,0,0)
  elseif (val == Board.static.air_cell) then love.graphics.setColor(60,60,60)
  elseif (val == Board.static.player_cell) then love.graphics.setColor(50,255,50)
  else love.graphics.setColor(50,0,100)
  end
  

  love.graphics.rectangle("fill",(col-1)*Board.static.cellSize, 
    (row-1)*Board.static.cellSize, Board.static.cellSize, Board.static.cellSize)
end


-- Draw a coloured rectangle.
function love.draw()
  board:draw()
  player:draw()
  love.graphics.printf("Rounds: " .. player.rounds, Board.static.fullSize, 0, 500, "left")
  love.graphics.printf("Stuck: " .. player.timeoutStuck, Board.static.fullSize, 20, 500, "left")
  love.graphics.printf("Repeat: " .. player.timeoutRepeat, Board.static.fullSize, 40, 500, "left")
  love.graphics.printf("Fitness: " .. player:getFitness(), Board.static.fullSize, 60, 500, "left")
  love.graphics.printf("MaxFitness: " .. maxFitness .. " (" .. player.maxFitness .. ")", Board.static.fullSize, 80, 500, "left")
end

