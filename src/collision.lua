require "src/bird"  --import the function removeBirdTouchHandler(gameLayer)
require "src/pipe"  --import the funciton removeMovePipeFunc() and removeCalScoreFunc()

function addCollision(gameLayer, spriteBird, pipes, land_1, land_2)
    --设置land区域对应的刚体
    local landNode = cc.Node:create()   --由于land1, land2是在移动的，landNode是用来在land对应的区域内设置physicsBody
    local landHeight = 81
    local landWidth = visibleSize.width
    landNode:setPhysicsBody(cc.PhysicsBody:createEdgeSegment(cc.p(0, landHeight), cc.p(landWidth, landHeight)))
    landNode:getPhysicsBody():setEnable(true)
    gameLayer:addChild(landNode)
    --set bitmask and group: bug, will send event but will not contact
    spriteBird:getPhysicsBody():setCategoryBitmask(3)
    spriteBird:getPhysicsBody():setContactTestBitmask(1)
    spriteBird:getPhysicsBody():setCollisionBitmask(1)
    landNode:getPhysicsBody():setCategoryBitmask(1)
    landNode:getPhysicsBody():setContactTestBitmask(1)
    landNode:getPhysicsBody():setCollisionBitmask(1)
    landNode:getPhysicsBody():setGroup(1)
    spriteBird:getPhysicsBody():setGroup(1)

    --pipe对应的刚体在pipe.lua中设置
    
    --contactHandler
    local function onContactBetweenBirdAndLandBegin(contact)
        --注：categoryBitmask 1=land  3=bird  7=pipe
        --注：pipe和其他物体不会碰撞，会发送事件（bitmask设置生效）
        --注：land和bird不会碰撞，会发送事件（bitmask设置失效。。所以只能spriteBird:getPhysicsBody():setEnable(false)）
        local a = contact:getShapeA():getBody():getCategoryBitmask();
        local b = contact:getShapeB():getBody():getCategoryBitmask();
        if a == 3 and b == 1 or a == 1 and b == 3 then
            cclog("onContactBetweenBirdAndLandBegin")
            --bird collides with land
            spriteBird:getPhysicsBody():setEnable(false)
            spriteBird:stopAllActions()
            land_1:stopAllActions()
            land_2:stopAllActions()
            removeMovePipeFunc()
            removeBirdTouchHandler(gameLayer)
            removeAIFunc()
        elseif a == 3 and b == 7 or a == 7 and b == 3 then
            cclog("onContactBetweenBirdAndPipeBegin")
            --bird collides with pipe
            land_1:stopAllActions()
            land_2:stopAllActions()
            removeMovePipeFunc()
            removeBirdTouchHandler(gameLayer)
            removeAIFunc()
        end
        
        
        --spriteBird:getPhysicsBody():setEnable(false)    --can not collide, so disable physicsBody of bird
        --cc.Director:getInstance():getScheduler():unscheduleScriptEntry(movePipeFunc)
    end
    
    --add contactListener
    local contactListener = cc.EventListenerPhysicsContact:create()
    --local contactListener = cc.EventListenerPhysicsContactWithBodies:create(landNode:getPhysicsBody(), spriteBird:getPhysicsBody())
    contactListener:registerScriptHandler(onContactBetweenBirdAndLandBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    gameLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(contactListener, gameLayer)
end