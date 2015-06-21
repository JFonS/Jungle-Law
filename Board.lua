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
  local color = "fffffff"
  for i=1,Board.static.size do
    for j=1,Board.static.size do
      if (self.cells[i][j] == Board.static.death_cell) then color = "red"
      elseif (self.cells[i][j] == Board.static.air_cell) then color = "303030"
      elseif (self.cells[i][j] == Board.static.goal_cell) then color = "3030ff"
      end
      draw_square(i,j,color)
    end
  end
end
