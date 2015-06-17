require 'NEAT'

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  x, y, w, h = 20, 20, 60, 20;
  main()
end
 
-- Increase the size of the rectangle every frame.
function love.update(dt)
  w = w + 1;
  h = h + 1;
  print(h);
end
 
-- Draw a coloured rectangle.
function love.draw()
  love.graphics.setColor(0, 100, 100);
  love.graphics.rectangle('fill', x, y, w, h);
end

