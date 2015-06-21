require 'Board'


INFINITE = 999999999
function BFS(startI, startJ, matrix, endI, endJ)

  local max_depth = 10000

  local visited = {}

  for i=1,Board.static.size do
    visited[i] = {}
    for j=1,Board.static.size do
      visited[i][j] = false
    end
  end 

  local queue = {}
  local depth = {} -- depth queue
  local head  = 1
  local tail  = 1
  
  local function push(e, d)
    --print("TAIL " .. tail)
    queue[tail] = e
    depth[tail] = d
    tail = tail + 1
  end

  local function pop()
    if head == tail then return nil end
    local e, d = queue[head], depth[head]
    head = head + 1
    return e, d
  end
  
  local function intToPos(i)
    local col = i%Board.static.size
    if col < 1 then col = Board.static.size end
    return math.ceil(i/Board.static.size),col
  end
  
  local function posToInt(i,j)
    return  (i-1)*Board.static.size + j
  end
  

-- BFS

  local currentPos = posToInt(startI,startJ)
  local d = 1
  if matrix.cells[startI][startJ] == Board.static.death_cell then return INFINITE end
  local function visit(i,j, d)
    if (i < 1 or j < 1 or i > Board.static.size or j > Board.static.size or visited[i][j]) then
      return nil
    end

    if (matrix.cells[i][j] ~= Board.static.death_cell) then
      push(posToInt(i,j), d + 1)
    end
    visited[i][j] = true
  end

  while currentPos and d <= max_depth do

   
    local i,j = intToPos(currentPos)
    --print(i,j)
    if matrix.cells[i][j] == Board.static.goal_cell or (i == endI and j == endJ) then return d-1 end
    local k, l
    for k = -1, 1 do
      for l = -1, 1 do
        --print(i - k, j - l, d)
        visit(i - k, j - l, d)
      end
    end

    currentPos, d = pop()
  end
  
end 