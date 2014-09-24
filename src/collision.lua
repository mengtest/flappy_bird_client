function addCollision(gameLayer, spriteBird, pipes, land_1, land_2)
    --set collision between bird and land
    --set landNode
    local landNode = cc.Node:create()   --由于land1, land2是在移动的，landNode是用来在land对应的区域内设置physicsBody
    local landHeight = 81
    local landWidth = visibleSize.width
    landNode:setPhysicsBody(cc.PhysicsBody:createEdgeSegment(cc.p(0, landHeight), cc.p(landWidth, landHeight)))
    landNode:getPhysicsBody():setEnable(true)
    gameLayer:addChild(landNode)
    --set bitmask and group: bug, will send event but will not contact
    spriteBird:getPhysicsBody():setCategoryBitmask(0x01)
    spriteBird:getPhysicsBody():setContactTestBitmask(0x01)
    spriteBird:getPhysicsBody():setCollisionBitmask(0x01)
    landNode:getPhysicsBody():setCategoryBitmask(0x1)
    landNode:getPhysicsBody():setContactTestBitmask(0x1)
    landNode:getPhysicsBody():setCollisionBitmask(0x1)
    landNode:getPhysicsBody():setGroup(1)
    spriteBird:getPhysicsBody():setGroup(1)
    --contactHandler
    local function onContactBetweenBirdAndLandBegin(event, contact)
        cclog("onContactBetweenBirdAndLandBegin")
        spriteBird:getPhysicsBody():setEnable(false)    --can not collide, so disable physicsBody of bird
    end
    --add contactListener
    local contactListener = cc.EventListenerPhysicsContactWithBodies:create(landNode:getPhysicsBody(), spriteBird:getPhysicsBody())
    contactListener:registerScriptHandler(onContactBetweenBirdAndLandBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    gameLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(contactListener, gameLayer)

    --set collision between bird and pipe
    


end