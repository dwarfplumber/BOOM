local S = {}

	local function spawn(x, y)
		local col = require "collision_filters"
		local T = {}
			T.bounds = display.newImageRect(GLOBAL_graphicsPath.."/Items/SpeedPowerUp.png", 100, 100 )
			T.bounds.myName = "powerup"
			T.bounds.x = x
			T.bounds.y = y
			T.bounds.super = T
			T.myName = "powerup"
			print("making powerup: " .. x .. " : " .. y)
			physics.addBody(
				T.bounds,
				"kinematic",
				{
					isSensor=true,
					filter=col.sensorCol
				})
			T.powerup = function(event)
				local fx = audio.loadSound( GLOBAL_soundsPath.."/PowerUps/SpeedPowerUp.ogg")
				local other = event.other.super
				audio.play(fx,{channel = audio.findFreeChannel()})
				audio.dispose( fx )
				other.maxSpeed = other.maxSpeed + 50
				GLOBAL_speed = other.maxSpeed
				display.remove( T.bounds )
			end
			T.bounds:addEventListener( "collision", T.powerup )

		return T
	end
	S.spawn = spawn
return S
