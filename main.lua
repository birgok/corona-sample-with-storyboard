-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

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
local tabButtons = {
	{
	  label = "Session", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
	  onPress = function(event)
        local ids =  {
          ["Android"] = "4f56aa6e3dc441000e005a20",
          ["iPhone OS"] = "4fd619388d314b0008000213"
        }
        RevMob.startSession(ids)
        return true
	  end
	},
  
    {
      label="Fullscreen", up="icon1.png", down="icon1-down.png", width = 32, height = 32,
      onPress = function(event)
        timer.performWithDelay(100, function()
          RevMob.showFullscreen(revmobListener)
        end)
        return true
      end
	},
	
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
          local banner = RevMob.createBanner(params)
        end)
        return true
      end
	},

	{
	  label = "Pop up", up = "icon1.png", down = "icon1-down.png", width = 32, height = 32,
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

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
 top = 0, -- 50 is default height for tabBar widget
 buttons = tabButtons
}