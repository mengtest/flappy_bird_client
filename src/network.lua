require "src/socket"
require "src/json"
require "src/mime"

function connect()
    -- connect server
    local host = "127.0.0.1"
    local port = 1234
    local sock = socket.connect(host, port)
    sock.receive(1)
    -- recv data
    local function recvData()
        data, error = sock.receive(3)
    end
end

function read(sock)
    --读取三位的报文头
    sock.settimeout(0)
    local data, error = sock.recv(3)
    if data == nil then
        
    end
    
end

function pack(table)
    --转换成json
    local jsonData = json.encode(table)
    --base64加密
    jsonData = mime.b64(str)
    --加上头部长度信息
    local len = string.len(jsonData)
    local str = nil
    if len < 10 then
        local str = "00"..tostring(len)..jsonData
    elseif len < 100 then
        local str = "0"..tostring(len)..jsonData
    elseif len < 1000 then
        local str = tostring(len)..jsonData
    else
        str = "000"
    end
    print(str)
    return str
end

function unpack(str)
    --base64解密
    local jsonData = mime.unb64(str)
    --json解析
    local table = json.decode(jsonData)
    return table
end

function tryBase64()
    local str = "woshiyigeren我是一个人"
    local str2 = mime.b64(str)
    print(str2)
    local str3 = mime.unb64(str2)
    print(str3)
end