require "src/socket"
require "src/json"
require "src/mime"

--constants
TIMEOUT = -1
CLOSED = -2
EMPTY = -3    --means read empty data

-- return: 1-success TIMEOUT-timeout CLOSED-closed EMPTY-empty
function send(sock, table)  -- take table as argument!!
    local state, error, index = sock:send(pack(table))
    if state == nil then
        if error == "timeout" then return TIMETOUT
        elseif error == "closed" then return CLOSED end
    else
        return 1
    end
end

-- return: table-success TIMEOUT-timeout CLOSED-closed EMPTY-empty
function read(sock)
    --读取三位的报文头
    sock:settimeout(0)
    local data, error = sock:receive(3)
    if data == nil then
        if error == "timeout" then
            return TIMEOUT
        elseif error == "closed" then
            return CLOSED
        end
    end
    local len = tonumber(data)
    if len == 0 then return EMPTY end
    --读取数据
    data,error = sock:receive(len)
    if data == nil then
        if error == "timeout" then
            return TIMEOUT
        elseif error == "closed" then
            return CLOSED
        end
    end
    --解析数据
    return unpack(data)
end

-- 把table 先用json编码 再用base64加密 最后加上长度信息
-- 输入table
-- 输出string
function pack(table)    --take table as argument!!
    --转换成json
    local jsonData = json.encode(table)
    --base64加密
    jsonData = mime.b64(jsonData)
    --加上头部长度信息
    local len = string.len(jsonData)
    local str = nil
    if len < 10 and len > 0 then
        str = "00"..tostring(len)..jsonData
    elseif len < 100 then
        str = "0"..tostring(len)..jsonData
    elseif len < 1000 then
        str = tostring(len)..jsonData
    else
        str = "000"
    end
    return str
end

-- 把string 先用base64解密 再用json解码
-- 输入string
-- 输出table（使用.访问元素，而非[]）
function unpack(str)    --return table(使用.而不是[])
    --base64解密
    local jsonData = mime.unb64(str)
    --json解析
    local table = json.decode(jsonData)
    return table
end