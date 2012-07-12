-- RevMob Corona SDK for Android and iOS
--
-- Usage:
--
--  * Include the library in your project:
--       require "revmob"
--
--  * To show a fullscreen ad:
--       RevMob.showFullscreen({ ["Android"] = "Android App Id", ["iPhone OS"] = "IPhone OS App Id" })
--
--  * To show a pop-up ad:
--       RevMob.showPopup({ ["Android"] = "Android App Id", ["iPhone OS"] = "IPhone OS App Id" })
--
-- "your app id" is the one you got at http://www.revmob.com for your application.
--

local json = require('json')
require('revmob_client')

Popup = {
  DELAYED_LOAD_IMAGE = 10,
  YES_BUTTON_POSITION = 2,
  message = nil,
  click_url = nil,

  show = function(applicationId)
    client = Client:new("pop_ups", applicationId)
    client:fetch(Popup.networkListener)
  end,

  networkListener = function(event)
    local status, json = pcall(json.decode, event.response)
    if Popup.isParseOk(status, json) then
      Popup.message = json["pop_up"]["message"]
      Popup.click_url = json["pop_up"]["links"][1]["href"]
      timer.performWithDelay(Popup.DELAYED_LOAD_IMAGE, function()
        local alert = native.showAlert(Popup.message, "", { "No, thanks.", "Yes, Sure!" }, Popup.click)
      end)
    end
  end,

  isParseOk = function(status, json)
    -- For some reason, short-circuiting did not work, otherwise this could be
    -- a single statement using "and"
    if (not status) then
      return false
    elseif (json == nil) then
      return false
    elseif (json["pop_up"] == nil) then
      return false
    elseif (json["pop_up"]["message"] == nil) then
      return false
    elseif (json["pop_up"]["links"] == nil) then
      return false
    elseif (json["pop_up"]["links"][1] == nil) then
      return false
    elseif (json["pop_up"]["links"][1]["href"] == nil) then
      return false
    end
    return true
  end,

  click = function( event )
    if "clicked" == event.action then
      if Popup.YES_BUTTON_POSITION == event.index then
        system.openURL(Popup.click_url)
      end
    end
  end
}

local getLink = function(rel, links)
  for i,v in ipairs(links) do
    if v.rel == rel then
      return v.href
    end
  end
  return nil
end

local Screen =
{
	left = display.screenOriginX,
	top = display.screenOriginY,
	right = display.contentWidth - display.screenOriginX,
	bottom = display.contentHeight - display.screenOriginY,
	scaleX = display.contentScaleX,
	scaleY = display.contentScaleY,

	width = function(self)
	  return self.right - self.left
  end,

  height = function(self)
    return self.bottom - self.top
  end,
}

-- print("left: " .. tostring(Screen.left))
-- print("top: " .. tostring(Screen.top))
-- print("right: " .. tostring(Screen.right))
-- print("bottom: " .. tostring(Screen.bottom))
-- print("scaleX: " .. tostring(Screen.scaleX))

Fullscreen = {
  CLOSE_BUTTON_X = Device:isIPad() and Screen.right - (50 * Screen.scaleX) or Screen.right - (30 * Screen.scaleY),
  CLOSE_BUTTON_Y = Device:isIPad() and Screen.top + (80 * Screen.scaleX) or Screen.top + (30 * Screen.scaleY),
  CLOSE_BUTTON_WIDTH = Device:isIPad() and  80 * Screen.scaleX or 50 * Screen.scaleY,

  ASSETS_PATH = 'revmob-assets/fullscreen/',
  LOCALIZED_MSG = {
    ar = "Arabic.jpg",
    bg = "Bulgarian.jpg",
    cs = "Czech.jpg",
    da = "Danish.jpg",
    de = "German.jpg",
    el = "Greek.jpg",
    en = "English.jpg",
    es = "Spanish.jpg",
    fi = "Finnish.jpg",
    fr = "French.jpg",
    hr = "Croatian.jpg",
    hu = "Hungarian.jpg",
    id = "Indonesian.jpg",
    is = "Icelandic.jpg",
    it = "Italian.jpg",
    ja = "Japanese.jpg",
    ko = "Korean.jpg",
    nb = "Norwegian.jpg",
    pl = "Polish.jpg",
    pt = "Portuguese.jpg",
    ro = "Romanian.jpg",
    ru = "Russian.jpg",
    sv = "Swedish.jpg",
    tr = "Turkish.jpg",
    uk = "Ukrainian.jpg",
    zh = "Chinese.jpg"
  },
  DELAY = 200,

  getLocalizedMessagePath = function(language)
    return Fullscreen.ASSETS_PATH .. (Fullscreen.LOCALIZED_MSG[language] or Fullscreen.LOCALIZED_MSG["en"])
  end,

  language = system.getPreference("locale", "language"),
  adClicked = false,
  clickUrl = nil,
  screenGroup = nil,

  networkListener = function(event)
    local status, jsonResponse = pcall(json.decode, event.response)
    if (not status or jsonResponse == nil) then
      log("Ad not received.")
      return
    end
    log("Ad received.")
    local links = jsonResponse['fullscreen']['links']
    Fullscreen.clickUrl = getLink('clicks', links)
    Fullscreen.create()
  end,

  release = function(event)
    Runtime:removeEventListener("enterFrame", Fullscreen.update)
    Runtime:removeEventListener("system", Fullscreen.onApplicationResume)
    pcall(Fullscreen.localizedImage.removeEventListener, Fullscreen.localizedImage, "touch", Fullscreen.localizedImage)
    pcall(Fullscreen.closeButton.removeEventListener, Fullscreen.closeButton, "touch", Fullscreen.closeButton)
    if Fullscreen.screenGroup then
      Fullscreen.screenGroup:removeSelf()
      Fullscreen.screenGroup = nil
    end
    Fullscreen.adClicked = false
    log("Fullscreen Released.")
    return true
  end,

  back = function()
    timer.performWithDelay(Fullscreen.DELAY, Fullscreen.release)
    return true
  end,

  adClick = function()
    if not Fullscreen.adClicked then
      Fullscreen.adClicked = true
      system.openURL(Fullscreen.clickUrl)
      Fullscreen.back()
    end
    return true
  end,

  update = function(event)
    if (Fullscreen.screenGroup) then
      Fullscreen.screenGroup:toFront()
    end
  end,

  show = function(applicationId)
    local client = Client:new("fullscreens", applicationId)
    client:fetch(Fullscreen.networkListener)
  end,

  create = function()
    Fullscreen.screenGroup = display.newGroup()

    Fullscreen.localizedImage = display.newImageRect(Fullscreen.getLocalizedMessagePath(Fullscreen.language),
                                                     Screen:width(), Screen:height())
    Fullscreen.localizedImage.x = display.contentWidth / 2
    Fullscreen.localizedImage.y = display.contentHeight / 2
    Fullscreen.localizedImage.touch = function(self, e)
      Fullscreen.adClick()
      return true
    end

    local closeButtonImagePath = Fullscreen.ASSETS_PATH .. 'close_button.png'
    Fullscreen.closeButton = display.newImageRect(closeButtonImagePath,
                                                  Fullscreen.CLOSE_BUTTON_WIDTH, Fullscreen.CLOSE_BUTTON_WIDTH)
    Fullscreen.closeButton.x = Fullscreen.CLOSE_BUTTON_X
    Fullscreen.closeButton.y = Fullscreen.CLOSE_BUTTON_Y
    Fullscreen.closeButton.touch = function(self, event)
      Fullscreen.back()
      return true
    end

    Fullscreen.localizedImage:addEventListener("touch", Fullscreen.localizedImage)
    Fullscreen.closeButton:addEventListener("touch", Fullscreen.closeButton)
    Runtime:addEventListener( "enterFrame", Fullscreen.update )
    Runtime:addEventListener("system", Fullscreen.onApplicationResume)

    Fullscreen.screenGroup:insert( Fullscreen.localizedImage )
    Fullscreen.screenGroup:insert( Fullscreen.closeButton )
  end,

  onApplicationResume = function(event)
    if event.type == "applicationResume" then
      log("Application resumed.")
      Fullscreen.release()
    end
  end,
}

AdLink = {
  open = function(applicationId)
    local client = Client:new("links", applicationId)
    local response = client.post(client:url(), client:payloadAsJsonString(), nil)
    log("Status code: " .. response.statusCode)
    if (response.statusCode == 302) then
      system.openURL(response.headers['location'])
    end
  end,
}

Banner = {
  DELAYED_LOAD_IMAGE = 10,
  TMP_IMAGE_NAME = "bannerImage.jpg",
  WIDTH = (Screen:width() > 640) and 640 or Screen:width(),
  HEIGHT = Device:isIPad() and 100 or 50 * (Screen.bottom - Screen.top) / display.contentHeight,

  clickUrl = nil,
  imageUrl = nil,
  image = nil,
  x = nil,
  y = nil,
  width = nil,
  height = nil,

  new = function(self, params)
    local banner = params or {}
    setmetatable(banner, self)
    self.__index = self

    banner.adClick = function(event)
      system.openURL(banner.clickUrl)
      return true
    end

    banner.update = function(event)
      if (banner.image) then
        if (banner.image.toFront ~= nil) then
          banner.image:toFront()
        else
          banner:release()
        end
      end
    end

    local remoteImageLoaderListener = function(event)
      if banner.image ~= nil then
        banner:release()
      end
      banner.image = event.target
      banner:show()
    end

    local revMobListener = function(event)
      local status, jsonResponse = pcall(json.decode, event.response)
      if (not status or jsonResponse == nil) then
        log("Ad not received.")
        return
      end
      log("Ad received")
      local links = jsonResponse['banners'][1]['links']
      banner.clickUrl = getLink('clicks', links)
      banner.imageUrl = getLink('image', links)

      timer.performWithDelay(banner.DELAYED_LOAD_IMAGE, function()
        display.loadRemoteImage(banner.imageUrl, "GET", remoteImageLoaderListener,
                                banner.TMP_IMAGE_NAME, system.TemporaryDirectory)
      end)
    end

    local client = Client:new("banners", banner.applicationId)
    client:fetch(revMobListener)
    return banner
  end,

  show = function(self)
    self:setDimension()
    self:setPosition()
    self.image.tap = self.adClick
    self.image:addEventListener("tap", self.image)
    Runtime:addEventListener("enterFrame", self.update)
  end,

  release = function(self)
    log("Releasing event listeners.")
    Runtime:removeEventListener("enterFrame", self.update)
    pcall(self.image.removeEventListener, self.image, "tap", self.image)
    if self.image then
      log("Removing image")
      self.image:removeSelf()
    end
    self.image = nil
  end,

  setPosition = function(self, x, y)
    self.x = x or self.x
    self.y = y or self.y
    if self.image then
      self.image.x = self.x or (Screen.left + self.WIDTH / 2)
      self.image.y = self.y or (Screen.bottom - self.HEIGHT / 2)
    end
  end,

  setDimension = function(self, width, height)
    self.width = width or self.width
    self.height = height or self.height
    if self.image then
      self.image.width = self.width or self.WIDTH
      self.image.height = self.height or self.HEIGHT
    end
  end,
}

local DUMMY_APPID_FOR_SIMULATOR = '4f56aa6e3dc441000e005a20'

RevMob = {
  showPopup = function(applicationIds)
    if Device:isSimulator() then
      Popup.show(DUMMY_APPID_FOR_SIMULATOR)
    else
      applicationId = applicationIds[system.getInfo("platformName")]
      Popup.show(applicationId)
    end
  end,

  showFullscreen = function(applicationIds)
    if Device:isSimulator() then
      Fullscreen.show(DUMMY_APPID_FOR_SIMULATOR)
    else
      applicationId = applicationIds[system.getInfo("platformName")]
      Fullscreen.show(applicationId)
    end
  end,

  openAdLink = function(applicationIds)
    if Device:isSimulator() then
      AdLink.open(DUMMY_APPID_FOR_SIMULATOR)
    else
      applicationId = applicationIds[system.getInfo("platformName")]
      AdLink.open(applicationId)
    end
  end,

  createBanner = function(params)
    if Device:isSimulator() then
      params['applicationId'] = DUMMY_APPID_FOR_SIMULATOR
      return Banner:new(params)
    else
      params['applicationId'] = params[system.getInfo("platformName")]
      return Banner:new(params)
    end
  end,

  printEnvironmentInformation = function()
    log("Device name: " .. system.getInfo("name"))
    log("Model name: " .. system.getInfo("model"))
    log("Device ID: " .. system.getInfo("deviceID"))
    log("Environment: " .. system.getInfo("environment"))
    log("Platform name: " .. system.getInfo("platformName"))
    log("Platform version: " .. system.getInfo("platformVersion"))
    log("Corona version: " .. system.getInfo("version"))
    log("Corona build: " .. system.getInfo("build"))
    log("Architecture: " .. system.getInfo("architectureInfo"))
  end
}
