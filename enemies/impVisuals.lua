V = {}

    V.anim = ""
    V.sounds = {}
    local imp_sheetOptions =
    {
        width = 300,
        height = 300,
        numFrames = 64
    }
    local imp_sheet = graphics.newImageSheet( "Graphics/Animation/Imp.png", imp_sheetOptions )
    local imp_sequences = require "SpriteSeq.impSeq"
    V.imp_sprite = display.newSprite( imp_sheet, imp_sequences )

    local function animate(angle, ext) -- angle i.e 90, ext is the extension onto the animation, i.e "Shoot" or "Stand"
        -- Animate Upper Body
        local anim = ""
        if angle > 337 or angle < 23 then
            anim = "up"
        elseif angle < 68 then
            anim = "upRight"
        elseif angle < 113 then
            anim = "right"
        elseif angle < 158 then
            anim = "downRight"
        elseif angle < 203 then
            anim = "down"
        elseif angle < 248 then
            anim = "downLeft"
        elseif angle < 293 then
            anim = "left"
        else
            anim = "upLeft"
        end

        anim = anim .. ext

        if V.anim ~= anim then
            V.imp_sprite:setSequence(anim)
            V.imp_sprite:play()
            V.anim = anim
        end
    end

    V.animate = animate

return V