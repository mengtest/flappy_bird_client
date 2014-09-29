require "src/socket"
require "src/network.netstream"
require "src/bird"

-- vars accessed by other files
isNetBattle = true      -- true: 网战， false：单机
pipeRandomHeight = {}   -- 网战时，根据该table中的数据来设置pipe高度
isNetBattleStart = false    -- 标识网战是否开始
netBattleInterval = 50  -- 网战时，相邻的鸟之间的距离（对应的client上的pipe位置也会变化
netBattleOrder = -1     -- 网战时，玩家被安排的序号（0或者1）
battleSize = -1         -- 网战时，记录对战人数
otherBird = {}          -- 网战时，存储其他玩家bird精灵
isNetBattleOver = false     -- 标识网战是否结束

-- local vars
local sock = nil    -- 连接到服务器的套接字

function connect()
    -- connect server
    local host = "127.0.0.1"
    local port = 1234
    sock = socket.connect(host, port)
    
    -- 始终接收服务端消息
    function receiveServer()
        local data = read(sock)
        if data == TIMEOUT or data == CLOSED or data == EMPTY then return end
        -- 处理接收到的消息
        -- 处理pipe信息
        if data['pipe'] ~= nil then
            for key, value in pairs(data['pipe']) do
                pipeRandomHeight[tonumber(key)] = value
            end
        end
        -- 处理其他鸟的位置信息
        if data['pos'] ~= nil then
            -- 如果网战结束，则不需要更新其他鸟位置
            if not isNetBattleOver then
                otherBird[data['no']]:getPhysicsBody():setVelocity(cc.p(0, upSpeed))
            end
        end
        -- 处理游戏开始信息，必须最后处理！
        if data['start'] ~= nil then
            netBattleOrder = data['no']
            battleSize = data['size']
            isNetBattleStart = true
        end
    end
    receiveServerFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(receiveServer, 0, false)
end

-- 向server请求pipe位置信息
function requestPipeRandomHeight(index)
    local table = {}
    table['pipe'] = index
    send(sock, table)
end

-- 向server通知自己的纵坐标（每次小鸟向上跳时通知）
function notifyPosition(pos)
    local table = {}
    table['no'] = netBattleOrder
    table['pos'] = pos
    send(sock, table)
end

-- 游戏开始时调用该函数来创建其他鸟的精灵、设置位置、设置刚体、设置碰撞
function initOtherBird(gameLayer)
    -- 用来创建其他鸟
    local function createOtherBird()
        cc.FileUtils:getInstance():addSearchPath("res")
        local sprite = cc.Sprite:create("otherBird.png", cc.rect(0, 0, 48, 48))
        sprite:setPhysicsBody(cc.PhysicsBody:createCircle(sprite:getContentSize().width/2 - 9))
        sprite:getPhysicsBody():setCategoryBitmask(15)
        sprite:getPhysicsBody():setContactTestBitmask(0)
        sprite:getPhysicsBody():setCollisionBitmask(0)
        return sprite
    end
    for i = 0, battleSize-1 do
        if i ~= netBattleOrder then
            otherBird[i] = createOtherBird()
            -- 设置其他鸟的位置
            --otherBird[i]:setPosition(visibleSize.width/2 + (netBattleOrder - i) * netBattleInterval, visibleSize.height/2)
            otherBird[i]:setPosition(visibleSize.width/2 - i * netBattleInterval, visibleSize.height/2)
            gameLayer:addChild(otherBird[i])
        end
        -- 设置自己鸟的位置
        getSpriteBird():setPosition((visibleSize.width/2) - netBattleOrder * netBattleInterval, visibleSize.height/2)
    end
end

function printTable(table)
    local str = ''
    return _printTable(table, str, 0)
end

function _printTable(table, str, indent)
    if (type(table) ~= 'table') then str=str..table..'\n' return str end
    for key, value in pairs(table) do
        for i = 1,indent do str=str..'\t' end
        str=str..key..": "
        str = _printTable(value, str, indent+1)
    end
    return str
end

--[[
function try_send_read()
    -- connect server
    local host = "127.0.0.1"
    local port = 1234
    local sock = socket.connect(host, port)
    local table = read(sock)
    print("read data: "..printTable(table))
    local table2 = {}
    table2['login'] = 'chenchao'
    table2['wife'] = 'gongyilin'
    --table2['hobby'] = '看动画，听音乐，打篮球，玩游戏，哈哈哈'
    table2['pipe'] = {['index']=15, ['random']=3}
    table2['bird'] = {['1']=111, ['2']=222, ['3']=333}
    send(sock, table2)
    print("send data"..printTable(table2))
    print("end")
    sock:close()
end
]]