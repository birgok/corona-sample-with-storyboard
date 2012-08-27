-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local ids =  {
  ["Android"] = "4f56aa6e3dc441000e005a20",
  ["iPhone OS"] = "4fd619388d314b0008000213"
}

display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local storyboard = require "storyboard"
local widget = require "widget"

-- load first screen
storyboard.gotoScene( "scene1" )

-- Display objects added below will not respond to storyboard transitions
require 'revmob'

revmobListener = function (event)
  print("Event: " .. event.type)
end

-- table to setup tabBar buttons
local line1 = {
	{
	  label = "Session", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
	  onPress = function(event)
        RevMob.startSession(ids)
        return true
	  end
	},
  
	{
	  label = "Popup", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
	  onPress = function(event)
      RevMob.showPopup(revmobListener)
      return true
	  end
	},
	
	{
	  label = "Link", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
	  onPress = function(event)
      RevMob.openAdLink()
      return true
	  end
	},
}

local line2 = {
	{
      label="Banner", up="icon1.png", down="icon1-down.png", width = 32, height = 32,
      onPress = function(event)
        timer.performWithDelay(100, function()
          local params = {
            x = display.contentWidth / 2,
            y = display.contentHeight - 20,
            width = 300,
            height = 40,
            adListener = revmobListener
          }
          bannerRevMob = RevMob.createBanner(params)
        end)
        return true
      end
	},
	
	{
      label="Hide Banner", up="icon1.png", down="icon1-down.png", width = 32, height = 32,
      onPress = function(event)
        timer.performWithDelay(100, function()
          if bannerRevMob then
            bannerRevMob:hide()
          end
        end)
        return true
      end
	},
	
	{
      label="Release Banner", up="icon1.png", down="icon1-down.png", width = 32, height = 32,
      onPress = function(event)
        timer.performWithDelay(100, function()
          if bannerRevMob then
            bannerRevMob:release()
          end
        end)
        return true
      end
	},

}

local line3 = {
    {
      label="Random Fullscreen", up="icon1.png", down="icon1-down.png", width = 32, height = 32,
      onPress = function(event)
        timer.performWithDelay(100, function()
          RevMob.showFullscreen(revmobListener)
        end)
        return true
      end
	},
	
    {
      label="Fullscreen Web", up="icon1.png", down="icon1-down.png", width = 32, height = 32,
      onPress = function(event)
        timer.performWithDelay(100, function()
          RevMob.showFullscreenWeb({})
        end)
        return true
      end
	},
	
    {
      label="Fullscreen Image", up="icon1.png", down="icon1-down.png", width = 32, height = 32,
      onPress = function(event)
        timer.performWithDelay(100, function()
          RevMob.showFullscreenImage(revmobListener)
        end)
        return true
      end
	},

}

local line4 = {
	{
	  label = "Print env", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
	  onPress = function(event)
        RevMob.printEnvironmentInformation(ids)
        RevMob.printEnvironmentInformation()
        return true
	  end
	},
	{
	  label = "Change Scene (Test)", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
	  onPress = function(event)
        RevMob.startSession(ids)
        storyboard.gotoScene("scene2", "fade", 400)
        RevMob.showFullscreen(revmobListener)
        storyboard.gotoScene("scene3", "fromLeft", 400)
        RevMob.createBanner()
        storyboard.gotoScene("scene4", "fromRight", 400)
        return true
	  end
	},
	{
	  label = "Purge current scene", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
	  onPress = function(event)
        storyboard.purgeScene(storyboard.getCurrentSceneName())
        storyboard.removeScene(storyboard.getCurrentSceneName())
        return true
	  end
	}
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
 top = 0, -- 50 is default height for tabBar widget
 buttons = line1
}
	
local tabBar2 = widget.newTabBar{
 top = 50, -- 50 is default height for tabBar widget
 buttons = line2
}

local tabBar2 = widget.newTabBar{
 top = 100, -- 50 is default height for tabBar widget
 buttons = line3
}

local tabBar2 = widget.newTabBar{
 top = 150, -- 50 is default height for tabBar widget
 buttons = line4
}
