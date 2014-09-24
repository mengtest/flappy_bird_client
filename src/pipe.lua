require "src/atlas"

-- constants
local pipeCount = 2
local pipeHeight = 320
local pipeWidth = 52
local pipeDistance = 100
local pipeInterval = 180
local waitDistance = 100
-- vars
local PIPE_NEW = 0
local PIPE_PASS = 1
local pipes = {}    --contains nodes of pipes
local pipeState = {}    --PIPE_NEW or PIPE_PASS
--local pipeXPosition = {}    --the x position of pipes
local downPipeYPosition = {}    --朝下pipe的最下侧的y坐标
local upPipeYPosition = {}  --朝上pipe的最上侧的y坐标

function createPipes(layer)
    local function initPipe()
        for i = 1, pipeCount do
            local downPipe = createAtlasSprite("pipe_down")   --朝下的pipe而非在下方的pipe
            local upPipe = createAtlasSprite("pipe_up")       --朝上的pipe而非在上方的pipe

            downPipe:setPosition(0, pipeHeight + pipeDistance)

            local singlePipe = cc.Node:create()
            singlePipe:addChild(downPipe)
            singlePipe:addChild(upPipe)
            --管道高度？
            local height_random = math.random(0,3)
            singlePipe:setPosition(origin.x + visibleSize.width + (i-1)*pipeInterval + waitDistance, height_random * 50)
            layer:addChild(singlePipe, 10)
            pipes[i] = singlePipe
            pipeState[i] = PIPE_NEW
            upPipeYPosition[i] = height_random*50 + pipeHeight/2
            downPipeYPosition[i] = height_random*50 + pipeHeight/2 + pipeDistance
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
                pipeNode:setPosition(pipes[next]:getPositionX() + pipeInterval, 50 * randomHeight)
                --pipeNode:setTag(randomHeight)
                break
            end
        end
    end
    
    local function calScore()
        local birdXPosition = spriteBird:getPositionX()
        for i = 1, pipeCount do
            if pipeState[i] == PIPE_NEW and pipes[i]:getPositionX() < birdXPosition then
                pipeState[i] = PIPE_PASS
                score = score + 1
                print("score is "..score)
            end
        end
    end
    
    initPipe()
    movePipeFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(movePipe, 0, false)
    calScoreFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(calScore, 0, false)
    return pipes
end