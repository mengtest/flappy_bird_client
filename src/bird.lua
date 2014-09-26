-- constants
gravity = -600   --重力大小
upSpeed = 250    --点击后上升的高度

-- vars
local spriteBird = nil
local AIFunc = nil

-- create the moving bird
function creatBird() 
    --create bird animate
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --修改随机数种子
    local birdNum = math.random(0,2)
    spriteBird = createAtlasSprite("bird"..birdNum.."_1")
    spriteBird:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height/2)
    local animation = cc.Animation:createWithSpriteFrames({createAtlasFrame("bird"..birdNum.."_0"), createAtlasFrame("bird"..birdNum.."_1"), createAtlasFrame("bird"..birdNum.."_2")},0.1)
    local animate = cc.Animate:create(animation)
    spriteBird:runAction(cc.RepeatForever:create(animate))
    
    --create physicsBody
    spriteBird:setPhysicsBody(cc.PhysicsBody:createCircle(spriteBird:getContentSize().width/2 - 9))    --修正physicalBody的大小

    return spriteBird
end

local listener = nil --监听touch事件，birdTouchHandler()和removeBirdTouchHandler()中会用到

-- handling touch events
function birdTouchHandler(gameLayer)
    --local touchBeginPoint = nil
    local function onTouchBegan(touch, event)
        --local location = touch:getLocation()
        --cclog("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
        spriteBird:getPhysicsBody():setVelocity(cc.p(0, upSpeed))
        return true
    end
    --[[
    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        --cclog("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
        if touchBeginPoint then
            local cx, cy = gameLayer:getPosition()
            gameLayer:setPosition(cx + location.x - touchBeginPoint.x,
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
    --]]
    
    -- 事件监听的方式
    listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    --listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    --listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = gameLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, gameLayer)
end

-- 控制AI开关，switch为"on"则打开，为"off"则关闭
local function switchAI(switch, gameLayer)
    -- AI执行的操作
    local function AI()
        local birdX = spriteBird:getPositionX()
        local birdY = spriteBird:getPositionY()
        require "src/pipe"
        local pipes = getPipes()
        local upPipeY = getUpPipeYPosition()
        local pipeY = nil   --bird需要参考的管子的高度，优先是鸟当前所在的管子，其次是鸟面前的第一根管子
        for index = 1, getPipeCount() do
            if birdX+(spriteBird:getContentSize().width/2-9) >= pipes[index]:getPositionX() - getPipeWidth()/2 and birdX-(spriteBird:getContentSize().width/2-9) <= pipes[index]:getPositionX() + getPipeWidth()/2 then
                pipeY = upPipeY[index]
                break
            end
        end
        if pipeY == nil then
            for index = 1, getPipeCount() do
                local preIndex = index - 1
                if preIndex == 0 then preIndex = getPipeCount() end
                if pipes[index]:getPositionX() >= birdX and pipes[preIndex]:getPositionX() < birdX then
                    pipeY = upPipeY[index]
                    break
                end
            end
        end
        if pipeY == nil then pipeY = upPipeY[1] end    --如果没有满足要求的pipe，则说明所有pipe都在鸟的前面，取第一根pipe
        if birdY-(spriteBird:getContentSize().width/2-9)-6 < pipeY then --鸟的physicsBody的半径是spriteBird:getContentSize().width/2 - 9
            spriteBird:getPhysicsBody():setVelocity(cc.p(0, upSpeed))
        end
    end
    
    -- 判断是打开还是关闭AI
    if switch == "on" then
        -- 关闭触摸事件
        gameLayer:getEventDispatcher():removeEventListener(listener)
        -- 启动AI操作
        AIFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(AI, 0, false)
    elseif switch == "off" then
        -- 打开触摸事件
        gameLayer:getEventDispatcher():removeEventListener(listener)    --如果listener里的触摸事件未关闭则关闭，以免添加了两个触摸事件
        birdTouchHandler(gameLayer) --添加触摸事件
        -- 关闭AI操作
        if AIFunc ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(AIFunc)
        end
    end
end

function birdAIHandler(gameLayer)
    local isAIOn = true
    local AILabel = cc.Label:create()
    AILabel:setString("AI: ON")
    AILabel:setVisible(true)
    local function AILabelClick(sender)
        if isAIOn then
            isAIOn = false
            AILabel:setString("AI: OFF")
            switchAI("off", gameLayer)
        else
            isAIOn = true
            AILabel:setString("AI: ON")
            switchAI("on", gameLayer)
        end
    end
    local AIMenuItem = cc.MenuItemLabel:create(AILabel)
    AIMenuItem:registerScriptTapHandler(AILabelClick)
    AIMenuItem:setPosition(visibleSize.width-30, visibleSize.height-30)
    local AIMenu = cc.Menu:create()
    AIMenu:addChild(AIMenuItem)
    AIMenu:setPosition(0, 0)
    gameLayer:addChild(AIMenu, 30)
    
    switchAI("on", gameLayer)
end

-- remove touch events
function removeBirdTouchHandler(gameLayer)
    gameLayer:getEventDispatcher():removeEventListener(listener)
end

-- get spriteBird
function getSpriteBird()
    return spriteBird
end

function removeAIFunc()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(AIFunc)
end 