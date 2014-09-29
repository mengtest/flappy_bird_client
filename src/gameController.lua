require "src/pipe"
require "src/collision"
require "src/atlas"

--vars
local gameLayer
local gameScene
local spriteBird
local land_1
local land_2
local startLayer
local pipes
score = 0

function gameStart(_gameScene)
    -- 给gameScene赋值
    gameScene = _gameScene
    
    -- gameLayer: 游戏场景所在的layer
    gameLayer = cc.Layer:create()
    -- add background
    local bg = createAtlasSprite("bg_day")
    bg:setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2)
    gameLayer:addChild(bg, 0)
    -- add moving bird
    spriteBird = creatBird()
    spriteBird:getPhysicsBody():setEnable(false)
    gameLayer:addChild(spriteBird, 20)
    -- add moving land
    land_1, land_2 = createLand()
    gameLayer:addChild(land_1, 10)
    gameLayer:addChild(land_2, 10)
    -- add gameLayer to gameScene
    gameScene:addChild(gameLayer)
    
    -- 控制游戏是否开始
    if (not isNetBattle) then   --非联机时开始游戏
        -- start button
        local startButtonSprite = createAtlasSprite("button_play")
        local startMenuItem = cc.MenuItemSprite:create(startButtonSprite, startButtonSprite, startButtonSprite)
        local startMenu = cc.Menu:create()
        startMenu:addChild(startMenuItem)
        startMenu:setPosition(visibleSize.width/2, visibleSize.height/4)
        local startLayer = cc.Layer:create()
        startLayer:addChild(startMenu)
        gameScene:addChild(startLayer, 10)  --显示在startLayer前
        -- start button的回调函数
        local function gameStart()                    
            spriteBird:getPhysicsBody():setEnable(true)
            -- handling bird touch events
            birdTouchHandler(gameLayer)
            -- handling bird AI
            birdAIHandler(gameLayer)
            -- add moving pipes
            score = 0   --分数，飞过一个管子得到一分
            pipes = createPipes(gameLayer)
            -- add collision detect
            addCollision(gameLayer, spriteBird, pipes, land_1, land_2)
            -- remove startLayer
            gameScene:removeChild(startLayer)
        end
        startMenuItem:registerScriptTapHandler(gameStart)
    else    -- 联机时开始游戏
        local function netBattleStart()
            if isNetBattleStart then
                initOtherBird(gameLayer) -- 初始化其他bird
                spriteBird:getPhysicsBody():setEnable(true)
                -- handling bird touch events
                birdTouchHandler(gameLayer)
                -- handling bird AI
                birdAIHandler(gameLayer)
                -- add moving pipes
                score = 0   --分数，飞过一个管子得到一分
                pipes = createPipes(gameLayer)
                -- add collision detect
                addCollision(gameLayer, spriteBird, pipes, land_1, land_2)
                -- remove netBattleStartFunc
                if netBattleStartFunc ~= nil then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(netBattleStartFunc)
                end
            end
        end
        netBattleStartFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(netBattleStart, 0, false)
    end
end