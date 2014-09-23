-- constants
gravity = -550   --重力大小
upSpeed = 250    --点击后上升的高度

-- create the moving bird
function creatBird() 
    --create bird animate
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --修改随机数种子
    local birdNum = math.random(0,2)
    local spriteBird = createAtlasSprite("bird"..birdNum.."_1")
    spriteBird:setPhysicsBody(cc.PhysicsBody:createCircle(spriteBird:getContentSize().width/2))
    spriteBird:getPhysicsBody():setEnable(true)
    spriteBird:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height/2)
    local animation = cc.Animation:createWithSpriteFrames({createAtlasFrame("bird"..birdNum.."_0"), createAtlasFrame("bird"..birdNum.."_1"), createAtlasFrame("bird"..birdNum.."_2")},0.1)
    local animate = cc.Animate:create(animation)
    spriteBird:runAction(cc.RepeatForever:create(animate))
    
    -- moving bird at every frame
    local function tick()
        local x, y = spriteBird:getPosition()
        if y > origin.y+atlas["bird0_0"].height/2 then
            y = y - 1.5
        end
        spriteBird:setPositionY(y)
    end

    --schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
    return spriteBird
end

-- handling touch events
function birdTouchHandler(layerFarm, spriteBird)
    --local touchBeginPoint = nil
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        cclog("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
        touchBeginPoint = {x = location.x, y = location.y}
        -- CCTOUCHBEGAN event must return true
        spriteBird:getPhysicsBody():setVelocity(cc.p(0, upSpeed))
        return true
    end
    
    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        --cclog("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
        if touchBeginPoint then
            local cx, cy = layerFarm:getPosition()
            layerFarm:setPosition(cx + location.x - touchBeginPoint.x,
                                  cy + location.y - touchBeginPoint.y)
            touchBeginPoint = {x = location.x, y = location.y}
        end
    end
    
    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        --cclog("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
        touchBeginPoint = nil
        spriteBird.isPaused = false
    end
    
    
    -- 事件监听的方式
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layerFarm:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerFarm)
end 