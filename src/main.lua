require "Cocos2d"
require "Cocos2dConstants"
require "src/atlas"
require "src/bird"
require "src/pipe"
require "src/land"
require "src/collision"
require "src/network.network"
require "src/gameController"

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- initialize director
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLView:createWithRect("HelloLua", cc.rect(0,0,900,600))
        director:setOpenGLView(glview)
    end

    glview:setDesignResolutionSize(288, 512, cc.ResolutionPolicy.NO_BORDER)

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

	cc.FileUtils:getInstance():addSearchPath("src")
	cc.FileUtils:getInstance():addSearchPath("res")
	local schedulerID = 0
    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or 
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        --cclog("result is ")
		--require('debugger')()
        
    end
    -- 调用其他文件中的函数
    --[[
    require "hello2"
    cclog("result is " .. myadd(1, 1))
    --]]

    ---------------
    --get resolution and coordinate
    visibleSize = cc.Director:getInstance():getVisibleSize()
    origin = cc.Director:getInstance():getVisibleOrigin()

    ---------------

    --[[
    -- create menu
    local function createMenuLayer()
        local menuLayer = cc.Layer:create()

        local menuPopup, menuTools, effectID

        local function menuCallbackClosePopup()
            -- stop test sound effect
            cc.SimpleAudioEngine:getInstance():stopEffect(effectID)
            menuPopup:setVisible(false)
        end

        local function menuCallbackOpenPopup()
            -- loop test sound effect
            local effectPath = cc.FileUtils:getInstance():fullPathForFilename("effect1.wav")
            effectID = cc.SimpleAudioEngine:getInstance():playEffect(effectPath)
            menuPopup:setVisible(true)
        end
        
        -- add a popup menu
        local menuPopupItem = cc.MenuItemImage:create("menu2.png", "menu2.png")
        menuPopupItem:setPosition(0, 0)
        menuPopupItem:registerScriptTapHandler(menuCallbackClosePopup)
        menuPopup = cc.Menu:create(menuPopupItem)
        menuPopup:setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2)
        menuPopup:setVisible(false)
        menuLayer:addChild(menuPopup)
        
        -- add the left-bottom "tools" menu to invoke menuPopup
        local menuToolsItem = cc.MenuItemImage:create("menu1.png", "menu1.png")
        menuToolsItem:setPosition(0, 0)
        menuToolsItem:registerScriptTapHandler(menuCallbackOpenPopup)
        menuTools = cc.Menu:create(menuToolsItem)
        local itemWidth = menuToolsItem:getContentSize().width
        local itemHeight = menuToolsItem:getContentSize().height
        menuTools:setPosition(origin.x + itemWidth/2, origin.y + itemHeight/2)
        menuLayer:addChild(menuTools)

        return menuLayer
    end
    ]]
    
    --[[
    -- play background music, preload effect
    local bgMusicPath = cc.FileUtils:getInstance():fullPathForFilename("background.mp3") 
    cc.SimpleAudioEngine:getInstance():playMusic(bgMusicPath, true)
    local effectPath = cc.FileUtils:getInstance():fullPathForFilename("effect1.wav")
    cc.SimpleAudioEngine:getInstance():preloadEffect(effectPath)
    ]]

    -- run
    local gameScene = cc.Scene:createWithPhysics()
    -- create physicsWorld
    gameScene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    gameScene:getPhysicsWorld():setGravity(cc.p(0, gravity))    --gravity is defined in bird.lua
    -- connect server if needed
    if (isNetBattle) then connect() end
    -- gameStart() in gameController
    gameStart(gameScene)
	
	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(gameScene)
	else
		cc.Director:getInstance():runWithScene(gameScene)
	end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
