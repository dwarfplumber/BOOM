local composer = require( "composer" )
local scene = composer.newScene()
local col = require "collisionFilters"
local g = require "globals"
local joysticks = require "joystick"
local perspective = require("perspective")
local goreCount = 0
local physics = require "physics"
local playerBuilder = require "playerMechanics"
local satanBuilder = require "satan"


local controllerMapping = require "controllerMapping"
local levelBuilder = require "levelBuilder"
local camera = perspective.createView()

local map = {
	params = {},
	enemies = {},
	traps = {},
	player = {},
	satan = {},
	level = display.newGroup( ),
	floor = display.newGroup( ),
	trapsDisplay = display.newGroup( ),
	enemiesDisplay = display.newGroup( ),
	gore = {},
	fireballs = {}
}

function updateGUI()
	sceneGroup:insert(player.shotgun.displayPower())
	if(playerTextSpeed)then
		playerTextSpeed:removeSelf()
	end
	playerTextSpeed = display.newText( sceneGroup, tostring(player.maxSpeed/50).." KMPH", 400, 100, "Curse of the Zombie", 50 )
	playerTextSpeed:setFillColor( 1,1,0 )
end

function createMap()
	map.params = levelBuilder.buildLevel(g.level)
	map.enemies = map.params.enemies
	map.traps = map.params.traps
	map.level = map.params.level
	map.floor = map.params.floor
	map.player = playerBuilder.spawn()

	for i = 1, #map.enemies do
		map.enemiesDisplay:insert(map.enemies[i].parent)
	end

	for i = 1, #map.traps do
		map.trapsDisplay:insert(map.traps[i].bounds)
	end

	map.satan = satanBuilder.spawn(map.params.satanPath)
	map.satan.start()
	map.player.bounds:translate(0,0)

	camera:add(map.player.parent, 1)
	camera:add(map.player.bounds, 1)
	camera:add(map.level, 4)
	camera:add(map.player.shotgun.blast, 1)
	camera:add(map.player.shotgun.bounds, 1)
	camera:add(map.satan.bounds, 2)
	camera:add(map.enemiesDisplay, 2)
	camera:add(map.trapsDisplay, 4)
	camera:add(map.floor,5)
	camera:add(map.player.torchLight, 5)
	--print ("player x: " .. player.bounds.x .. ", player y: " .. player.bounds.y )

	-- INITIALIZING CAMERA
	camera:prependLayer()
	camera.damping = 10
	camera:setFocus(map.player.cameraLock)
	camera:track()
end 



function updateGUI()
	sceneGroup:insert(map.player.shotgun.displayPower())
end

local function onAxisEvent( event )
	-- Map event data to simple variables
	if string.sub( event.device.descriptor, 1 , 7 ) == "Gamepad" then
		local axis = controllerMapping.axis[event.axis.number]
		--if g.pause then print("g.pause = true") else print("g.pause = false") end
		if(g.pause == false) then
			map.player.playerAxis(axis, event.normalizedValue)
		end
	end
	return true
end

local function onKeyEvent( event )
	local phase = event.phase
	local keyName = event.keyName
	local axis = ""
	local value = 0

	if (event.phase == "down") then
		-- Adjust velocity for testing, remove for final game        
		if ( event.keyName == "[" or event.keyName == "rightShoulderButton1" ) then
			if (player.velocity > 0 ) then
			player.maxSpeed = player.maxSpeed - 50
				player.shotgun.powerUp(-1)
			end
		elseif ( event.keyName == "]" or event.keyName == "leftShoulderButton1" ) then
			player.maxSpeed = player.maxSpeed + 50
			player.shotgun.powerUp(1)
			if (map.player.velocity > 0 ) then
			--player.velocity = player.velocity - 1
				map.player.shotgun.powerUp(-1)
			end
		elseif ( event.keyName == "]" or event.keyName == "leftShoulderButton1" ) then
			--player.velocity = player.velocity + 1
			map.player.shotgun.powerUp(1)
		end
		-- WASD and ArrowKeys pressed down
		if ( event.keyName == "w" ) then
			value = -1.0
			axis = "left_y"
		elseif ( event.keyName == "s") then
			value = 1
			axis = "left_y"
		elseif ( event.keyName == "a") then
			value = -1
			axis = "left_x"
		elseif ( event.keyName == "d") then
			value = 1
			axis = "left_x"
		elseif ( event.keyName == "up") then
			value = -1
			axis = "right_y"
		elseif ( event.keyName == "down") then
			value = 1
			axis = "right_y"
		elseif ( event.keyName == "left") then
			value = -1
			axis = "right_x"
		elseif ( event.keyName == "right") then
			value = 1
			axis = "right_x"
		elseif ( event.keyName == "space") then
			value = 1
			axis = "left_trigger"
		end
	else
		-- WASD and Arrow keys pressed up
		if ( event.keyName == "w" ) then
			value = 0
			axis = "left_y"
		elseif ( event.keyName == "s") then
			value = 0
			axis = "left_y"
		elseif ( event.keyName == "a") then
			value = 0
			axis = "left_x"
		elseif ( event.keyName == "d") then
			value = 0
			axis = "left_x"
		elseif ( event.keyName == "up") then
			value = 0
			axis = "right_y"
		elseif ( event.keyName == "down") then
			value = 0
			axis = "right_y"
		elseif ( event.keyName == "left") then
			value = 0
			axis = "right_x"
		elseif ( event.keyName == "right") then
			value = 0
			axis = "right_x"
		elseif (event.keyName == "l") then
			composer.gotoScene( g.scenePath.."death")
		end
	end

	if (g.pause == false) then 
		print(map.player.myName)
		map.player.playerAxis(axis, value) 
	end

	return false
end

local function makeGore( event )
	timer.performWithDelay( 10,
		function ()
			local go = event.splat(map.player.thisAimAngle, event.bounds.x, event.bounds.y)
			goreCount = goreCount + 1
			if(map.gore[math.fmod(goreCount, g.maxGore)] ~= nil) then
				map.gore[math.fmod(goreCount, g.maxGore)]:removeSelf()
				map.gore[math.fmod(goreCount, g.maxGore)] = nil
			end
				map.gore[math.fmod(goreCount, g.maxGore)] = go
			if(map.gore[math.fmod(goreCount, g.maxGore)] ~= nil)then
				print("making gore")
				camera:add(map.gore[math.fmod(goreCount, g.maxGore)], 3)
			end
			--display.remove( go )
		end
	)
end

local function fireball( event )
	--timer.performWithDelay( 10, 
	--	function ()
			map.fireballs[#map.fireballs + 1] = event.f
			if(map.fireballs[#map.fireballs] ~= nil)then
				camera:add(map.fireballs[#map.fireballs] , 3)
			end
	--	end
	--)
end


local function youWin( event )
	print("you win")
end

local function youDied( event )
	print("you Died")
	g.pause = true
	composer.gotoScene( g.scenePath.."death")

end

local function getPlayerLocation( event )
	if(map.player.isAlive == true) then
		local p = event.updatePlayerLocation(map.player.bounds.x, map.player.bounds.y)
		return p
	end
end

local function gameLoop( event )
	--print("in game loop")
	if g.pause == false and axis ~= "" then
		
		--local shotgunOMeter = map.player.shotgun.displayPower()
		--updateGUI()
		if(g.android) then
			map.player.virtualJoystickInput(leftJoystick.angle, leftJoystick.xLoc/70, leftJoystick.yLoc/70, rightJoystick.angle, rightJoystick.distance/70, rightJoystick.xLoc/70, rightJoystick.yLoc/70)
		end
		map.player.movePlayer()
	end
	return true
end
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
-- "scene:create()"
function scene:create( event )
	physics.start()
	physics.setGravity(0,0)
	physics.setDrawMode( "hybrid" )
	g.pause = false
	sceneGroup = self.view
	createMap()
	sceneGroup:insert(camera)
	
	local bgOptions =
	{
		channel = 20,
		loops = -1,
		fadein = 1000,
	}
	audio.setVolume( 0.2, { channel=20 } )
	local bgMusic = audio.loadStream( "Sounds/Music/HeadShredder.mp3")
	audio.play(bgMusic,bgOptions)
	
	function buttonPress( self, event )
		if event.phase == "began" then
			audio.play(press, {channel = 31})
			if self.id == 1 then
				g.pause = true
				composer.showOverlay(g.scenePath.."pauseMenu")
			end
			return true
		end
	end
	if(g.android) then
		rightJoystick = joysticks.joystick(sceneGroup, 
							"Graphics/Animation/analogStickHead.png", 200, 200, 
							"Graphics/Animation/analogStickBase.png", 280, 280, 2.5 )
		rightJoystick.x = g.acw -250
		rightJoystick.y = g.ach -250
		rightJoystick.activate()
		leftJoystick = joysticks.joystick(sceneGroup, 
							"Graphics/Animation/analogStickHead.png", 200, 200, 
							"Graphics/Animation/analogStickBase.png", 280, 280, 1.0 )
		leftJoystick.x = 250
		leftJoystick.y = g.ach -250
		leftJoystick.activate()
	end
	local pauseButton = display.newCircle(0,0,200)
	sceneGroup:insert(pauseButton)
	pauseButton.id = 1
	pauseButton.touch = buttonPress
	pauseButton:addEventListener( "touch", pauseButton )
	local press = audio.loadSound( "Sounds/GUI/ButtonPress.ogg")
	-- Initialize the scene here.
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- "scene:show()"
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	-- Called when the scene is still off screen (but is about to come on screen).
	elseif ( phase == "did" ) then
	composer.removeScene( g.scenePath.."menu", false )
	g.pause = false
	-- Called when the scene is now on screen.
	-- Insert code here to make the scene come alive.
	-- Example: start timers, begin animation, play audio, etc.
	end
end

-- "scene:hide()"
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	-- Called when the scene is on screen (but is about to go off screen).
	-- Insert code here to "pause" the scene.
	-- Example: stop timers, stop animation, stop audio, etc.
	elseif ( phase == "did" ) then
	-- Called immediately after scene goes off screen.
	end
end

-- "scene:destroy()"
function scene:destroy( event )

	g.pause = true
	local sceneGroup = self.view
	local phase = event.phase
	

	Runtime:removeEventListener( "enterFrame", gameLoop )
 	Runtime:removeEventListener( "key", onKeyEvent )
  	Runtime:removeEventListener( "axis", onAxisEvent )
  	Runtime:removeEventListener( "makeGore", makeGore)
	Runtime:removeEventListener( "fireball", fireball)
	Runtime:removeEventListener( "youWin", youWin)
	Runtime:removeEventListener( "youDied", youDied)
	Runtime:removeEventListener( "getPlayerLocation", getPlayerLocation)

	map.player.die()
	map.player = nil
	map.player = {}
	display.remove( map.enemiesDisplay )
	for i = 1, #map.enemies do
		if(map.enemies[i] ~= nil) then
			map.enemies[i].die(false)
		end
	end
	display.remove( map.level )
	transition.cancel( map.satan.bounds )
	display.remove( map.satan.bounds )
	map.satan = nil
	map.satan = {}
	display.remove( map.floor )
	display.remove( map.trapsDisplay )
	map.params = nil
	map.params = {}
	for i = 1, #map.gore do
		if(map.gore[i] ~= nil) then
			display.remove(map.gore[i])
			map.gore[i] = nil
		end
	end
	for i = 1, #map.fireballs do
		if(map.fireballs[i] ~= nil) then
			map.fireballs[i].die()
			map.fireballs[i] = nil
		end
	end
	camera.destroy()
	timer.performWithDelay( 10, 
		function()
			physics.stop( )
		end
	)
	
	--scene:removeEventListener( "create", scene )
	--scene:removeEventListener( "show", scene )
	--scene:removeEventListener( "hide", scene )
	--scene:removeEventListener( "destroy", scene )
	--]]
	
-- Called prior to the removal of scene's view ("sceneGroup").
-- Insert code here to clean up the scene.
-- Example: remove display objects, save state, etc.
end
---------------------------------------------------------------------------------


---------------------------------------------------------------------------------

-- Listener setup
Runtime:addEventListener( "makeGore", makeGore)
Runtime:addEventListener( "fireball", fireball)
Runtime:addEventListener( "youWin", youWin)
Runtime:addEventListener( "youDied", youDied)
Runtime:addEventListener( "getPlayerLocation", getPlayerLocation)
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
Runtime:addEventListener( "enterFrame", gameLoop )
if(g.android == false) then 
  Runtime:addEventListener( "key", onKeyEvent )
  Runtime:addEventListener( "axis", onAxisEvent )
end
---------------------------------------------------------------------------------

return scene