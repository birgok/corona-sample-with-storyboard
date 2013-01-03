package.preload['json']=(function(...)local a={}local e=string
local u=math
local f=table
local i=error
local c=tonumber
local r=tostring
local s=type
local l=setmetatable
local d=pairs
local m=ipairs
local o=assert
local n=Chipmunk
local n={buffer={}}function n:New()local e={}l(e,self)self.__index=self
e.buffer={}return e
end
function n:Append(e)self.buffer[#self.buffer+1]=e
end
function n:ToString()return f.concat(self.buffer)end
local t={backslashes={['\b']="\\b",['\t']="\\t",['\n']="\\n",['\f']="\\f",['\r']="\\r",['"']='\\"',['\\']="\\\\",['/']="\\/"}}function t:New()local e={}e.writer=n:New()l(e,self)self.__index=self
return e
end
function t:Append(e)self.writer:Append(e)end
function t:ToString()return self.writer:ToString()end
function t:Write(n)local e=s(n)if e=="nil"then
self:WriteNil()elseif e=="boolean"then
self:WriteString(n)elseif e=="number"then
self:WriteString(n)elseif e=="string"then
self:ParseString(n)elseif e=="table"then
self:WriteTable(n)elseif e=="function"then
self:WriteFunction(n)elseif e=="thread"then
self:WriteError(n)elseif e=="userdata"then
self:WriteError(n)end
end
function t:WriteNil()self:Append("null")end
function t:WriteString(e)self:Append(r(e))end
function t:ParseString(n)self:Append('"')self:Append(e.gsub(n,'[%z%c\\"/]',function(t)local n=self.backslashes[t]if n then return n end
return e.format("\\u%.4X",e.byte(t))end))self:Append('"')end
function t:IsArray(t)local n=0
local i=function(e)if s(e)=="number"and e>0 then
if u.floor(e)==e then
return true
end
end
return false
end
for e,t in d(t)do
if not i(e)then
return false,'{','}'else
n=u.max(n,e)end
end
return true,'[',']',n
end
function t:WriteTable(e)local t,o,i,n=self:IsArray(e)self:Append(o)if t then
for t=1,n do
self:Write(e[t])if t<n then
self:Append(',')end
end
else
local n=true;for t,e in d(e)do
if not n then
self:Append(',')end
n=false;self:ParseString(t)self:Append(':')self:Write(e)end
end
self:Append(i)end
function t:WriteError(n)i(e.format("Encoding of %s unsupported",r(n)))end
function t:WriteFunction(e)if e==Null then
self:WriteNil()else
self:WriteError(e)end
end
local r={s="",i=0}function r:New(n)local e={}l(e,self)self.__index=self
e.s=n or e.s
return e
end
function r:Peek()local n=self.i+1
if n<=#self.s then
return e.sub(self.s,n,n)end
return nil
end
function r:Next()self.i=self.i+1
if self.i<=#self.s then
return e.sub(self.s,self.i,self.i)end
return nil
end
function r:All()return self.s
end
local n={escapes={['t']='\t',['n']='\n',['f']='\f',['r']='\r',['b']='\b',}}function n:New(n)local e={}e.reader=r:New(n)l(e,self)self.__index=self
return e;end
function n:Read()self:SkipWhiteSpace()local n=self:Peek()if n==nil then
i(e.format("Nil string: '%s'",self:All()))elseif n=='{'then
return self:ReadObject()elseif n=='['then
return self:ReadArray()elseif n=='"'then
return self:ReadString()elseif e.find(n,"[%+%-%d]")then
return self:ReadNumber()elseif n=='t'then
return self:ReadTrue()elseif n=='f'then
return self:ReadFalse()elseif n=='n'then
return self:ReadNull()elseif n=='/'then
self:ReadComment()return self:Read()else
i(e.format("Invalid input: '%s'",self:All()))end
end
function n:ReadTrue()self:TestReservedWord{'t','r','u','e'}return true
end
function n:ReadFalse()self:TestReservedWord{'f','a','l','s','e'}return false
end
function n:ReadNull()self:TestReservedWord{'n','u','l','l'}return nil
end
function n:TestReservedWord(n)for o,t in m(n)do
if self:Next()~=t then
i(e.format("Error reading '%s': %s",f.concat(n),self:All()))end
end
end
function n:ReadNumber()local n=self:Next()local t=self:Peek()while t~=nil and e.find(t,"[%+%-%d%.eE]")do
n=n..self:Next()t=self:Peek()end
n=c(n)if n==nil then
i(e.format("Invalid number: '%s'",n))else
return n
end
end
function n:ReadString()local n=""o(self:Next()=='"')while self:Peek()~='"'do
local e=self:Next()if e=='\\'then
e=self:Next()if self.escapes[e]then
e=self.escapes[e]end
end
n=n..e
end
o(self:Next()=='"')local t=function(n)return e.char(c(n,16))end
return e.gsub(n,"u%x%x(%x%x)",t)end
function n:ReadComment()o(self:Next()=='/')local n=self:Next()if n=='/'then
self:ReadSingleLineComment()elseif n=='*'then
self:ReadBlockComment()else
i(e.format("Invalid comment: %s",self:All()))end
end
function n:ReadBlockComment()local n=false
while not n do
local t=self:Next()if t=='*'and self:Peek()=='/'then
n=true
end
if not n and
t=='/'and
self:Peek()=="*"then
i(e.format("Invalid comment: %s, '/*' illegal.",self:All()))end
end
self:Next()end
function n:ReadSingleLineComment()local e=self:Next()while e~='\r'and e~='\n'do
e=self:Next()end
end
function n:ReadArray()local t={}o(self:Next()=='[')local n=false
if self:Peek()==']'then
n=true;end
while not n do
local o=self:Read()t[#t+1]=o
self:SkipWhiteSpace()if self:Peek()==']'then
n=true
end
if not n then
local n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' due to: '%s'",self:All(),n))end
end
end
o(']'==self:Next())return t
end
function n:ReadObject()local r={}o(self:Next()=='{')local t=false
if self:Peek()=='}'then
t=true
end
while not t do
local o=self:Read()if s(o)~="string"then
i(e.format("Invalid non-string object key: %s",o))end
self:SkipWhiteSpace()local n=self:Next()if n~=':'then
i(e.format("Invalid object: '%s' due to: '%s'",self:All(),n))end
self:SkipWhiteSpace()local l=self:Read()r[o]=l
self:SkipWhiteSpace()if self:Peek()=='}'then
t=true
end
if not t then
n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' near: '%s'",self:All(),n))end
end
end
o(self:Next()=="}")return r
end
function n:SkipWhiteSpace()local n=self:Peek()while n~=nil and e.find(n,"[%s/]")do
if n=='/'then
self:ReadComment()else
self:Next()end
n=self:Peek()end
end
function n:Peek()return self.reader:Peek()end
function n:Next()return self.reader:Next()end
function n:All()return self.reader:All()end
function encode(n)local e=t:New()e:Write(n)return e:ToString()end
function decode(e)local e=n:New(e)return e:Read()end
function Null()return Null
end
a.encode=encode
a.decode=decode
return a
end)package.preload['asyncHttp']=(function(...)local o={}local n=require("dispatch")local e=require("socket")local c=require("socket.http")local a=require"ltn12"local t=Runtime
local d=table
local e=print
local e=coroutine
function o.request(f,u,i,e)local n=n.newhandler("coroutine")local l=true
n:start(function()local r,s=a.sink.table()local o,t
if e then
if e.headers then
o=e.headers
end
if e.body then
t=a.source.string(e.body)end
end
local n,e,t=c.request{url=f,method=u,create=n.tcp,sink=r,source=t,headers=o}if n then
i{statusCode=e,headers=t,response=d.concat(s),sink=r,isError=false}else
i{isError=true}end
l=false
end)local e={}function e.enterFrame()if l then
n:step()else
t:removeEventListener("enterFrame",e)end
end
function e:cancel()t:removeEventListener("enterFrame",self)n=nil
end
t:addEventListener("enterFrame",e)return e
end
return o
end)package.preload['dispatch']=(function(...)local l={}local t=_G
local i=require("table")local r=require("socket")local n=require("coroutine")local s=type
l.TIMEOUT=10
local a={}function l.newhandler(e)e=e or"coroutine"return a[e]()end
local function e(n,e)return e()end
function a.sequential()return{tcp=r.tcp,start=e}end
function r.protect(e)return function(...)local o=n.create(e)while true do
local e={n.resume(o,t.unpack(arg))}local i=i.remove(e,1)if not i then
if s(e[1])=='table'then
return nil,e[1][1]else t.error(e[1])end
end
if n.status(o)=="suspended"then
arg={n.yield(t.unpack(e))}else
return t.unpack(e)end
end
end
end
local function c()local e={}local n={}return t.setmetatable(n,{__index={insert=function(t,n)if not e[n]then
i.insert(t,n)e[n]=i.getn(t)end
end,remove=function(r,t)local o=e[t]if o then
e[t]=nil
local n=i.remove(r)if n~=t then
e[n]=o
r[o]=n
end
end
end}})end
local function s(i,e,o)if not e then return nil,o end
e:settimeout(0)local a={__index=function(i,n)i[n]=function(...)arg[1]=e
return e[n](t.unpack(arg))end
return i[n]end}local r=false
local o={}function o:settimeout(e,n)if e==0 then r=true
else r=false end
return 1
end
function o:send(l,t,a)t=(t or 1)-1
local r,o
while true do
if n.yield(i.sending,e)=="timeout"then
return nil,"timeout"end
r,o,t=e:send(l,t+1,a)if o~="timeout"then return r,o,t end
end
end
function o:receive(a,t)local o="timeout"local l
while true do
if n.yield(i.receiving,e)=="timeout"then
return nil,"timeout"end
l,o,t=e:receive(a,t)if(o~="timeout")or r then
return l,o,t
end
end
end
function o:connect(r,l)local o,t=e:connect(r,l)if t=="timeout"then
if n.yield(i.sending,e)=="timeout"then
return nil,"timeout"end
o,t=e:connect(r,l)if o or t=="already connected"then return 1
else return nil,"non-blocking connect failed"end
else return o,t end
end
function o:accept()while 1 do
if n.yield(i.receiving,e)=="timeout"then
return nil,"timeout"end
local n,e=e:accept()if e~="timeout"then
return s(i,n,e)end
end
end
function o:close()i.stamp[e]=nil
i.sending.set:remove(e)i.sending.cortn[e]=nil
i.receiving.set:remove(e)i.receiving.cortn[e]=nil
return e:close()end
return t.setmetatable(o,a)end
local i={__index={}}function schedule(i,t,e,n)if t then
if i and e then
e.set:insert(n)e.cortn[n]=i
e.stamp[n]=r.gettime()end
else
print("[RevMob] Unknown error: "..tostring(t).." - "..tostring(e))end
end
function kick(e,n)e.cortn[n]=nil
e.set:remove(n)end
function wakeup(t,i)local e=t.cortn[i]if e then
kick(t,i)return e,n.resume(e)else
return nil,true
end
end
function abort(e,t)local i=e.cortn[t]if i then
kick(e,t)n.resume(i,"timeout")end
end
function i.__index:step()local e,n=r.select(self.receiving.set,self.sending.set,.1)for n,e in t.ipairs(e)do
schedule(wakeup(self.receiving,e))end
for n,e in t.ipairs(n)do
schedule(wakeup(self.sending,e))end
local n=r.gettime()for e,t in t.pairs(self.stamp)do
if e.class=="tcp{client}"and n-t>l.TIMEOUT then
abort(self.sending,e)abort(self.receiving,e)end
end
end
function i.__index:start(e)local e=n.create(e)schedule(e,n.resume(e))end
function a.coroutine()local e={}local e={stamp=e,sending={name="sending",set=c(),cortn={},stamp=e},receiving={name="receiving",set=c(),cortn={},stamp=e},}function e.tcp()return s(e,r.tcp())end
return t.setmetatable(e,i)end
return l
end)package.preload['revmob_messages']=(function(...)local e={NO_ADS="No ads for this device/country right now, or your App ID is paused.",APP_IDLING="No ads because your App ID or Placement ID is idling.",NO_SESSION="The method RevMob.startSession(REVMOB_IDS) has not been called.",UNKNOWN_REASON="Ad was not received because a timeout or for an unknown reason: ",UNKNOWN_REASON_CORONA="Ad was not received for an unknown reason. Is your internet connection working properly? It also may be a timeout or a temporary issue in the server. Please, try again later. If this error persist, please contact us for more details.",INVALID_DEVICE_ID="Device requirements not met.",INVALID_APPID="App not recognized due to invalid App ID.",INVALID_PLACEMENTID="No ads because you type an invalid Placement ID.",OPEN_MARKET="Opening market"}return e end)package.preload['revmob_events']=(function(...)local e={AD_RECEIVED="adReceived",AD_NOT_RECEIVED="adNotReceived",AD_DISPLAYED="adDisplayed",AD_CLICKED="adClicked",AD_CLOSED="adClosed",INSTALL_RECEIVED="installReceived",INSTALL_NOT_RECEIVED="installNotReceived"}return e end)package.preload['revmob_about']=(function(...)local e={VERSION="4.0.0",DEBUG=false}local n=function()if"Android"==system.getInfo("platformName")then
return"corona-android"elseif"iPhone OS"==system.getInfo("platformName")then
return"corona-ios"else
return"corona"end
end
e.NAME=n()return e end)package.preload['revmob_log']=(function(...)local n=require('revmob_about')local e
e={info=function(e)print("[RevMob] "..tostring(e))io.output():flush()end,debug=function(e)if n.DEBUG then
print("[RevMob Debug] "..tostring(e))io.output():flush()end
end,infoTable=function(n)for n,t in pairs(n)do e.info(tostring(n)..': '..tostring(t))end
end,debugTable=function(t)if n.DEBUG then
for n,t in pairs(t)do e.debug(tostring(n)..': '..tostring(t))end
end
end}return e
end)package.preload['revmob_utils']=(function(...)require('revmob_about')local function t(e,n,t)timer.performWithDelay(1,function()display.loadRemoteImage(e,"GET",n,t,system.TemporaryDirectory)end)end
local e
e={left=function()return display.screenOriginX end,top=function()return display.screenOriginY end,right=function()return display.contentWidth-display.screenOriginX end,bottom=function()return display.contentHeight-display.screenOriginY end,width=function()return e.right()-e.left()end,height=function()return e.bottom()-e.top()end}local n={}n.loadAsset=t
n.Screen=e
return n end)package.preload['revmob_context']=(function(...)local s=require"dispatch"local l=require('revmob_about')local e=require('revmob_log')local o=require('revmob_device')local r=require('revmob_client')local a=require('revmob_advertiser')local e={printEnvironmentInformation=function(i)local n=nil
local t=nil
if i~=nil then
n=tostring(i["Android"])t=tostring(i["iPhone OS"])end
e.info("==============================================")e.info("RevMob Corona SDK: "..l["NAME"].." - "..l["VERSION"])e.info("App ID in the current session: "..tostring(r.appId))if n~=nil then e.info("Publisher App ID for Android: "..n)end
if t~=nil then e.info("Publisher App ID for iOS: "..t)end
e.info("Device name: "..system.getInfo("name"))e.info("Model name: "..system.getInfo("model"))e.info("Device ID: "..system.getInfo("deviceID"))e.info("Environment: "..system.getInfo("environment"))e.info("Platform name: "..system.getInfo("platformName"))e.info("Platform version: "..system.getInfo("platformVersion"))e.info("Corona version: "..system.getInfo("version"))e.info("Corona build: "..system.getInfo("build"))e.info("Architecture: "..system.getInfo("architectureInfo"))e.info("Locale-Country: "..system.getPreference("locale","country"))e.info("Locale-Language: "..system.getPreference("locale","language"))e.info("Timeout: "..tostring(r.timeout).."s / "..tostring(s.TIMEOUT).."s")e.info("Corona Simulator: "..tostring(o.isSimulator()))e.info("iOS Simulator: "..tostring(o.isIosSimulator()))if n~=nil then e.info("Installed (Android devices): "..tostring(a.isInstallRegistered(n)))end
if t~=nil then e.info("Installed (iOS devices): "..tostring(a.isInstallRegistered(t)))end
end}return e end)package.preload['revmob_device']=(function(...)local t=require('revmob_log')local e='9774d5f368157442'local o='4c6dbc5d000387f3679a53d76f6944211a7f2224'local r=o
local n=false
local i={wifi=nil,wwan=nil,hasInternetConnection=function()return(not network.canDetectNetworkStatusChanges)or(RevMobConnection.wifi or RevMobConnection.wwan)end}local function l(e)if e.isReachable then
t.info("Internet connection available.")else
t.info("Could not connect to RevMob site. No ads will be available.")end
i.wwan=e.isReachableViaCellular
i.wifi=e.isReachableViaWiFi
t.info("IsReachableViaCellular: "..tostring(e.isReachableViaCellular))t.info("IsReachableViaWiFi: "..tostring(e.isReachableViaWiFi))end
if network.canDetectNetworkStatusChanges and not n then
network.setStatusListener("revmob.com",l)n=true
t.info("Listening network reachability.")end
local n
n={identities=nil,country=nil,manufacturer=nil,model=nil,os_version=nil,connection_speed=nil,new=function(t,e)e=e or{}setmetatable(e,t)t.__index=t
e.identities=n.buildDeviceIdentifierAsTable()e.country=system.getPreference("locale","country")e.locale=system.getPreference("locale","language")e.manufacturer=n.getManufacturer()e.model=n.getModel()e.os_version=system.getInfo("platformVersion")if i.wifi then
e.connection_speed="wifi"elseif i.wwan then
e.connection_speed="wwan"else
e.connection_speed="other"end
return e
end,isAndroid=function()return"Android"==system.getInfo("platformName")end,isIOS=function()return"iPhone OS"==system.getInfo("platformName")end,isSimulator=function()return"simulator"==system.getInfo("environment")or system.getInfo("name")==""or n.isIosSimulator()end,isIosSimulator=function()return system.getInfo("name")=="iPhone Simulator"or system.getInfo("name")=="iPad Simulator"end,isIPad=function()return"iPad"==system.getInfo("model")end,getDeviceId=function()if n.isIosSimulator()then
return o or system.getInfo("deviceID")elseif n.isSimulator()then
return r or system.getInfo("deviceID")end
return system.getInfo("deviceID")end,buildDeviceIdentifierAsTable=function()local e=n.getDeviceId()e=string.gsub(e,"-","")e=string.lower(e)if(string.len(e)==40)then
return{udid=e}elseif(string.len(e)==14 or string.len(e)==15 or string.len(e)==17 or string.len(e)==18)then
return{mobile_id=e}elseif(string.len(e)==16)then
return{android_id=e}else
t.info("WARNING: device not identified, no registration or ad unit will work")return nil
end
end,getManufacturer=function()local e=system.getInfo("platformName")if(e=="iPhone OS")then
return"Apple"end
return e
end,getModel=function()local e=n.getManufacturer()if(e=="Apple")then
return system.getInfo("architectureInfo")end
return system.getInfo("model")end}return n
end)package.preload['revmob_client']=(function(...)local a=require('json')local h=require("dispatch")local c=require('asyncHttp')local f=require('socket.http')local d=require("ltn12")local i=require('revmob_about')local n=require('revmob_log')local t=require('revmob_messages')local l=require('revmob_events')local s=require('revmob_device')local e
local m=30
local o='https://api.bcfads.com'local function u(e,t,n)if n==nil then
return o.."/api/v4/mobile_apps/"..e.."/"..t.."/fetch.json"else
return o.."/api/v4/mobile_apps/"..e.."/placements/"..n.."/"..t.."/fetch.json"end
end
local function p(e)return o.."/api/v4/mobile_apps/"..e.."/install.json"end
local function v(e)return o.."/api/v4/mobile_apps/"..e.."/sessions.json"end
local function o()local t=s:new()if e.testMode~=nil then
n.info("TESTING MODE ACTIVE: "..tostring(e.testMode))local e={response=e.testMode}return a.encode({device=t,sdk={name=i["NAME"],version=i["VERSION"]},testing=e})end
return a.encode({device=t,sdk={name=i["NAME"],version=i["VERSION"]}})end
local function r(o,t,i)if t==nil then return end
n.debug("Request url:  "..o)n.debug("Request body: "..t)if not i then i=function(e)n.debugTable(e)end
end
local n={}n.body=t
if s.isAndroid()then
n.headers={["Content-Length"]=tostring(#t),["Content-Type"]="application/json"}c.request(o,"POST",i,n)else
n.headers={["Content-Type"]="application/json"}n.timeout=e.timeout
network.request(o,"POST",i,n)end
end
local function g(i,e,t)if e==nil then return end
n.debug("Request url:  "..i)n.debug("Request body: "..e)if not t then t=function(e)n.debugTable(e)end
end
local n={}n.body=e
n.headers={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"}c.request(i,"POST",t,n)end
local function i(i,c,a,s)if e.sessionStarted then
if placementID~=nil then
n.info("Ad registered with Placement ID "..placementID)end
if s~=nil and s==true then
g(u(e.appId,i,c),o(),a)else
r(u(e.appId,i,c),o(),a)end
else
n.info(t.NO_SESSION)local e={type=l.AD_NOT_RECEIVED,ad=i,reason=t.NO_SESSION,error=t.NO_SESSION}local e={statusCode=0,response=e,headers={}}end
end
e={TEST_WITH_ADS="with_ads",TEST_WITHOUT_ADS="without_ads",TEST_DISABLED=nil,appId=nil,sessionStarted=false,testMode=nil,listenersRegistered=false,startSession=function(t)if e.isAppIdValid(t)then
if not e.sessionStarted then
e.appId=t
e.sessionStarted=true
r(v(t),o(),nil)n.info("Session started for App ID: "..t)else
n.info("Session has already been started for App ID: "..t)end
else
n.info("Invalid App ID: "..tostring(t))end
end,isAppIdValid=function(e)return e and string.len(e)==24
end,setTestingMode=function(n)if n==e.TEST_DISABLED or
n==e.TEST_WITH_ADS or
n==e.TEST_WITHOUT_ADS then
e.testMode=n
else
e.testMode=e.TEST_DISABLED
end
end,install=function(n)r(p(e.appId),o(),n)end,fetchFullscreen=function(e,n)i('fullscreens',e,n)end,fetchBanner=function(e,n)i('banners',e,n)end,fetchLink=function(e,n)i('links',e,n,true)end,fetchPopup=function(n,e)i('pop_ups',n,e)end,theFetchSucceed=function(s,o,r)n.debugTable(o)local e=o.status or o.statusCode
if(e~=200 and e~=302 and e~=303)then
local i=nil
if e==204 then
i=t.NO_ADS
elseif e==404 then
i=t.INVALID_APPID
elseif e==409 then
i=t.INVALID_PLACEMENTID
elseif e==422 then
i=t.INVALID_DEVICE_ID
elseif e==423 then
i=t.APP_IDLING
elseif e==500 then
i=t.UNKNOWN_REASON.."Please, contact us for more details."end
if i==nil then
n.info(t.UNKNOWN_REASON_CORONA.." ("..tostring(e)..")")else
n.info("Reason: "..tostring(i).." ("..tostring(e)..")")end
if r~=nil then r({type=l.AD_NOT_RECEIVED,ad=s,reason=i})end
return false,nil
end
if e==302 or e==303 then
return true,nil
end
local i,e=pcall(a.decode,o.response)if(not i or e==nil)then
n.info("Reason: "..t.UNKNOWN_REASON..tostring(i).." / "..tostring(e))if r~=nil then r({type=l.AD_NOT_RECEIVED,ad=s,reason=reason})end
return false,e
end
return i,e
end,getLink=function(n,e)for t,e in ipairs(e)do
if e.rel==n then
return e.href
end
end
return nil
end,getMarketURL=function(t,n)local i={}if n==nil then
n=""end
local i,n,o=f.request{method="POST",url=t,source=d.source.string(n),headers={["Content-Length"]=tostring(#n),["Content-Type"]="application/json"},sink=d.sink.table(i),}if(n==302 or n==303)then
local i="details%?id=[a-zA-Z0-9%.]+"local t="android%?p=[a-zA-Z0-9%.]+"local n=o['location']if(string.sub(n,1,string.len("market://"))=="market://")then
return n
elseif(string.match(n,i,1))then
local e=string.match(n,i,1)return"market://"..e
elseif(string.sub(n,1,string.len("amzn://"))=="amzn://")then
return n
elseif(string.match(n,t,1))then
local e=string.match(n,t,1)return"amzn://apps/"..e
else
return e.getMarketURL(n)end
end
return t
end,setTimeoutInSeconds=function(t)if(t>=1 and t<5*60)then
e.timeout=t
h.TIMEOUT=t
else
n.info("Invalid timeout.")end
end}local function n(n)if n.type=="applicationSuspend"then
e.sessionStarted=false
elseif n.type=="applicationResume"then
e.startSession(e.appId)end
end
if e.listenersRegistered==false then
e.listenersRegistered=true
Runtime:removeEventListener("system",n)Runtime:addEventListener("system",n)end
e.setTimeoutInSeconds(m)return e
end)package.preload['revmob_fullscreen_web']=(function(...)local r=require('revmob_log')local l=require('revmob_messages')local o=require('revmob_events')local i=require('revmob_client')local t="fullscreen"local n
n={autoshow=true,listener=nil,clickUrl=nil,htmlUrl=nil,new=function(e)local e=e or{}setmetatable(e,n)return e
end,load=function(e,r)e.networkListener=function(n)local r,n=i.theFetchSucceed(t,n,e.listener)if r then
local n=n['fullscreen']['links']e.clickUrl=i.getLink('clicks',n)e.htmlUrl=i.getLink('html',n)if e.listener~=nil then e.listener({type=o.AD_RECEIVED,ad=t})end
if e.autoshow then
e:show()end
end
end
i.fetchFullscreen(r,e.networkListener)end,isLoaded=function(e)return e.htmlUrl~=nil and e.clickUrl~=nil
end,hide=function(e)if not e:isLoaded()then e.autoshow=false end
end,show=function(e)if not e:isLoaded()then
r.info("Ad is not loaded yet to be shown")return
end
e.clickListener=function(n)if string.sub(n.url,-string.len("#close"))=="#close"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
if e.listener~=nil then e.listener({type=o.AD_CLOSED,ad=t})end
return false
end
if string.sub(n.url,-string.len("#click"))=="#click"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
if e.listener~=nil then e.listener({type=o.AD_CLICKED,ad=t})end
local e=i.getMarketURL(e.clickUrl)r.info(l.OPEN_MARKET)if e then system.openURL(e)end
return false
end
if n.errorCode then
r.info("Error: "..tostring(n.errorMessage))end
return true
end
local n={hasBackground=false,autoCancel=true,urlRequest=e.clickListener}e.changeOrientationListener=function(t)native.cancelWebPopup()timer.performWithDelay(200,function()native.showWebPopup(e.htmlUrl,n)end)end
timer.performWithDelay(1,function()if e.listener~=nil then e.listener({type=o.AD_DISPLAYED,ad=t})end
native.showWebPopup(e.htmlUrl,n)end)Runtime:addEventListener("orientation",e.changeOrientationListener)end,close=function(e)if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
native.cancelWebPopup()end,}n.__index=n
return n
end)package.preload['revmob_fullscreen_static']=(function(...)local t=require('revmob_log')local s=require('revmob_messages')local i=require('revmob_events')local l=require('revmob_utils')local a=require('revmob_device')local o=require('revmob_client')local n="fullscreen"local r
r={autoshow=true,listener=nil,clickUrl=nil,imageUrl=nil,closeButtonUrl=nil,component=nil,_clicked=false,_released=false,_updateAccordingToOrientation=nil,_loadCloseButtonListener=nil,_loadImageListener=nil,_networkListener=nil,_moveToFront=nil,new=function(e)local e=e or{}setmetatable(e,r)e.component=display.newGroup()e.component.alpha=0
e.component.isHitTestable=false
e.component.isVisible=false
return e
end,load=function(e,t)e._networkListener=function(t)local n,t=o.theFetchSucceed(n,t,e.listener)if n then
local n=t['fullscreen']['links']e.clickUrl=o.getLink('clicks',n)e.imageUrl=o.getLink('image',n)e.closeButtonUrl=o.getLink('close_button',n)e:loadImage()e:loadCloseButton()end
end
o.fetchFullscreen(t,e._networkListener)end,loadImage=function(e)if e._released==true then t.info("Fullscreen was closed.")return end
e._loadImageListener=function(r)if e._released==true then if r.target then r.target:removeSelf()end t.info("Fullscreen was closed.")return end
if r.isError or r.target==nil or e.imageUrl==nil then
t.info("Fail to load ad image: "..tostring(e.imageUrl))if e.listener~=nil then e.listener({type=i.AD_NOT_RECEIVED,ad=n})end
return
end
e.image=r.target
e.image.isHitTestable=false
e.image.isVisible=false
e.image.alpha=0
e.image.tap=function(r)if not e._clicked then
e._clicked=true
if e.listener~=nil then e.listener({type=i.AD_CLICKED,ad=n})end
local n=o.getMarketURL(e.clickUrl)t.info(s.OPEN_MARKET)if n then system.openURL(n)end
e:close()end
return true
end
e.image.touch=function(n)return true end
e.image:addEventListener("tap",e.image)e.image:addEventListener("touch",e.image)e.component:insert(1,e.image)e:_updateResourcesLoaded()end
l.loadAsset(e.imageUrl,e._loadImageListener,"fullscreen.jpg")end,loadCloseButton=function(e)if e._released==true then return end
e._loadCloseButtonListener=function(o)if e._released==true then if o.target then o.target:removeSelf()end return end
if o.isError or o.target==nil or e.closeButtonUrl==nil then
t.info("Fail to load close button image: "..tostring(e.closeButtonUrl))if e.listener~=nil then e.listener({type=i.AD_NOT_RECEIVED,ad=n})end
return
end
e.closeButtonImage=o.target
e.closeButtonImage.isHitTestable=false
e.closeButtonImage.isVisible=false
e.closeButtonImage.alpha=0
e.closeButtonImage.tap=function(t)if e.listener~=nil then e.listener({type=i.AD_CLOSED,ad=n})end
e:close()return true
end
e.closeButtonImage.touch=function(n)return true end
e.closeButtonImage:addEventListener("tap",e.closeButtonImage)e.closeButtonImage:addEventListener("touch",e.closeButtonImage)e.component:insert(2,e.closeButtonImage)e:_updateResourcesLoaded()end
l.loadAsset(e.closeButtonUrl,e._loadCloseButtonListener,"close_button.jpg")end,_updateResourcesLoaded=function(e)if e:isLoaded()then
if e.listener~=nil then e.listener({type=i.AD_RECEIVED,ad=n})end
if e.autoshow then
e:show()end
end
end,_configureDimensions=function(e)if(e.image~=nil)then
e.image.x=display.contentWidth/2
e.image.y=display.contentHeight/2
e.image.width=l.Screen.width()e.image.height=l.Screen.height()end
if(e.closeButtonImage~=nil)then
e.closeButtonImage.x=display.contentWidth-45
e.closeButtonImage.y=40
e.closeButtonImage.width=a.isIPad()and 35 or 42
e.closeButtonImage.height=a.isIPad()and 35 or 42
end
end,isLoaded=function(e)return e.clickUrl~=nil and e.component~=nil and e.component.numChildren>=2
end,hide=function(e)if not e:isLoaded()then e.autoshow=false end
if e.component~=nil then
e.component.alpha=0
e.component.isVisible=false
if e.image~=nil then e.image.alpha=0 e.image.isVisible=false end
if e.closeButtonImage~=nil then e.closeButtonImage.alpha=0 e.closeButtonImage.isVisible=false end
end
end,show=function(e)if not e:isLoaded()then
t.info("Ad is not loaded yet to be shown")e.autoshow=true
return
end
if e.component~=nil then
e:_configureDimensions()e.component.alpha=1
e.component.isVisible=true
if e.image~=nil then e.image.alpha=1 e.image.isVisible=true end
if e.closeButtonImage~=nil then e.closeButtonImage.alpha=1 e.closeButtonImage.isVisible=true end
e._moveToFront=function(n)if e.component~=nil then e.component:toFront()end end
Runtime:addEventListener("enterFrame",e._moveToFront)e._updateAccordingToOrientation=function(n)e:_configureDimensions()end
Runtime:addEventListener("orientation",e._updateAccordingToOrientation)if e.listener~=nil then e.listener({type=i.AD_DISPLAYED,ad=n})end
end
end,close=function(e)e._released=true
e.autoshow=false
if e._moveToFront~=nil then Runtime:removeEventListener("enterFrame",e._moveToFront)end
if e._updateAccordingToOrientation~=nil then Runtime:removeEventListener("orientation",e._updateAccordingToOrientation)end
e._updateAccordingToOrientation=nil
e._loadCloseButtonListener=nil
e._loadImageListener=nil
e._networkListener=nil
e._moveToFront=nil
e.listener=nil
if e.image~=nil then
pcall(e.image.removeEventListener,e.image,"tap",e.image)pcall(e.image.removeEventListener,e.image,"touch",e.image)e.image:removeSelf()e.image=nil
end
if e.closeButtonImage~=nil then
pcall(e.closeButtonImage.removeEventListener,e.closeButtonImage,"tap",e.closeButtonImage)pcall(e.closeButtonImage.removeEventListener,e.closeButtonImage,"touch",e.closeButtonImage)e.closeButtonImage:removeSelf()e.closeButtonImage=nil
end
if e.component~=nil then e.component:removeSelf()e.component=nil end
e._clicked=false
t.info("Fullscreen closed")end,}r.__index=r
return r
end)package.preload['revmob_fullscreen']=(function(...)local i=require('revmob_log')local n=require('revmob_client')local a=require('revmob_fullscreen_static')local s=require('revmob_fullscreen_web')local o="fullscreen"RevMobFullscreen={params=nil,view=nil,listener=nil,placementID=nil,autoshow=true,new=function(n)local e=n or{}setmetatable(e,RevMobFullscreen)e.params=n
return e
end,load=function(e)local t=function(t)local o,t=n.theFetchSucceed(o,t,e.listener)if o then
local t=t['fullscreen']['links']local o=n.getLink('clicks',t)local r=n.getLink('html',t)local l=n.getLink('image',t)local n=n.getLink('close_button',t)if r then
i.info("Rich fullscreen")e.view=s.new(e.params)e.view.htmlUrl=r
e.view.clickUrl=o
e.view.autoshow=e.autoshow
if e.autoshow==true then
e.view:show()end
else
i.info("Static fullscreen")e.view=a.new(e.params)e.view.imageUrl=l
e.view.closeButtonUrl=n
e.view.clickUrl=o
e.view.autoshow=e.autoshow
e.view:loadImage()e.view:loadCloseButton()end
end
end
n.fetchFullscreen(e.placementID,t)end,hide=function(e)e.autoshow=false
if e.view~=nil then e.view:hide()end
end,show=function(e)e.autoshow=true
if e.view~=nil then e.view:show()end
end,close=function(e)e.autoshow=false
if e.view~=nil then e.view:close()end
end}RevMobFullscreen.__index=RevMobFullscreen
end)package.preload['revmob_banner_web']=(function(...)local r=require('revmob_log')local l=require('revmob_messages')local o=require('revmob_events')local t=require('revmob_client')local i="banner"local n
n={autoshow=true,listener=nil,clickUrl=nil,htmlUrl=nil,webView=nil,x=0,y=0,width=320,height=50,rotation=0,new=function(e)local e=e or{}setmetatable(e,n)return e
end,load=function(e,l)e.networkListener=function(n)local r,n=t.theFetchSucceed(i,n,e.listener)if r then
local n=n['banners'][1]['links']e.clickUrl=t.getLink('clicks',n)e.htmlUrl=t.getLink('html',n)if e.listener~=nil then e.listener({type=o.AD_RECEIVED,ad=i})end
e:configWebView()if e.autoshow then
e:show()end
end
end
t.fetchBanner(l,e.networkListener)end,configWebView=function(e)e.clickListener=function(n)if string.sub(n.url,-string.len("#click"))=="#click"then
if e.listener~=nil then e.listener({type=o.AD_CLICKED,ad=i})end
local n=t.getMarketURL(e.clickUrl)r.info(l.OPEN_MARKET)if n then system.openURL(n)end
e:hide()end
if n.errorCode then
r.info("Error: "..tostring(n.errorMessage))end
return true
end
e.webView=native.newWebView(e.x,e.y,e.width,e.height)e.webView:addEventListener('urlRequest',e.clickListener)e:hide()e.webView.rotation=e.rotation
e.webView.canGoBack=false
e.webView.canGoForward=false
e.webView.hasBackground=true
e.webView:request(e.htmlUrl)e.clickListener2=function(n)return true end
e.webView.tap=e.clickListener2
e.webView.touch=e.clickListener2
e.webView:addEventListener("tap",e.webView)e.webView:addEventListener("touch",e.webView)end,isLoaded=function(e)return e.htmlUrl~=nil and e.clickUrl~=nil
end,show=function(e)if not e:isLoaded()then
r.info("Ad is not loaded yet to be shown")return
end
if e.webView~=nil then
timer.performWithDelay(1,function()if e.listener~=nil then e.listener({type=o.AD_DISPLAYED,ad=i})end
e.webView.alpha=1
end)end
end,setPosition=function(e,n,t)if e.webView then
e.webView.x=n or e.webView.x
e.webView.y=t or e.webView.y
e.x=e.webView.x
e.y=e.webView.y
end
end,setDimension=function(e,i,n,t)if e.webView then
e.webView.width=i or e.webView.width
e.webView.height=n or e.webView.height
e.webView.rotation=t or e.webView.rotation
e.width=e.webView.width
e.height=e.webView.height
e.rotation=e.webView.rotation
end
end,update=function(e,o,r,i,n,t)e:setPosition(o,r)e:setDimension(i,n,t)end,release=function(e)if e.webView then
e.webView:removeEventListener("tap",e.webView)e.webView:removeEventListener("touch",e.webView)e.webView:removeSelf()e.webView=nil
end
end,hide=function(e)if e.webView~=nil then e.webView.alpha=0 end
end,}n.__index=n
return n
end)package.preload['revmob_banner_static']=(function(...)local l=require('revmob_log')local d=require('revmob_messages')local a=require('revmob_events')local n=require('revmob_utils')local s=require('revmob_device')local i=require('revmob_client')local r="banner"local o
o={autoshow=true,listener=nil,clickUrl=nil,imageUrl=nil,component=nil,_clicked=false,_released=false,width=nil,height=nil,x=nil,y=nil,rotation=0,new=function(e)local e=e or{}setmetatable(e,o)e.component=display.newGroup()e.component.alpha=0
return e
end,load=function(e,t)e.networkListener=function(n)local n,t=i.theFetchSucceed(r,n,e.listener)if n then
local n=t['banners'][1]['links']e.clickUrl=i.getLink('clicks',n)e.imageUrl=i.getLink('image',n)e:loadImage()end
end
i.fetchBanner(t,e.networkListener)end,loadImage=function(e)if e._released==true then l.info("Banner was released.")return end
e._loadImageListener=function(t)if e._released==true then if t.target then t.target:removeSelf()end l.info("Banner was released.")return end
if t.isError or t.target==nil or e.imageUrl==nil then
l.info("Fail to load ad image: "..tostring(e.imageUrl))if e.listener~=nil then e.listener({type=a.AD_NOT_RECEIVED,ad=r})end
return
end
e.image=t.target
local o=(n.Screen.width()>640)and 640 or n.Screen.width()local t=(s.isIPad()and 100 or 50*(n.Screen.bottom()-n.Screen.top())/display.contentHeight)local s=(n.Screen.left()+o/2)local c=(n.Screen.bottom()-t/2)e:setPosition(e.x or s,e.y or c)e:setDimension(e.width or o,e.height or t)e.image.tap=function(n)if not e._clicked then
e._clicked=true
if e.listener~=nil then e.listener({type=a.AD_CLICKED,ad=r})end
local n=i.getMarketURL(e.clickUrl)l.info(d.OPEN_MARKET)if n then system.openURL(n)end
e:release()end
return true
end
e.image.touch=function(n)return true end
e.image:addEventListener("tap",e.image)e.image:addEventListener("touch",e.image)e.component:insert(1,e.image)if e.listener~=nil then e.listener({type=a.AD_RECEIVED,ad=r})end
if e.autoshow then
e:show()end
end
n.loadAsset(e.imageUrl,e._loadImageListener,"revmob_banner.jpg")end,isLoaded=function(e)return e.image~=nil and e.clickUrl~=nil and e.component~=nil
end,hide=function(e)if not e:isLoaded()then e.autoshow=false end
if e.component~=nil then e.component.alpha=0 end
end,show=function(e)if not e:isLoaded()then
l.info("Ad is not loaded yet to be shown")e.autoshow=true
return
end
if e.component~=nil then
e.component.alpha=1
if e.listener~=nil then e.listener({type=a.AD_DISPLAYED,ad=r})end
end
end,setPosition=function(e,t,n)if e.image~=nil then
e.image.x=t or e.image.x
e.image.y=n or e.image.y
e.x=e.image.x
e.y=e.image.y
end
end,setDimension=function(e,i,t,n)if e.image~=nil then
e.image.width=i or e.image.width
e.image.height=t or e.image.height
e.image.rotation=n or e.image.rotation
e.width=e.image.width
e.height=e.image.height
e.rotation=e.image.rotation
end
end,release=function(e)e._released=true
e.autoshow=false
e.networkListener=nil
e._loadImageListener=nil
e.listener=nil
if e.image~=nil then
pcall(e.image.removeEventListener,e.image,"tap",e.image)pcall(e.image.removeEventListener,e.image,"touch",e.image)e.image:removeSelf()e.image=nil
end
if e.component~=nil then e.component:removeSelf()e.component=nil end
e._clicked=false
end,}o.__index=o
return o
end)package.preload['revmob_banner']=(function(...)local i=require('revmob_log')local n=require('revmob_client')local r=require('revmob_banner_static')local l=require('revmob_banner_web')local o="banner"RevMobBanner={params=nil,view=nil,placementID=nil,listener=nil,autoshow=true,width=nil,height=nil,x=nil,y=nil,rotation=0,new=function(n)local e=n or{}setmetatable(e,RevMobBanner)e.params=n
return e
end,load=function(e)local t=function(t)local t,o=n.theFetchSucceed(o,t,e.listener)if t then
local t=o['banners'][1]['links']local o=n.getLink('clicks',t)local a=n.getLink('image',t)local n=n.getLink('html',t)if n then
i.info("Rich banner")e.view=l.new(e.params)e.view.htmlUrl=n
e.view.clickUrl=o
e.view.autoshow=e.autoshow
e:configWebView()if e.autoshow==true then
e.view:show()end
else
i.info("Static banner")e.view=r.new(e.params)e.view.imageUrl=a
e.view.clickUrl=o
e.view.autoshow=e.autoshow
e.view:loadImage()end
end
end
n.fetchBanner(e.placementID,t)end,hide=function(e)e.autoshow=false
if e.view~=nil then e.view:hide()end
end,show=function(e)e.autoshow=true
if e.view~=nil then e.view:show()end
end,setPosition=function(e,n,t)if e.view~=nil then e.view:setPosition(n,t)end
e.x=n or e.view.x
e.y=t or e.view.y
end,setDimension=function(e,i,n,t)if e.view~=nil then e.view:setDimension(i,n,t)end
e.width=i or e.view.width
e.height=n or e.view.height
e.rotation=t
if not e.rotation and e.view then
e.rotation=e.view.rotation
else
e.rotation=0
end
end,release=function(e)e.autoshow=false
if e.view~=nil then e.view:release()end
end}RevMobBanner.__index=RevMobBanner
end)package.preload['revmob_link']=(function(...)local r=require('revmob_log')local l=require('revmob_messages')local o=require('revmob_events')local i=require('revmob_client')local t="link"RevMobAdLink={open=function(n,s)local e=function(e)local a,s=i.theFetchSucceed(t,e,n)if a then
if(e.statusCode==302 or e.statusCode==303)then
local e=i.getMarketURL(e.headers['location'])or e.headers['location']if e then
if n then n({type=o.AD_RECEIVED,ad=t})end
r.info(l.OPEN_MARKET)system.openURL(e)else
local e=l.UNKNOWN_REASON.."No market url"r.info(e)if n then n({type=o.AD_NOT_RECEIVED,ad=t,reason=e})end
end
end
end
end
i.fetchLink(s,e)end,}end)package.preload['revmob_popup']=(function(...)local r=require('revmob_log')local o=require('revmob_messages')local t=require('revmob_events')local i=require('revmob_client')local n="popup"RevMobPopup={DELAYED_LOAD_IMAGE=10,YES_BUTTON_POSITION=2,message=nil,click_url=nil,adListener=nil,notifyAdListener=function(e)if RevMobPopup.adListener then
RevMobPopup.adListener(e)end
end,show=function(e,n)RevMobPopup.adListener=e
i.fetchPopup(n,RevMobPopup.networkListener)end,networkListener=function(e)local i,e=i.theFetchSucceed(n,e,RevMobPopup.adListener)if i then
if RevMobPopup.isParseOk(e)then
RevMobPopup.message=e["pop_up"]["message"]RevMobPopup.click_url=e["pop_up"]["links"][1]["href"]timer.performWithDelay(RevMobPopup.DELAYED_LOAD_IMAGE,function()RevMobPopup.notifyAdListener({type=t.AD_DISPLAYED,ad=n})local e=native.showAlert(RevMobPopup.message,"",{"No, thanks.","Yes, Sure!"},RevMobPopup.click)end)RevMobPopup.notifyAdListener({type=t.AD_RECEIVED,ad=n})else
r.info(o.UNKNOWN_REASON)RevMobPopup.notifyAdListener({type=t.AD_NOT_RECEIVED,ad=n,reason=o.UNKNOWN_REASON})end
end
end,isParseOk=function(e)if(e==nil)then
return false
elseif(e["pop_up"]==nil)then
return false
elseif(e["pop_up"]["message"]==nil)then
return false
elseif(e["pop_up"]["links"]==nil)then
return false
elseif(e["pop_up"]["links"][1]==nil)then
return false
elseif(e["pop_up"]["links"][1]["href"]==nil)then
return false
end
return true
end,click=function(e)if"clicked"==e.action then
if RevMobPopup.YES_BUTTON_POSITION==e.index then
RevMobPopup.notifyAdListener({type=t.AD_CLICKED,ad=n})local e=i.getMarketURL(RevMobPopup.click_url)r.info(o.OPEN_MARKET)if e then system.openURL(e)end
else
RevMobPopup.notifyAdListener({type=t.AD_CLOSED,ad=n})end
end
end}end)package.preload['revmob_advertiser']=(function(...)local e=require('json')local n=require('revmob_log')local o=require('revmob_events')local l=require('revmob_client')local e=require('revmob_loadsave')local e={registerInstall=function(r,i)local i=function(t)n.debugTable(t)local l=t.status or t.statusCode
if(l==200)then
e.addItem(r,true)e.saveToFile()n.info("Install received.")if i~=nil then
i.notifyAdListener({type=o.INSTALL_RECEIVED})end
else
n.info("Install not received: "..tostring(t.status))if i~=nil then
i.notifyAdListener({type=o.INSTALL_NOT_RECEIVED})end
end
end
local t=e.loadFromFile()if not t then
e.saveToFile()e.loadFromFile()end
local e=e.getItem(r)if e==true then
n.info("Install already registered in this device")else
l.install(i)end
end,isInstallRegistered=function(n)local t=e.loadFromFile()return t~=nil and e.getItem(n)==true
end}return e end)package.preload['revmob_loadsave']=(function(...)local i=require('json')local n="revmob_sdk.json"local e={}local t=function()local e=system.pathForFile(n,system.CachesDirectory)if not e then
e=system.pathForFile(n,system.TemporaryDirectory)end
return e
end
local n={}n.getItem=function(t)return e[t]or nil
end
n.addItem=function(i,t)e[i]=t
end
n.saveToFile=function()local t=t()local t=io.open(t,"w")local e=i.encode(e)t:write(e)io.close(t)end
n.loadFromFile=function()local t=t()local n=nil
if t then
n=io.open(t,"r")end
if n then
local t=n:read("*a")e=i.decode(t)if e==nil then
e={}end
io.close(n)return true
end
return false
end
return n end)local i=require('revmob_log')local r=require('revmob_context')local o=require('revmob_advertiser')local e=require('revmob_client')require('revmob_fullscreen')require('revmob_banner')require('revmob_link')require('revmob_popup')local n=function(t)if t==nil then return nil end
local n=t[system.getInfo("platformName")]if n==nil then
n=t["iPhone OS"]if e.isAppIdValid(n)then
i.info("Using iPhone App ID for simulator: "..tostring(n))else
n=t["Android"]i.info("Using Android App ID for simulator: "..tostring(n))end
end
return n
end
local e={TEST_DISABLED=e.TEST_DISABLED,TEST_WITH_ADS=e.TEST_WITH_ADS,TEST_WITHOUT_ADS=e.TEST_WITHOUT_ADS,startSession=function(t)local n=n(t)e.startSession(n)o.registerInstall(n)end,setTestingMode=function(n)e.setTestingMode(n)end,showFullscreen=function(t,e)local e=n(e)local e=RevMobFullscreen.new({listener=t,placementID=e})e:load()return e
end,createFullscreen=function(e,t)local n=n(t)local e=RevMobFullscreen.new({listener=e,placementID=n,autoshow=false})e:load()return e
end,openAdLink=function(t,e)local e=n(e)RevMobAdLink.open(t,e)end,createBanner=function(e,t)if e==nil then e={}end
local n=n(t)e["placementID"]=n
local e=RevMobBanner.new(e)e:load()return e
end,showPopup=function(e,t)local n=n(t)RevMobPopup.show(e,n)end,setTimeoutInSeconds=function(n)e.setTimeoutInSeconds(n)end,printEnvironmentInformation=function(e)r.printEnvironmentInformation(e)end}return e
