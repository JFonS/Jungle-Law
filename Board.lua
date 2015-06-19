local class = require 'middleclass'
Board = class("Board")

Board.static.death_cell = -1
Board.static.air_cell = 0 
Board.static.player_cell = 1 
Board.static.goal_cell = 2 

Board.static.cellSize = 40
Board.static.size = 8
Board.static.fullSize = Board.static.cellSize * Board.static.size

function Board:initialize()
  local cells = {}
  for i=1,Board.static.size do
    cells[i] = {}
    for j=1,Board.static.size do
      cells[i][j] = Board.static.air_cell
    end
  end
  self.cells = cells
end



function Board:draw()
  for i=1,Board.static.size do
    for j=1,Board.static.size do
      draw_square(i,j,self.cells[i][j])
    end
  end
end
