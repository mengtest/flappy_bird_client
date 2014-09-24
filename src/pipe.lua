require "src/atlas"
require "src/bird"  --import the function getSpriteBird()

-- constants
local pipeCount = 2
local pipeHeight = 320
local pipeWidth = 52
local pipeDistance = 100    --上下管道间的距离
local pipeInterval = 180    --两根管道的水平距离
local waitDistance = 100    --开始时第一根管道距离屏幕最右侧的距离
local heightOffset = 30 --singlePipe:setPosition(XXX, height_random * heightOffset)
-- vars
local PIPE_NEW = 0
local PIPE_PASS = 1
local pipes = {}    --contains nodes of pipes
local pipeState = {}    --PIPE_NEW or PIPE_PASS
--local pipeXPosition = {}    --the x position of pipes
local downPipeYPosition = {}    --朝下pipe的最下侧的y坐标
local upPipeYPosition = {}  --朝上pipe的最上侧的y坐标
local movePipeFunc = nil
local calScoreFunc = nil

function createPipes(layer)
    local function initPipe()
        for i = 1, pipeCount do
            --把downPipe和upPipe组合为singlePipe
            local downPipe = createAtlasSprite("pipe_down")   --朝下的pipe而非在下方的pipe
            local upPipe = createAtlasSprite("pipe_up")       --朝上的pipe而非在上方的pipe
            downPipe:setPosition(0, pipeHeight + pipeDistance)
            local singlePipe = cc.Node:create()
            singlePipe:addChild(downPipe)
            singlePipe:addChild(upPipe)
            
            --设置刚体
            --upPipe的刚体
            --由于bitmask失效所以无法控制朝上Pipe刚体和地面刚体的碰撞。。。所以朝上pipe刚体要避开地面刚体
            local upPipeNode = cc.Node:create() --朝上pipe的刚体
            upPipeNode:setPhysicsBody(cc.PhysicsBody:createBox({height = pipeHeight, width = pipeWidth}))
            upPipeNode:getPhysicsBody():setGravityEnable(false) --not influenced by gravity
            singlePipe:addChild(upPipeNode)
            --设置bitmask，不会碰撞，但会发送事件
            upPipeNode:getPhysicsBody():setCategoryBitmask(7)
            upPipeNode:getPhysicsBody():setCollisionBitmask(0)
            upPipeNode:getPhysicsBody():setContactTestBitmask(1)
            --downPipe的刚体
            local downPipeNode = cc.Node:create()   --朝下pipe的刚体
            downPipeNode:setPhysicsBody(cc.PhysicsBody:createBox({height = pipeHeight, width = pipeWidth}))
            downPipeNode:getPhysicsBody():setGravityEnable(false) --not influenced by gravity
            downPipeNode:setPosition(0, pipeHeight + pipeDistance)
            singlePipe:addChild(downPipeNode)
            --设置bitmask，不会碰撞，但会发送事件
            downPipeNode:getPhysicsBody():setCategoryBitmask(7)
            downPipeNode:getPhysicsBody():setCollisionBitmask(0)
            downPipeNode:getPhysicsBody():setContactTestBitmask(1)
            
            --设置管道高度和位置
            local height_random = math.random(0,3)
            singlePipe:setPosition(origin.x + visibleSize.width + (i-1)*pipeInterval + waitDistance, height_random * heightOffset)
            layer:addChild(singlePipe, 10)
            pipes[i] = singlePipe
            pipeState[i] = PIPE_NEW
            upPipeYPosition[i] = height_random*heightOffset + pipeHeight/2
            downPipeYPosition[i] = height_random*heightOffset + pipeHeight/2 + pipeDistance
        end

    end

    local function movePipe()
        local moveDistance = visibleSize.width/(2*60)   -- 移动速度和land一致
        for i = 1, pipeCount do
            pipes[i]:setPositionX(pipes[i]:getPositionX()-moveDistance)
            if pipes[i]:getPositionX() < -pipeWidth/2 then
                local pipeNode = pipes[i]
                pipeState[i] = PIPE_NEW
                local randomHeight = math.random(0,3)
                local next = i-1
                if next < 1 then next = pipeCount end
                pipeNode:setPosition(pipes[next]:getPositionX() + pipeInterval, heightOffset * randomHeight)
                --pipeNode:setTag(randomHeight)
                break
            end
        end
    end
    
    local function calScore()
        local birdXPosition = getSpriteBird():getPositionX()
        for i = 1, pipeCount do
            if pipeState[i] == PIPE_NEW and pipes[i]:getPositionX() < birdXPosition then
                pipeState[i] = PIPE_PASS
                score = score + 1
                --print("score is "..score)
            end
        end
    end
    
    initPipe()
    movePipeFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(movePipe, 0, false)
    calScoreFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(calScore, 0, false)
    return pipes
end

function removeMovePipeFunc()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(movePipeFunc)
end
function removeCalScoreFunc()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(calScoreFunc)
end