-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local REVMOB_IDS =  {
  ["Android"] = "4f56aa6e3dc441000e005a20",
  ["iPhone OS"] = "4fd619388d314b0008000213"
}
local PLACEMENT_IDS = nil

display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local storyboard = require "storyboard"
local widget = require "widget"

-- load first screen
storyboard.gotoScene( "scene1" )

-- Display objects added below will not respond to storyboard transitions
local RevMob = require('revmob')

revmobListener = function (event)
  print("Event: " .. event.type)
  for k,v in pairs(event) do print(tostring(k) .. ': ' .. tostring(v)) end
end

local bannerRevMob = nil
local bannerHidden = nil
local fullscreenRevMob = nil
local fullscreenHidden = nil

local function newButton(label, callback)
  onPress = function(event) print(label) callback() return true end
  return { label = label, defaultFile = "assets/icon1.png", overFile = "assets/icon1-down.png", width = 32, height = 32, onPress = onPress }
end

-- table to setup tabBar buttons
local line1 = {
  newButton("Session", function() RevMob.startSession(REVMOB_IDS) end),
  newButton("Test Success", function() RevMob.setTestingMode(RevMob.TEST_WITH_ADS) end),
  newButton("Test Fail", function() RevMob.setTestingMode(RevMob.TEST_WITHOUT_ADS) end),
  newButton("Disable Test", function() RevMob.setTestingMode(RevMob.TEST_DISABLED) end),
  newButton("Placement", function() PLACEMENT_IDS = { ["Android"] = "5058bc97e658200c00000010", ["iPhone OS"] = "5058bc5f5d9fb60800000001" } end)
}

local line2 = {
  newButton("Banner", function()
    timer.performWithDelay(100, function()
        local params = {
          x = display.contentWidth / 2,
          y = display.contentHeight - 20,
          width = 300,
          height = 40,
          listener = revmobListener
        }
        bannerRevMob = RevMob.createBanner(params, PLACEMENT_IDS)
        bannerHidden = false
    end)
  end),

  newButton("Load", function()
    timer.performWithDelay(100, function()
      local params = {
        x = display.contentWidth / 2,
        y = display.contentHeight - 20,
        width = 300,
        height = 40,
        listener = revmobListener,
        autoshow = false
      }
      bannerRevMob = RevMobBanner.new(params)
      bannerRevMob:load()
      bannerHidden = true
    end)
  end),

  newButton("Hide/Show", function()
    timer.performWithDelay(100, function()
        if bannerRevMob then
          if bannerHidden then
            bannerRevMob:show()
            bannerHidden = false
          else
            bannerRevMob:hide()
            bannerHidden = true
          end
        end
      end)
  end),

  newButton("Change", function()
    timer.performWithDelay(100, function()
        if bannerRevMob then
          bannerRevMob:setPosition(bannerRevMob.x + 1, bannerRevMob.y + 1)
          bannerRevMob:setDimension(bannerRevMob.width - 1, bannerRevMob.height - 1)
        end
      end)
  end),

  newButton("Release", function()
    timer.performWithDelay(100, function()
        if bannerRevMob then
          bannerRevMob:release()
        end
      end)
  end)
}

local line3 = {
  newButton("Fullscreen", function()
    timer.performWithDelay(100, function()
      fullscreenRevMob = RevMob.showFullscreen(revmobListener, PLACEMENT_IDS)
      fullscreenHidden = false
    end)
  end),

  newButton("Load", function()
    timer.performWithDelay(100, function()
      fullscreenRevMob = RevMobFullscreen.new({listener = revmobListener, autoshow = false})
      fullscreenRevMob:load()
      fullscreenHidden = true
    end)
  end),

  newButton("Hide/Show", function()
    timer.performWithDelay(100, function()
      if fullscreenRevMob then
        if fullscreenHidden then
          print("Show activated")
          fullscreenRevMob:show()
          fullscreenHidden = false
        else
          print("Hide activated")
          fullscreenRevMob:hide()
          fullscreenHidden = true
        end
      end
    end)
  end)
}

local line4 = {
  newButton("Popup", function() RevMob.showPopup(revmobListener, PLACEMENT_IDS) end),
  newButton("Link", function() RevMob.openAdLink(revmobListener, PLACEMENT_IDS) end)
}

local line5 = {
  newButton("Print env", function() RevMob.printEnvironmentInformation(REVMOB_IDS) end),

  newButton("Change Scene", function()
    RevMob.startSession(REVMOB_IDS)
    storyboard.gotoScene("scene2", "fade", 400)
    RevMob.showFullscreen(revmobListener)
    storyboard.gotoScene("scene3", "fromLeft", 400)
    RevMob.createBanner()
    storyboard.gotoScene("scene4", "fromRight", 400)
  end),

  newButton("Purge scene", function()
    storyboard.purgeScene(storyboard.getCurrentSceneName())
    storyboard.removeScene(storyboard.getCurrentSceneName())
  end),

  newButton("Close", function() os.exit() end)
}

widget.newTabBar{ top = 0, buttons = line1 }
widget.newTabBar{ top = 50, buttons = line2 }
widget.newTabBar{ top = 100, buttons = line3 }
widget.newTabBar{ top = 150, buttons = line4 }
widget.newTabBar{ top = 200, buttons = line5 }
