function createLand()
    landHeight = atlas["land"].height/2
    
    -- first moving land
    local land_1 = createAtlasSprite("land")
    land_1:setPosition(visibleSize.width / 2, landHeight / 2)

    local move1 = cc.MoveTo:create(2, cc.p(- visibleSize.width / 2, landHeight / 2))
    local reset1 = cc.Place:create(cc.p(visibleSize.width / 2, landHeight / 2))
    land_1:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, reset1)))

    -- second moving land
    local land_2 = createAtlasSprite("land")
    land_2:setPosition(visibleSize.width * 3 / 2, landHeight / 2)

    local move2 = cc.MoveTo:create(2, cc.p(visibleSize.width / 2, landHeight / 2))
    local reset2 = cc.Place:create(cc.p(visibleSize.width * 3 / 2, landHeight / 2))
    land_2:runAction(cc.RepeatForever:create(cc.Sequence:create(move2, reset2)))
    
    return land_1, land_2
end