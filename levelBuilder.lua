local B = {}

	local function buildLevel(levelNo)
		local b = {}
		local g = require "globals"
		local col = require "collisionFilters"
		local enemy = require "enemy"
		local imp = require "imp"
		local spot = require "spot"
		b.level = display.newGroup( )
		b.enemies = {group = display.newGroup()}
		local levelName = "level"..levelNo..".BOOMMAP"
		local map = {}
		local imps = display.newGroup()
		local spots = display.newGroup()
		local minotaurs = display.newGroup()
		local size = 5
		local verticesMap = {
			{
				{0,0,0,128,128,128,128,0},
				{0,0,0,128,128,128,128,0},
				{0,0,0,128,128,128,128,0},
				{0,0,0,128,128,128,128,0}
			},
			{
				{64,64,0,128,128,128,128,0},
				{0,0,0,128,128,128,64,64},
				{0,0,0,128,64,64,128,0},
				{0,0,64,64,128,128,128,0}
			},
			{
				{10,0,0,0,0,10,118,128,128,128,128,118},
				{128,10,128,0,118,0,0,118,0,128,10,128},
				{10,0,0,0,0,10,118,128,128,128,128,118},
				{128,10,128,0,118,0,0,118,0,128,10,128}
			},
			{
				{0,0,128,0,128,20,0,20},
				{49,0,69,0,69,128,49,128},
				{0,0,128,0,128,20,0,20},
				{49,0,69,0,69,128,49,128}
			}
		}

		for i = 1, #verticesMap do
			for j = 1, #verticesMap[i] do
				for k = 1, #verticesMap[i][j] do
					verticesMap[i][j][k] = verticesMap[i][j][k]*5
				end
			end
		end

		local function getVertices(type,rotation)
			local vertices = verticesMap[type][rotation]
			return vertices
		end
		

		b.floor = display.newRect(g.ccx, g.ccy,500000,500000)
		display.setDefault( "textureWrapX", "repeat" )
		display.setDefault( "textureWrapY", "repeat" )
		b.floor.fill = {type = "image",filename ="/Graphics/Background/FloorTile.png"}
		b.floor.fill.scaleX = 0.001
		b.floor.fill.scaleY = 0.001

		local path = system.pathForFile(levelName,system.ResourceDirectory)
		local file = io.open(path,"r")
		function explode(div,str)
			if (div=='') then 
				return false 
			end
			local pos,arr = 0,{}
			for st,sp in function() return string.find(str,div,pos,true) end do
				table.insert(arr,string.sub(str,pos,st-1))
				pos = sp + 1
			end
			table.insert(arr,string.sub(str,pos))
			return arr
		end
		local counter = 1
		for line in file:lines()do
			map[counter] = explode(",",line)
			counter = counter + 1
			--print (counter)
		end
		io.close(file)
		local objectFileName = {"lavaTile","lavaTile","wall_diagonal","wall_flat"}
		local physlevel = {}
		for mapCounter=1,table.getn(map),1 do
			print("here")
			if (tonumber(map[mapCounter][1]) <11 and tonumber(map[mapCounter][1]) >0) then
				physlevel[mapCounter] = display.newPolygon( b.level,
															tonumber((map[mapCounter][3])-448)*size,
															tonumber((map[mapCounter][4])-448)*size, 
															getVertices(tonumber(map[mapCounter][1]),
															tonumber(map[mapCounter][2])))
				--physlevel[mapCounter]:setFillColor(0.5,0,0,1)
				physlevel[mapCounter].fill = { 	type="image", 
												filename=g.backgroundPath..objectFileName[tonumber(map[mapCounter][1])]..tonumber(map[mapCounter][2])..".png" }
				physics.addBody( 	physlevel[mapCounter], 
									"static", 
									{
										friction = 0, 
										bounce = 0.3, 
										filter=col.wallCol
									}
								)
				physlevel[mapCounter].myName = "Wall"
				physlevel[mapCounter].super = physlevel[mapCounter]
			elseif(tonumber(map[mapCounter][1]) <21)then
				local enemyType = tonumber(map[mapCounter][1])
				local location = 	{
										tonumber((map[mapCounter][3])-448)*size,
										tonumber((map[mapCounter][4])-448)*size
									}
				if(enemyType == 11)then
					b.enemies.group:insert(imp.spawn(location[1],location[2]).parent)
				elseif(enemyType == 12)then
					--spawn dog
				elseif(enemyType == 13)then
					--spawn rosy
				end
			elseif(tonumber(map[mapCounter][1]) <31)then
				--spawn items/deco
			elseif(tonumber(map[mapCounter][1]) <41)then
				--satans trailpath
			end
		end

		zerozero = display.newRect( b.level, 0, 0, 100, 100 )
		zerozero:setFillColor( 0,0,1 )
		return b
	end
	B.buildLevel = buildLevel
return B