require 'Board'
require 'Player'
class = require 'middleclass'


function love.load()
  board = Board:new()
  board.cells[3][5] = Board.static.player_cell
  board.cells[4][5] = Board.static.death_cell
  board.cells[1][1] = Board.static.goal_cell
  player = Player:new()

end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  player:update(board)
end


-- Draw a coloured rectangle.
function love.draw()
  board:draw()
end

