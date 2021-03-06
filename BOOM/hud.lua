local HUD = {}
local hudInitialized = false
	
local s = require "HUD.speedometer"

local function initializeHUD()
	hudInitialized = true
	HUD.hudGroup = display.newGroup()
	HUD.distance = 0
	HUD.satanIndicatorGroup = display.newGroup()
	HUD.pointer = display.newPolygon( HUD.satanIndicatorGroup, GLOBAL_ccx, GLOBAL_ccy, {0,0, 35,50,90,0,35,-50} )
	--HUD.satanIndicator = display.newCircle( HUD.satanIndicatorGroup, GLOBAL_ccx, GLOBAL_ccy, 60 )
	local sheetOptions =
	{
		width = 165,
		height = 165,
		numFrames = 12
	}
	HUD.sheet_satanIndicator = graphics.newImageSheet(GLOBAL_UIPath .. "SatanIndicator.png", sheetOptions)
	local sequences_satanIndicator =
	{
		{
			name = "play",
			start = 1,
			count = 12,
			time = 1200,
			loopCount = 0,
			loopDirection = "forward"
		}
	}
	HUD.satanIndicator = display.newSprite( HUD.satanIndicatorGroup, HUD.sheet_satanIndicator,sequences_satanIndicator)
	HUD.satanIndicator.x = GLOBAL_ccx
	HUD.satanIndicator.y = GLOBAL_ccy
	HUD.satanIndicator:scale(0.75,0.75)
	HUD.satanIndicator:setSequence("play")
	HUD.satanIndicator:play()
	HUD.distanceText = display.newText( HUD.satanIndicatorGroup, tostring(HUD.distance).."m", GLOBAL_ccx, GLOBAL_ccy+60, GLOBAL_comicBookFont,60)
	HUD.hudGroup:insert(HUD.satanIndicatorGroup)
	HUD.satanIndicator.alpha = 0
	HUD.pointer:setFillColor(1,0,0,0)
	HUD.distanceText:setFillColor( 1,1,0,0)
	HUD.pointer.anchorX=-1

	HUD.shotgunOMeter = display.newImage( HUD.hudGroup, GLOBAL_UIPath.."Shotgun.png", 400, 110, isFullResolution )
	HUD.blocks = {}

	-- SPEEDOMETER
	HUD.speedometer = s.spawn()
	HUD.speedometer.set(GLOBAL_speed/50 - 10)
	HUD.speedometer.x = 270
	HUD.speedometer.y = 180
	HUD.hudGroup:insert(HUD.speedometer)

	HUD.hudGroup.x = -300
	HUD.hudGroup.y = -500

	-- TIMER
	HUD.timer = display.newText(
		"00:00:00",
		GLOBAL_cw-150,
		80,
		400,
		0,
		GLOBAL_lcdFont,
		80
	)
	HUD.timer:setFillColor( 1,1,0 )
	HUD.hudGroup:insert(HUD.timer)

	-- STARTING THE GAME
	HUD.startText = display.newText(
		"RUN!",
		GLOBAL_ccx,
		GLOBAL_ccy-140,
		GLOBAL_zombieFont,
		180
	)
	HUD.startText:setFillColor( 1,0,0 )
	HUD.startText.alpha = 0.0
	HUD.hudGroup:insert(HUD.startText)
	transition.to(
		HUD.hudGroup,
		{
			time = 1000, x = 0, y = 0,
			onComplete = function()
				HUD.startText.alpha = 1.0
				transition.scaleTo( HUD.startText, { xScale=2.0, yScale=2.0, time=1000 } )
				transition.fadeOut( HUD.startText, {time=1000} )
			end
		}
	)

end
HUD.initializeHUD = initializeHUD

local function updateSatanPointer(satanX,satanY,playerX,playerY,cameraLockX,cameraLockY)
	HUD.distance = math.sqrt(math.pow((satanX-playerX),2)+math.pow((satanY-playerY),2))
	if HUD.distance/100 > 10 then
		HUD.satanIndicator.alpha = 1
		HUD.pointer:setFillColor(1,0,0,1)
		HUD.distanceText:setFillColor( 1,1,0,1)
		HUD.distanceText.text = tostring(math.floor(HUD.distance/100)).."m"

		local xDiff = satanX-playerX
		local yDiff = satanY-playerY
		local rotation = math.atan2(yDiff,xDiff)*(180/math.pi)
		HUD.pointer.rotation = rotation

		if xDiff < (GLOBAL_ccx*-1)+100 then
			xDiff = (GLOBAL_ccx*-1)+100
		elseif xDiff > GLOBAL_ccx-100 then
			xDiff = GLOBAL_ccx-100
		end

		if yDiff < (GLOBAL_ccy*-1) + 100 then
			yDiff = (GLOBAL_ccy*-1) + 100
		elseif yDiff > GLOBAL_ccy-100 then
			yDiff = GLOBAL_ccy-100
		end

		HUD.satanIndicatorGroup.x = xDiff
		HUD.satanIndicatorGroup.y = yDiff
	else
		HUD.satanIndicator.alpha = 0
		HUD.pointer:setFillColor(1,0,0,0)
		HUD.distanceText:setFillColor( 1,1,0,0)
	end
	-- NEED TO FIND A BETTER WAY OF DOING THIS..
	HUD.speedometer.set(GLOBAL_speed/50 - 10)

end
HUD.updateSatanPointer = updateSatanPointer

local function updateShotgunOMeter(power)
	for j = 1,table.getn(HUD.blocks), 1 do
		HUD.blocks[j]:removeSelf( )
	end
	for i = 1, power - 9, 1 do
		HUD.blocks[i]=display.newRect( HUD.hudGroup,(i*42)+340, 95, 40,40 )
		HUD.blocks[i]:setFillColor((i/2.5),2/i,0,0.8)
		HUD.blocks[i]:toBack()
	end
end
HUD.updateShotgunOMeter = updateShotgunOMeter

local function updateTimer( time )
	HUD.timer.text = "" .. math.floor(time/600000) .. math.floor((time/60000)%10) ..":"
		.. math.floor((time/10000)%6) .. math.floor((time/1000)%10) .. ":" .. math.floor((time/100)%10) .. math.floor((time/10)%10)
end

HUD.updateTimer = updateTimer

local function killHUD()
	if hudInitialized == true then
		HUD.hudGroup:removeSelf()
		HUD.hudGroup = nil
	end
end
HUD.killHUD = killHUD

return HUD
