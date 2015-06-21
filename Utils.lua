function scrambleArray(array)
  math.randomseed(os.time())

  for k=1,math.random(15,35) do
    local i,j = math.random(1,#array), math.random(1,#array)
    table.swap(array,i,j)
  end
  return array
end


function table.swap(t,i,j)
  t[i],t[j] = t[j],t[i]
end

function arrayCopy(t)
  local t2 = {}
  for k,v in ipairs(t) do
    t2[k] = v
  end
  return t2
end

function ink(hex)
   --convert hexadecimal (accepts 6 or 8 characters)
   local function convertHex(hex)
      local splitToRGB = {}
      
      if # hex < 6 then hex = hex .. string.rep("F", 6 - # hex) end --flesh out bad hexes
      
      for x = 1, # hex - 1, 2 do
          table.insert(splitToRGB, tonumber(hex:sub(x, x + 1), 16)) --convert hexes to dec
          if splitToRGB[# splitToRGB] < 0 then slpitToRGB[# splitToRGB] = 0 end --prevents negative values
      end
      return unpack(splitToRGB)
   end
   --predefined colours ("" works for white for convenience)
   if hex == "red" then
      hex = "FF3333FF"
   elseif hex == "green" then
      hex = "33FF33FF"
   elseif hex == "blue" then
      hex = "3333FFFF"
   elseif hex == "white" or hex == "" then
      hex = "FFFFFFFF"
   elseif hex == "black" then
      hex = "333333FF"
   end
   
   love.graphics.setColor(convertHex(hex)) 
end

function draw_square(row,col,color)
  ink(color)
  --[[if (val == Board.static.death_cell) then love.graphics.setColor(255,50,50)
  elseif (val == Board.static.air_cell) then love.graphics.setColor(60,60,60)
  elseif (val == Board.static.player_cell) then love.graphics.setColor(50,255,50)
  else love.graphics.setColor(50,50,255)
  end]]
  

  love.graphics.rectangle("fill",(col-1)*Board.static.cellSize, 
    (row-1)*Board.static.cellSize, Board.static.cellSize, Board.static.cellSize)
end
