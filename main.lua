require 'Board'
require 'Player'
require 'bfs'

class = require 'middleclass'


function love.load()
  board = Board:new()
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


  for i=1,8 do
    for j=1,8 do
      io.write(BFS(i,j,board) .. " ")
    end
    print(" ")
  end
  player = Player:new(8,7)
  frame = 0
  maxFitness = 0
end


function love.update(dt)
 
  --if frame%1 == 0 then
  player:update(board)
  --end
  if player:getFitness() > maxFitness then maxFitness = player:getFitness() end
  frame = frame + 1
end


function draw_square(row,col,val)
  if (val == Board.static.death_cell) then love.graphics.setColor(255,50,50)
  elseif (val == Board.static.air_cell) then love.graphics.setColor(60,60,60)
  elseif (val == Board.static.player_cell) then love.graphics.setColor(50,255,50)
  else love.graphics.setColor(50,50,255)
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

