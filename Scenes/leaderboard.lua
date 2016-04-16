local composer = require( "composer" )
local g = require "globals"
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
Leaderboard = {}
---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )
-----Map-----
	local path = system.pathForFile("LeaderBoard.BOOMFILE",system.ResourceDirectory)
	local file = io.open(path,"r")
	i = 1

	function explode(div,str)
	  if (div=='') then return false end
	  local pos,arr = 0,{}
	  for st,sp in function() return string.find(str,div,pos,true) end do
		 table.insert(arr,string.sub(str,pos,st-1))
		 pos = sp + 1
	  end
	  table.insert(arr,string.sub(str,pos))
	  return arr
	end

	for line in file:lines()do
	  Leaderboard[i] = explode(",",line)
	  i = i + 1
	end

	io.close(file)
	local sceneGroup = self.view
	local leaderBoardString = "Medal | Name Hrs : Mins : Secs Kills | Deaths\n\n"
	for i=1,table.getn(Leaderboard) do
	  leaderBoardString =  leaderBoardString..Leaderboard[i][1].." | "
						   ..Leaderboard[i][2].." ["
						   ..Leaderboard[i][3].." : "
						   ..Leaderboard[i][4].." : "
						   ..Leaderboard[i][5].."] "
						   ..Leaderboard[i][6].." | "
						   ..Leaderboard[i][7].."\n"
	end
	myText = display.newText( leaderBoardString, g.ccx, g.ccy, "Bloody", 50 )
	myText:setFillColor(1,0,0)
	sceneGroup:insert(myText)
	-- Initialize the scene here.
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.

	local press = audio.loadSound( "Sounds/GUI/ButtonPress.ogg")
	function buttonPress( self, event )
    	if event.phase == "began" then
    		audio.play(press, {channel = 31})
    		if self.id == 1 then
    			composer.gotoScene( g.scenePath.."menu" )
    		end
    		return true
    	end
	end

	button = display.newRect(125,37.5,250,75)
	button:setFillColor( 1, 1, 0 )
	button.id = 1
	button.touch = buttonPress
	button:addEventListener( "touch", button )
		
	buttonText = display.newText( "MAIN MENU", 125,37.5, "Curse of the Zombie", 30 )
	buttonText:setFillColor(1,0,0)
	sceneGroup:insert(button)
	sceneGroup:insert(buttonText)
end

-- "scene:show()"
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
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

	local sceneGroup = self.view
		path = nil
		file = nil
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

---------------------------------------------------------------------------------

return scene