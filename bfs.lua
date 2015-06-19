function BFS(data, func, max_depth)
  max_depth = max_depth or 10000

  local queue = {}
  local depth = {} -- depth queue
  local head  = 1
  local tail  = 1
  local function push(e, d)
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

  local elem = data
  local d = 1

  local function visit(i,j)
    if (i < 1 or j < 1 or i > Board.static.size or j > Board.static.size) then
      return nil
    end
    if (board[i][j] ~= Board.static.death_cell) then
      push(child, d + 1)
    
  end
  
  while elem and d <= max_depth do


    if board[i][j] == Board.static.goal_cell then return d end
    for _, child in ipairs(elem) do
      if type(child) == 'table' then
        push(child, d + 1)
      end
    end

    elem, d = pop()
  end
end 