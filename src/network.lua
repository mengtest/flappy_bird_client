require "src/socket"

function tryNetwork()
    local host = "127.0.0.1"
    local port = 1234
    local sock = socket.connect(host, port)
    local str = sock:receive(1)
    print(str)
    sock:close()
end