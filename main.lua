-- A weighted map. 8 are bounds (impassable locations)
-- Other values are passable. The higher a value is, the 
-- harder it costs to an agent to travel to that location.
-- 1 are cells easily crossed, 3 are harder to cross.
local map = {
	{5,5,5,5,5,5,5,5,5,5},
	{5,1,1,1,2,2,2,2,2,5},
	{5,2,2,1,2,2,2,2,1,5},
	{5,2,2,1,3,3,2,2,1,5},
	{5,2,2,1,3,3,2,2,1,5},
	{5,2,2,1,3,3,3,3,1,5},
	{5,2,2,1,1,1,1,1,1,5},
	{5,2,2,2,3,3,3,3,1,5},
	{5,2,3,3,3,3,3,3,2,5},
	{5,5,5,5,5,5,5,5,5,5},
}

-- A custom function that print the actual state of the
-- distance map
local function printDistanceMap(grid)
	print()
	for y,row in ipairs(grid.nodes) do
		for x,cell in ipairs(row) do
			io.write(('%4s'):format(cell.distance))
		end
		io.write('\n')
	end
	print()
end

-- A custom function that print some debugging information
-- It sequentially prints a message, then the distance map, then the path
-- returned by grid.getPath (see grid.lua)
local function printInfo(grid, path, cost, msg)
  print(msg)
  printDistanceMap(grid)
  print(('path : %d steps - cost: %d'):format(#path, cost))
  -- Print the path  
  for k, node in ipairs(path) do
    print(('step:%d, x: %d, y: %d'):format(k, node.x, node.y))
  end
  print(('-'):rep(80))
end

-- Dependencies
local runDijsktra = require 'dijkstra'
local grid = require 'grid'

grid.create(map)  -- We create the grid map
grid.passable = function(value) return value ~= 5 end -- values ~= 5 are passable
grid.diagonal = false  -- diagonal moves are disallowed (this is the default behavior)
grid.distance = grid.calculateManhattanDistance  -- We will use manhattan heuristic

-- Our target is node(2,2). We pass it to dijsktra 
-- algorithm so that it will calculate all shortest paths from this 
-- target to every other cell.
local target = grid.getNode(2,2)
runDijsktra(grid, target)

--  Let us read the full path from node(9,9) => node(2,2)
local start = grid.getNode(9,9)
local p, cost = grid.findPath(start,target)
printInfo(grid, p, cost, 'path : (9,9) => (2,2)')

-- Now let us read the full path from node(9,5) => node(2,2)
start = grid.getNode(9,5)
p, cost = grid.findPath(start,target)
printInfo(grid, p, cost, 'path : (9,5) => (2,2)')

-- Now we want to get the path from node(5,9) => node(9,2)
-- Since the target has changed, we need to recalculate the grid
target = grid.getNode(9,2)
runDijsktra(grid, target)

start = grid.getNode(5,9)
p, cost = grid.findPath(start,target)
printInfo(grid, p, cost, 'path : (5,9) => (9,2)')

-- Assume now that we have an agent that can move in a limited range.
-- the maximum cost he can spend is 5. We want to move that agent
-- from node(5,9) to node(9,2), same path than before. We want to get
-- the path (even incomplete) this agent should follow
local maxDistanceOfAgent = 6
p, cost = grid.findPath(start,target,maxDistanceOfAgent)
printInfo(grid, p, cost, 'path : (5,9) => (9,2) : maxCost: 5')

-- The agent has not yet arrived to the goal. So the next steps that
-- remains to reach the goal
local agentPosition = grid.getNode(p[#p].x, p[#p].y)
p, cost = grid.findPath(agentPosition,target,maxDistanceOfAgent)
printInfo(grid, p, cost, ('path : (%d,%d) => (9,2) : maxCost: 5'):format(agentPosition.x, agentPosition.y))

-- And again....
agentPosition = grid.getNode(p[#p].x, p[#p].y)
p, cost = grid.findPath(agentPosition,target,maxDistanceOfAgent)
printInfo(grid, p, cost, ('path : (%d,%d) => (9,2) : maxCost: 5'):format(agentPosition.x, agentPosition.y))