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
local pipes = {}
local pipeState = {}

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
            singlePipe:setPosition(origin.x + visibleSize.width + (i-1)*pipeInterval + waitDistance, math.random(0,3) * 50)
            layer:addChild(singlePipe, 10)

            pipes[i] = singlePipe
            pipeState[i] = PIPE_PASS            
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

    initPipe()
    createPipeFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(movePipe, 0, false)
    
    return pipes
end