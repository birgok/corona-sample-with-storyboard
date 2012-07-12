local json = require('json')

local REVMOB_HOSTNAME = 'api.bcfads.com'
local REVMOB_URL = 'https://' .. REVMOB_HOSTNAME
local DUMMY_ANDROID_ID_FOR_SIMULATOR = '9774d5f368157442'
local DUMMY_UDID_FOR_SIMULATOR = '4c6dbc5d000387f3679a53d76f6944211a7f2224'
local DUMMY_ID_FOR_SIMULATOR = DUMMY_ANDROID_ID_FOR_SIMULATOR

function log( message )
  print("[RevMob] " .. tostring(message))
  io.output():flush()
end

Device = {
  identities = nil,
  country = nil,
  manufacturer = nil,
  model = nil,
  os_version = nil,

  new = function(self, device)
    device = device or {}
    setmetatable(device, self)
    self.__index = self

    device.identities = device:buildDeviceIdentifierAsTable()
    device.country = system.getPreference( "locale", "country" )
    device.manufacturer = device:getManufacturer()
    device.model = device:getModel()
    device.os_version = system.getInfo("platformVersion")

    return device
  end,

  isSimulator = function(self)
    return "simulator" == system.getInfo("environment")
  end,

  isAndroid = function(self)
    return "Android" == system.getInfo("platformName")
  end,

  isIphoneOS = function(self)
     return "iPhone OS" == system.getInfo("platformName")
  end,

  isIPad = function(self)
    return "iPad" == system.getInfo("model")
  end,

  getDeviceId = function(self)
    return (self:isSimulator() and DUMMY_ID_FOR_SIMULATOR) or system.getInfo("deviceID")
  end,

  buildDeviceIdentifierAsTable = function(self)
    local id = self:getDeviceId()
    id = string.gsub(id, "-", "")
    id = string.lower(id)
    if (string.len(id) == 40) then
      return { udid = id }
    elseif (string.len(id) == 14 or string.len(id) == 15 or string.len(id) == 17 or string.len(id) == 18) then
      return { mobile_id = id }
    elseif (string.len(id) == 16) then
      return { android_id = id }
    else
      log("WARNING: device not identified, no registration or popup will work")
      return nil
    end
  end,

  getManufacturer = function(self)
    local manufacturer = system.getInfo("platformName")
    if (manufacturer == "iPhone OS") then
      return "Apple"
    end
    return manufacturer
  end,

  getModel = function(self)
    local manufacturer = self:getManufacturer()
    if (manufacturer == "Apple") then
      return system.getInfo("architectureInfo")
    end
    return system.getInfo("model")
  end
}

Client = {
  payload = {},
  adunit = nil,
  applicationId = nil,
  hostname = REVMOB_HOSTNAME,
  device = nil,

  new = function(self, adUnit, applicationId)
    local client = { adunit = adUnit, applicationId = applicationId, device = Device:new() }
    setmetatable(client, self)
    self.__index = self

    return client
  end,

  url = function(self)
    return REVMOB_URL .. "/api/v4/mobile_apps/" .. self.applicationId .. "/" .. self.adunit .. "/fetch.json"
  end,

  payloadAsJsonString = function(self)
    return json.encode({ device = self.device })
  end,

  post = function(reqUrl, reqBody, listener)
    log("Request url:  " ..  reqUrl)
    log("Request body: " ..  reqBody)
    if ( reqBody == nil) then
      return
    end
    local http = require('socket.http')
    local ltn12 = require("ltn12")
    local responseBody = {}
    local status, statusCode, headers = http.request {
      method = "POST",
      url = reqUrl,
      source = ltn12.source.string(reqBody),
      headers = {
        ["Content-Length"] = tostring(#reqBody),
        ["Content-Type"] = "application/json"
      },
      sink = ltn12.sink.table(responseBody),
    }

    local responseTbl = { statusCode = statusCode, response = responseBody[1], headers = headers }
    if listener then
      listener(responseTbl)
    end
    return responseTbl
  end,

  fetch = function(self, listener)
    local co = coroutine.create(Client.post)
    coroutine.resume(co, self:url(), self:payloadAsJsonString(), listener)
  end
}