-- MarI/O by SethBling
-- Feel free to use this code, but please do not redistribute it.
-- Intended for use with the BizHawk emulator and Super Mario World or Super Mario Bros. ROM.
-- For SMW, make sure you have a save state named "DP1.state" at the beginning of a level,
-- and put a copy in both the Lua folder and the root directory of BizHawk.
local class = require 'middleclass'

Neat = class('Neat')


Neat.static.population = 300
Neat.static.deltaDisjoint = 2.0
Neat.static.deltaWeights = 0.4
Neat.static.deltaThreshold = 1.0

Neat.static.staleSpecies = 15

Neat.static.mutateConnectionsChance = 0.25
Neat.static.perturbChance = 0.90
Neat.static.crossoverChance = 0.75
Neat.static.linkMutationChance = 2.0
Neat.static.nodeMutationChance = 0.50
Neat.static.biasMutationChance = 0.40
Neat.static.stepSize = 0.1
Neat.static.disableMutationChance = 0.4
Neat.static.enableMutationChance = 0.2

Neat.static.maxNodes = 1000000

function Neat:initialize(id, inputSize, outputSize)
  self.id = id
  self.saveLoadFile = self.id

  self.inputSize = inputSize+1
  self.outputSize = outputSize

  if pool == nil then
    self:_initializePool()
  end
end



function Neat:_sigmoid(x)
  return 2/(1+math.exp(-4.9*x))-1
end

function Neat:_newInnovation()
  self.pool.innovation = self.pool.innovation + 1
  return self.pool.innovation
end

function Neat:_newPool()
  local pool = {}
  pool.species = {}
  pool.generation = 0
  pool.innovation = self.outputSize
  pool.currentSpecies = 1
  pool.currentGenome = 1
  pool.currentFrame = 0
  pool.maxFitness = 0

  return pool
end

function Neat:_newSpecies()
  local species = {}
  species.topFitness = 0
  species.staleness = 0
  species.genomes = {}
  species.averageFitness = 0

  return species
end

function Neat:_newGenome()
  local genome = {}
  genome.genes = {}
  genome.fitness = 0
  genome.adjustedFitness = 0
  genome.network = {}
  genome.maxneuron = 0
  genome.globalRank = 0
  genome.mutationRates = {}
  genome.mutationRates["connections"] = Neat.static.mutateConnectionsChance
  genome.mutationRates["link"] = Neat.static.linkMutationChance
  genome.mutationRates["bias"] = Neat.static.biasMutationChance
  genome.mutationRates["node"] = Neat.static.nodeMutationChance
  genome.mutationRates["enable"] = Neat.static.enableMutationChance
  genome.mutationRates["disable"] = Neat.static.disableMutationChance
  genome.mutationRates["step"] = Neat.static.stepSize

  return genome
end

function Neat:_copyGenome(genome)
  local genome2 = self:_newGenome()
  for g=1,#genome.genes do
    table.insert(genome2.genes, self:_copyGene(genome.genes[g]))
  end
  genome2.maxneuron = genome.maxneuron
  genome2.mutationRates["connections"] = genome.mutationRates["connections"]
  genome2.mutationRates["link"] = genome.mutationRates["link"]
  genome2.mutationRates["bias"] = genome.mutationRates["bias"]
  genome2.mutationRates["node"] = genome.mutationRates["node"]
  genome2.mutationRates["enable"] = genome.mutationRates["enable"]
  genome2.mutationRates["disable"] = genome.mutationRates["disable"]

  return genome2
end

function Neat:_basicGenome()
  local genome = self:_newGenome()
  local innovation = 1

  genome.maxneuron = self.inputSize
  self:_mutate(genome)

  return genome
end

function Neat:_newGene()
  local gene = {}
  gene.into = 0
  gene.out = 0
  gene.weight = 0.0
  gene.enabled = true
  gene.innovation = 0

  return gene
end

function Neat:_copyGene(gene)
  local gene2 = self:_newGene()
  gene2.into = gene.into
  gene2.out = gene.out
  gene2.weight = gene.weight
  gene2.enabled = gene.enabled
  gene2.innovation = gene.innovation

  return gene2
end

function Neat:_newNeuron()
  local neuron = {}
  neuron.incoming = {}
  neuron.value = 0.0

  return neuron
end

function Neat:_generateNetwork(genome)
  local network = {}
  network.neurons = {}

  for i=1,self.inputSize do
    network.neurons[i] = self:_newNeuron()
  end

  for o=1,self.outputSize do
    network.neurons[Neat.static.maxNodes+o] = self:_newNeuron()
  end

  table.sort(genome.genes, function (a,b)
      return (a.out < b.out)
    end)
  for i=1,#genome.genes do
    local gene = genome.genes[i]
    if gene.enabled then
      if network.neurons[gene.out] == nil then
        network.neurons[gene.out] = self:_newNeuron()
      end
      local neuron = network.neurons[gene.out]
      table.insert(neuron.incoming, gene)
      if network.neurons[gene.into] == nil then
        network.neurons[gene.into] = self:_newNeuron()
      end
    end
  end

  genome.network = network
end

function Neat:_evaluateNetwork(network,inputs)
  table.insert(inputs, 1)
  if #inputs ~= self.inputSize then
    print("Incorrect number of neural network inputs.")
    return {}
  end

  for i=1,self.inputSize do
    network.neurons[i].value = inputs[i]
  end

  for _,neuron in pairs(network.neurons) do
    local sum = 0
    for j = 1,#neuron.incoming do
      local incoming = neuron.incoming[j]
      local other = network.neurons[incoming.into]
      sum = sum + incoming.weight * other.value
    end

    if #neuron.incoming > 0 then
      neuron.value = self:_sigmoid(sum)
    end
  end

  local outputs = {}
  for o=1,self.outputSize do
    if network.neurons[Neat.static.maxNodes+o].value > 0 then
      outputs[o] = true
    else
      outputs[o] = false
    end
  end

  return outputs
end

function Neat:_crossover(g1, g2)
  -- Make sure g1 is the higher fitness genome
  if g2.fitness > g1.fitness then
    tempg = g1
    g1 = g2
    g2 = tempg
  end

  local child = self:_newGenome()

  local innovations2 = {}
  for i=1,#g2.genes do
    local gene = g2.genes[i]
    innovations2[gene.innovation] = gene
  end

  for i=1,#g1.genes do
    local gene1 = g1.genes[i]
    local gene2 = innovations2[gene1.innovation]
    if gene2 ~= nil and math.random(2) == 1 and gene2.enabled then
      table.insert(child.genes, self:_copyGene(gene2))
    else
      table.insert(child.genes, self:_copyGene(gene1))
    end
  end

  child.maxneuron = math.max(g1.maxneuron,g2.maxneuron)

  for mutation,rate in pairs(g1.mutationRates) do
    child.mutationRates[mutation] = rate
  end

  return child
end

function Neat:_randomNeuron(genes, nonInput)
  local neurons = {}
  if not nonInput then
    for i=1,self.inputSize do
      neurons[i] = true
    end
  end
  for o=1,self.outputSize do
    neurons[Neat.static.maxNodes+o] = true
  end
  for i=1,#genes do
    if (not nonInput) or genes[i].into > self.inputSize then
      neurons[genes[i].into] = true
    end
    if (not nonInput) or genes[i].out > self.inputSize then
      neurons[genes[i].out] = true
    end
  end

  local count = 0
  for _,_ in pairs(neurons) do
    count = count + 1
  end
  local n = math.random(1, count)

  for k,v in pairs(neurons) do
    n = n-1
    if n == 0 then
      return k
    end
  end

  return 0
end

function Neat:_containsLink(genes, link)
  for i=1,#genes do
    local gene = genes[i]
    if gene.into == link.into and gene.out == link.out then
      return true
    end
  end
end

function Neat:_pointMutate(genome)
  local step = genome.mutationRates["step"]

  for i=1,#genome.genes do
    local gene = genome.genes[i]
    if math.random() < Neat.static.perturbChance then
      gene.weight = gene.weight + math.random() * step*2 - step
    else
      gene.weight = math.random()*4-2
    end
  end
end

function Neat:_linkMutate(genome, forceBias)
  local neuron1 = self:_randomNeuron(genome.genes, false)
  local neuron2 = self:_randomNeuron(genome.genes, true)

  local newLink = self:_newGene()
  if neuron1 <= self.inputSize and neuron2 <= self.inputSize then
    --Both input nodes
    return
  end
  if neuron2 <= self.inputSize then
    -- Swap output and input
    local temp = neuron1
    neuron1 = neuron2
    neuron2 = temp
  end

  newLink.into = neuron1
  newLink.out = neuron2
  if forceBias then
    newLink.into = self.inputSize
  end

  if self:_containsLink(genome.genes, newLink) then
    return
  end
  newLink.innovation = self:_newInnovation()
  newLink.weight = math.random()*4-2

  table.insert(genome.genes, newLink)
end

function Neat:_nodeMutate(genome)
  if #genome.genes == 0 then
    return
  end

  genome.maxneuron = genome.maxneuron + 1

  local gene = genome.genes[math.random(1,#genome.genes)]
  if not gene.enabled then
    return
  end
  gene.enabled = false

  local gene1 = self:_copyGene(gene)
  gene1.out = genome.maxneuron
  gene1.weight = 1.0
  gene1.innovation = self:_newInnovation()
  gene1.enabled = true
  table.insert(genome.genes, gene1)

  local gene2 = self:_copyGene(gene)
  gene2.into = genome.maxneuron
  gene2.innovation = self:_newInnovation()
  gene2.enabled = true
  table.insert(genome.genes, gene2)
end

function Neat:_enableDisableMutate(genome, enable)
  local candidates = {}
  for _,gene in pairs(genome.genes) do
    if gene.enabled == not enable then
      table.insert(candidates, gene)
    end
  end

  if #candidates == 0 then
    return
  end

  local gene = candidates[math.random(1,#candidates)]
  gene.enabled = not gene.enabled
end

function Neat:_mutate(genome)
  for mutation,rate in pairs(genome.mutationRates) do
    if math.random(1,2) == 1 then
      genome.mutationRates[mutation] = 0.95*rate
    else
      genome.mutationRates[mutation] = 1.05263*rate
    end
  end

  if math.random() < genome.mutationRates["connections"] then
    self:_pointMutate(genome)
  end

  local p = genome.mutationRates["link"]
  while p > 0 do
    if math.random() < p then
      self:_linkMutate(genome, false)
    end
    p = p - 1
  end

  p = genome.mutationRates["bias"]
  while p > 0 do
    if math.random() < p then
      self:_linkMutate(genome, true)
    end
    p = p - 1
  end

  p = genome.mutationRates["node"]
  while p > 0 do
    if math.random() < p then
      self:_nodeMutate(genome)
    end
    p = p - 1
  end

  p = genome.mutationRates["enable"]
  while p > 0 do
    if math.random() < p then
      self:_enableDisableMutate(genome, true)
    end
    p = p - 1
  end

  p = genome.mutationRates["disable"]
  while p > 0 do
    if math.random() < p then
      self:_enableDisableMutate(genome, false)
    end
    p = p - 1
  end
end

function Neat:_disjoint(genes1, genes2)
  local i1 = {}
  for i = 1,#genes1 do
    local gene = genes1[i]
    i1[gene.innovation] = true
  end

  local i2 = {}
  for i = 1,#genes2 do
    local gene = genes2[i]
    i2[gene.innovation] = true
  end

  local disjointGenes = 0
  for i = 1,#genes1 do
    local gene = genes1[i]
    if not i2[gene.innovation] then
      disjointGenes = disjointGenes+1
    end
  end

  for i = 1,#genes2 do
    local gene = genes2[i]
    if not i1[gene.innovation] then
      disjointGenes = disjointGenes+1
    end
  end

  local n = math.max(#genes1, #genes2)

  return disjointGenes / n
end

function Neat:_weights(genes1, genes2)
  local i2 = {}
  for i = 1,#genes2 do
    local gene = genes2[i]
    i2[gene.innovation] = gene
  end

  local sum = 0
  local coincident = 0
  for i = 1,#genes1 do
    local gene = genes1[i]
    if i2[gene.innovation] ~= nil then
      local gene2 = i2[gene.innovation]
      sum = sum + math.abs(gene.weight - gene2.weight)
      coincident = coincident + 1
    end
  end

  return sum / coincident
end

function Neat:_sameSpecies(genome1, genome2)
  local dd = Neat.static.deltaDisjoint *self:_disjoint(genome1.genes, genome2.genes)
  local dw = Neat.static.deltaWeights*self:_weights(genome1.genes, genome2.genes) 
  return dd + dw < Neat.static.deltaThreshold
end

function Neat:_rankGlobally()
  local global = {}
  for s = 1,#self.pool.species do
    local species = self.pool.species[s]
    for g = 1,#species.genomes do
      table.insert(global, species.genomes[g])
    end
  end
  table.sort(global, function (a,b)
      return (a.fitness < b.fitness)
    end)

  for g=1,#global do
    global[g].globalRank = g
  end
end

function Neat:_calculateAverageFitness(species)
  local total = 0

  for g=1,#species.genomes do
    local genome = species.genomes[g]
    total = total + genome.globalRank
  end

  species.averageFitness = total / #species.genomes
end

function Neat:_totalAverageFitness()
  local total = 0
  for s = 1,#self.pool.species do
    local species = self.pool.species[s]
    total = total + species.averageFitness
  end

  return total
end

function Neat:_cullSpecies(cutToOne)
  for s = 1,#self.pool.species do
    local species = self.pool.species[s]

    table.sort(species.genomes, function (a,b)
        return (a.fitness > b.fitness)
      end)

    local remaining = math.ceil(#species.genomes/2)
    if cutToOne then
      remaining = 1
    end
    while #species.genomes > remaining do
      table.remove(species.genomes)
    end
  end
end

function Neat:_breedChild(species)
  local child = {}
  if math.random() < Neat.static.crossoverChance then
    g1 = species.genomes[math.random(1, #species.genomes)]
    g2 = species.genomes[math.random(1, #species.genomes)]
    child = self:_crossover(g1, g2)
  else
    g = species.genomes[math.random(1, #species.genomes)]
    child = self:_copyGenome(g)
  end

  self:_mutate(child)

  return child
end

function Neat:_removeStaleSpecies()
  local survived = {}

  for s = 1,#self.pool.species do
    local species = self.pool.species[s]

    table.sort(species.genomes, function (a,b)
        return (a.fitness > b.fitness)
      end)

    if species.genomes[1].fitness > species.topFitness then
      species.topFitness = species.genomes[1].fitness
      species.staleness = 0
    else
      species.staleness = species.staleness + 1
    end
    if species.staleness < Neat.static.staleSpecies or species.topFitness >= self.pool.maxFitness then
      table.insert(survived, species)
    end
  end

  self.pool.species = survived
end

function Neat:_removeWeakSpecies()
  local survived = {}

  local sum = self:_totalAverageFitness()
  for s = 1,#self.pool.species do
    local species = self.pool.species[s]
    breed = math.floor(species.averageFitness / sum * Neat.static.population)
    if breed >= 1 then
      table.insert(survived, species)
    end
  end

  self.pool.species = survived
end


function Neat:_addToSpecies(child)
  local foundSpecies = false
  for s=1,#self.pool.species do
    local species = self.pool.species[s]
    if not foundSpecies and self:_sameSpecies(child, species.genomes[1]) then
      table.insert(species.genomes, child)
      foundSpecies = true
    end
  end

  if not foundSpecies then
    local childSpecies = self:_newSpecies()
    table.insert(childSpecies.genomes, child)
    table.insert(self.pool.species, childSpecies)
  end
end

function Neat:_newGeneration()
  self:_cullSpecies(false) -- Cull the bottom half of each species
  self:_rankGlobally()
  self:_removeStaleSpecies()
  self:_rankGlobally()
  for s = 1,#self.pool.species do
    local species = self.pool.species[s]
    self:_calculateAverageFitness(species)
  end
  self:_removeWeakSpecies()
  local sum = self:_totalAverageFitness()
  local children = {}
  for s = 1,#self.pool.species do
    local species = self.pool.species[s]
    breed = math.floor(species.averageFitness / sum * Neat.static.population) - 1
    for i=1,breed do
      table.insert(children, self:_breedChild(species))
    end
  end
  self:_cullSpecies(true) -- Cull all but the top member of each species
  while #children + #self.pool.species < Neat.static.population do
    local species = self.pool.species[math.random(1, #self.pool.species)]
    table.insert(children, self:_breedChild(species))
  end
  for c=1,#children do
    local child = children[c]
    self:_addToSpecies(child)
  end

  self.pool.generation = self.pool.generation + 1

  self:_writeFile("backup." .. self.pool.generation .. "." .. self.saveLoadFile)
end

function Neat:_initializePool()
  self.pool = self:_newPool()

  for i=1,Neat.static.population do
    local basic = self:_basicGenome()
    self:_addToSpecies(basic)
  end

  self:_initializeRun()
end

function Neat:_initializeRun()


  local species = self.pool.species[self.pool.currentSpecies]
  local genome = species.genomes[self.pool.currentGenome]
  self:_generateNetwork(genome)
  --self:evaluateCurrent()
end

function Neat:evaluateCurrent(inputs)
  local species = self.pool.species[self.pool.currentSpecies]
  local genome = species.genomes[self.pool.currentGenome]

  return self:_evaluateNetwork(genome.network, inputs)
end

function Neat:_nextGenome()
  self.pool.currentGenome = self.pool.currentGenome + 1
  if self.pool.currentGenome > #self.pool.species[self.pool.currentSpecies].genomes then
    self.pool.currentGenome = 1
    self.pool.currentSpecies = self.pool.currentSpecies+1
    if self.pool.currentSpecies > #self.pool.species then
      self:_newGeneration()
      self.pool.currentSpecies = 1
    end
  end
end

function Neat:_fitnessAlreadyMeasured()
  local species = self.pool.species[self.pool.currentSpecies]
  local genome = species.genomes[self.pool.currentGenome]

  return genome.fitness ~= 0
end

function Neat:_writeFile(filename)
  local dir = "backups/" .. self.id .. "/"
  os.execute("mkdir -p ".. dir)
  print(dir .. filename)
  local file = io.open(dir .. filename, "w")
  file:write(self.pool.generation .. "\n")
  file:write(self.pool.maxFitness .. "\n")
  file:write(#self.pool.species .. "\n")
  for n,species in pairs(self.pool.species) do
    file:write(species.topFitness .. "\n")
    file:write(species.staleness .. "\n")
    file:write(#species.genomes .. "\n")
    for m,genome in pairs(species.genomes) do
      file:write(genome.fitness .. "\n")
      file:write(genome.maxneuron .. "\n")
      for mutation,rate in pairs(genome.mutationRates) do
        file:write(mutation .. "\n")
        file:write(rate .. "\n")
      end
      file:write("done\n")

      file:write(#genome.genes .. "\n")
      for l,gene in pairs(genome.genes) do
        file:write(gene.into .. " ")
        file:write(gene.out .. " ")
        file:write(gene.weight .. " ")
        file:write(gene.innovation .. " ")
        if(gene.enabled) then
          file:write("1\n")
        else
          file:write("0\n")
        end
      end
    end
  end
  file:close()
end

function Neat:loadFile(filename)
  local dir = "backups/" .. self.id .. "/"
  os.execute("mkdir -p ".. dir)
  local file = io.open(dir .. filename, "w")
  self.pool = self:_newPool()
  self.pool.generation = file:read("*number")
  self.pool.maxFitness = file:read("*number")

  local numSpecies = file:read("*number")
  for s=1,numSpecies do
    local species = self:_newSpecies()
    table.insert(self.pool.species, species)
    species.topFitness = file:read("*number")
    species.staleness = file:read("*number")
    local numGenomes = file:read("*number")
    for g=1,numGenomes do
      local genome = self:_newGenome()
      table.insert(species.genomes, genome)
      genome.fitness = file:read("*number")
      genome.maxneuron = file:read("*number")
      local line = file:read("*line")
      while line ~= "done" do
        genome.mutationRates[line] = file:read("*number")
        line = file:read("*line")
      end
      local numGenes = file:read("*number")
      for n=1,numGenes do
        local gene = self:_newGene()
        table.insert(genome.genes, gene)
        local enabled
        gene.into, gene.out, gene.weight, gene.innovation, enabled = file:read("*number", "*number", "*number", "*number", "*number")
        if enabled == 0 then
          gene.enabled = false
        else
          gene.enabled = true
        end

      end
    end
  end
  file:close()

  while fitnessAlreadyMeasured() do
    self:_nextGenome()
  end
  self:_initializeRun()
end

function Neat:setID(id)
  self.id = id
  self.saveLoadFile = self.id
end

function Neat:endRun(fitness)
  local species = self.pool.species[self.pool.currentSpecies]
  local genome = species.genomes[self.pool.currentGenome]
  
  genome.fitness = fitness

  if fitness > self.pool.maxFitness then
    self.pool.maxFitness = fitness
    self:_writeFile("backup." .. self.pool.generation .. "." .. self.saveLoadFile)
  end

  print("Gen " .. self.pool.generation .. " species " .. self.pool.currentSpecies .. " genome " .. self.pool.currentGenome .. " fitness: " .. fitness)
  self.pool.currentSpecies = 1
  self.pool.currentGenome = 1
  while self:_fitnessAlreadyMeasured() do
    self:_nextGenome()
  end
  self:_initializeRun()
end


--[[MaxRounds = 50
function Neat:_main() 
  
  CreateBoard()
  writeFile("temp.pool")
  
  while true do
    
    local species = pool.species[pool.currentSpecies]
    local genome = species.genomes[pool.currentGenome]

    timeout = timeout - 1
    rounds = rounds + 1
    if(lastPlayerRow ~= playerRow or lastPlayerCol ~= playerCol) then
      timeout = TimeoutConstant
    end
    lastPlayerRow = playerRow
    lastPlayerCol = playerCol
    
   -- printBoard()
      
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
      
      --if fitness == 0 then
      --   fitness = -1
      --end

      genome.fitness = fitness

      if fitness > pool.maxFitness then
        pool.maxFitness = fitness
        writeFile("backup." .. pool.generation .. "." .. self.saveLoadFile)
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
end]]