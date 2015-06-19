local class = require 'middleclass'
Board = class("Board")

Board.static.death_cell = -1
Board.static.air_cell = 0 
Board.static.player_cell = 1 
Board.static.goal_cell = 2 

Board.static.cellSize = 40
Board.static.size = 8

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
  
  local function draw_square(row,col,val)
    if (val == Board.static.death_cell) then love.graphics.setColor(255,0,0)
    elseif (val == Board.static.air_cell) then love.graphics.setColor(60,60,60)
    elseif (val == Board.static.player_cell) then love.graphics.setColor(50,255,50)
    else love.graphics.setColor(50,0,100)
    end

    love.graphics.rectangle("fill",(col-1)*Board.static.cellSize, (row-1)*Board.static.cellSize, Board.static.cellSize, Board.static.cellSize)
  end

  for i=1,Board.static.size do
    for j=1,Board.static.size do
      draw_square(i,j,self.cells[i][j])
    end
  end
end
