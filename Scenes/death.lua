local composer = require( "composer" )
local scene = composer.newScene()
local g = require "globals"
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
local myText
local button
---------------------------------------------------------------------------------

-- "scene:create()"
local function buttonPress( self, event )
	composer.gotoScene( g.scenePath.."menu" )
	return true
end

function scene:create( event )

	local sceneGroup = self.view
	myText = display.newText( "YOU DIED!", 
									g.ccy, 
									g.ccy, 
									"Curse of the Zombie", 
									80 )
	sceneGroup:insert(myText)
	button = display.newRect( 	g.ccx,
								g.ach - 100,
								g.acw*3/20,
								100)
	sceneGroup:insert(button)
	button.touch = buttonPress
	button:addEventListener( "touch", buttons )
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
	myText:removeSelf()
	myText = nil
	button:removeEventListener( "touch", button )
	local sceneGroup = self.view

-- Called prior to the removal of scene's view ("sceneGroup").
-- Insert code here to clean up the scene.
-- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
--R:addEventListener( "key", onKeyPress )

---------------------------------------------------------------------------------

return scene