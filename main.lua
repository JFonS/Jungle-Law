require 'NEAT'

local tileSize = 40
local boardSize = BOARD_SIZE * tileSize
local outputTexts = {"U","R","D","L"}

function love.load()

  CreateBoard()
  writeFile("temp.pool")

end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  local species = pool.species[pool.currentSpecies]
  local genome = species.genomes[pool.currentGenome]

  timeout = timeout - 1
  rounds = rounds + 1
  if(lastPlayerRow ~= playerRow or lastPlayerCol ~= playerCol) then
    timeout = TimeoutConstant
  end
  lastPlayerRow = playerRow
  lastPlayerCol = playerCol

  --printBoard()

  local currentTile = evaluateCurrent()
  if(currentTile == 2 or currentTile == -1 or timeout <= 0 or rounds >= MaxRounds) then

    local fitness = getFitness() -- TODO calcular fitness
    if(currentTile == 2) then 
      fitness = fitness + 1000
    end

    if(currentTile == -1 or timeout <= 0) then 
      fitness = fitness / 10 * rounds
    end

    print("********* FINISHED ***********");
    if(currentTile == 2) then print("Arrived ? YES") else print("Arrived ? NO") end
    print("Finished in " .. rounds .. " rounds.");
    print("******************************")

    timeout = TimeoutConstant
    rounds = 0


    genome.fitness = fitness

    if fitness > pool.maxFitness then
      pool.maxFitness = fitness
      writeFile("backup." .. pool.generation .. "." .. saveLoadFile)
    end

    print("Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " fitness: " .. fitness)
    pool.currentSpecies = 1
    pool.currentGenome = 1
    while fitnessAlreadyMeasured() do
      nextGenome()
    end
    initializeRun()
  end
end

local measured = 0
local total = 0
for _,species in pairs(pool.species) do
  for _,genome in pairs(species.genomes) do
    total = total + 1
    if genome.fitness ~= 0 then
      measured = measured + 1
    end
  end
end


function draw_square(row,col,val)
  if (val == -1) then love.graphics.setColor(255,0,0)
  elseif (val == 0) then love.graphics.setColor(100,100,100)
  elseif (val == 1) then love.graphics.setColor(0,100,50)
  else love.graphics.setColor(50,0,100)
  end

  love.graphics.rectangle("fill",boardSize - row*tileSize,boardSize-col*tileSize,tileSize,tileSize)
end


-- Draw a coloured rectangle.
function love.draw()
  for i=1,BOARD_SIZE do
    for j=1,BOARD_SIZE do
      draw_square(i,j,Board[i][j])
    end
    print(" ")
  end
  love.graphics.setColor(255,255,255)
  for i=1,#currentOutputs do
    if currentOutputs[i] then
      love.graphics.printf(outputTexts[i],tileSize*i, boardSize, tileSize,"center")
      end
  end
  
end

