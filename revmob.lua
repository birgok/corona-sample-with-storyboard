package.preload['json']=(function(...)local e=string
local r=math
local d=table
local i=error
local s=tonumber
local c=tostring
local a=type
local l=setmetatable
local u=pairs
local f=ipairs
local o=assert
local n=Chipmunk
module("json")local n={buffer={}}function n:New()local e={}l(e,self)self.__index=self
e.buffer={}return e
end
function n:Append(e)self.buffer[#self.buffer+1]=e
end
function n:ToString()return d.concat(self.buffer)end
local t={backslashes={['\b']="\\b",['\t']="\\t",['\n']="\\n",['\f']="\\f",['\r']="\\r",['"']='\\"',['\\']="\\\\",['/']="\\/"}}function t:New()local e={}e.writer=n:New()l(e,self)self.__index=self
return e
end
function t:Append(e)self.writer:Append(e)end
function t:ToString()return self.writer:ToString()end
function t:Write(n)local e=a(n)if e=="nil"then
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
function t:WriteString(e)self:Append(c(e))end
function t:ParseString(n)self:Append('"')self:Append(e.gsub(n,'[%z%c\\"/]',function(t)local n=self.backslashes[t]if n then return n end
return e.format("\\u%.4X",e.byte(t))end))self:Append('"')end
function t:IsArray(i)local n=0
local t=function(e)if a(e)=="number"and e>0 then
if r.floor(e)==e then
return true
end
end
return false
end
for e,i in u(i)do
if not t(e)then
return false,'{','}'else
n=r.max(n,e)end
end
return true,'[',']',n
end
function t:WriteTable(e)local n,i,o,t=self:IsArray(e)self:Append(i)if n then
for n=1,t do
self:Write(e[n])if n<t then
self:Append(',')end
end
else
local n=true;for t,e in u(e)do
if not n then
self:Append(',')end
n=false;self:ParseString(t)self:Append(':')self:Write(e)end
end
self:Append(o)end
function t:WriteError(n)i(e.format("Encoding of %s unsupported",c(n)))end
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
function n:TestReservedWord(n)for o,t in f(n)do
if self:Next()~=t then
i(e.format("Error reading '%s': %s",d.concat(n),self:All()))end
end
end
function n:ReadNumber()local n=self:Next()local t=self:Peek()while t~=nil and e.find(t,"[%+%-%d%.eE]")do
n=n..self:Next()t=self:Peek()end
n=s(n)if n==nil then
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
o(self:Next()=='"')local t=function(n)return e.char(s(n,16))end
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
local o=self:Read()if a(o)~="string"then
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
end)package.preload['asyncHttp']=(function(...)local e=require"socket"local n=require"dispatch"local s=require"socket.http"local a=require"ltn12"n.TIMEOUT=10
local t=Runtime
local d=table
local e=print
local e=coroutine
module(...)function request(c,u,r,e)local n=n.newhandler("coroutine")local i=true
n:start(function()local o,f=a.sink.table()local t,l
if e then
if e.headers then
t=e.headers
end
if e.body then
l=a.source.string(e.body)end
end
local e,t,n=s.request{url=c,method=u,create=n.tcp,sink=o,source=l,headers=t}if e then
r{statusCode=t,headers=n,response=d.concat(f),sink=o,isError=false}else
r{isError=true}end
i=false
end)local e={}function e.enterFrame()if i then
n:step()else
t:removeEventListener("enterFrame",e)end
end
function e:cancel()t:removeEventListener("enterFrame",self)n=nil
end
t:addEventListener("enterFrame",e)return e
end
end)package.preload['dispatch']=(function(...)local n=_G
local i=require("table")local r=require("socket")local t=require("coroutine")local a=type
module("dispatch")TIMEOUT=10
local l={}function newhandler(e)e=e or"coroutine"return l[e]()end
local function e(n,e)return e()end
function l.sequential()return{tcp=r.tcp,start=e}end
function r.protect(e)return function(...)local o=t.create(e)while true do
local e={t.resume(o,n.unpack(arg))}local i=i.remove(e,1)if not i then
if a(e[1])=='table'then
return nil,e[1][1]else n.error(e[1])end
end
if t.status(o)=="suspended"then
arg={t.yield(n.unpack(e))}else
return n.unpack(e)end
end
end
end
local function s()local e={}local t={}return n.setmetatable(t,{__index={insert=function(t,n)if not e[n]then
i.insert(t,n)e[n]=i.getn(t)end
end,remove=function(o,t)local n=e[t]if n then
e[t]=nil
local i=i.remove(o)if i~=t then
e[i]=n
o[n]=i
end
end
end}})end
local function a(i,e,o)if not e then return nil,o end
e:settimeout(0)local s={__index=function(i,t)i[t]=function(...)arg[1]=e
return e[t](n.unpack(arg))end
return i[t]end}local r=false
local o={}function o:settimeout(e,n)if e==0 then r=true
else r=false end
return 1
end
function o:send(l,n,a)n=(n or 1)-1
local r,o
while true do
if t.yield(i.sending,e)=="timeout"then
return nil,"timeout"end
r,o,n=e:send(l,n+1,a)if o~="timeout"then return r,o,n end
end
end
function o:receive(a,n)local o="timeout"local l
while true do
if t.yield(i.receiving,e)=="timeout"then
return nil,"timeout"end
l,o,n=e:receive(a,n)if(o~="timeout")or r then
return l,o,n
end
end
end
function o:connect(l,r)local o,n=e:connect(l,r)if n=="timeout"then
if t.yield(i.sending,e)=="timeout"then
return nil,"timeout"end
o,n=e:connect(l,r)if o or n=="already connected"then return 1
else return nil,"non-blocking connect failed"end
else return o,n end
end
function o:accept()while 1 do
if t.yield(i.receiving,e)=="timeout"then
return nil,"timeout"end
local n,e=e:accept()if e~="timeout"then
return a(i,n,e)end
end
end
function o:close()i.stamp[e]=nil
i.sending.set:remove(e)i.sending.cortn[e]=nil
i.receiving.set:remove(e)i.receiving.cortn[e]=nil
return e:close()end
return n.setmetatable(o,s)end
local i={__index={}}function schedule(i,o,e,t)if o then
if i and e then
e.set:insert(t)e.cortn[t]=i
e.stamp[t]=r.gettime()end
else n.error(e)end
end
function kick(e,n)e.cortn[n]=nil
e.set:remove(n)end
function wakeup(i,n)local e=i.cortn[n]if e then
kick(i,n)return e,t.resume(e)else
return nil,true
end
end
function abort(n,i)local e=n.cortn[i]if e then
kick(n,i)t.resume(e,"timeout")end
end
function i.__index:step()local t,e=r.select(self.receiving.set,self.sending.set,.1)for n,e in n.ipairs(t)do
schedule(wakeup(self.receiving,e))end
for n,e in n.ipairs(e)do
schedule(wakeup(self.sending,e))end
local t=r.gettime()for e,n in n.pairs(self.stamp)do
if e.class=="tcp{client}"and t-n>TIMEOUT then
abort(self.sending,e)abort(self.receiving,e)end
end
end
function i.__index:start(e)local e=t.create(e)schedule(e,t.resume(e))end
function l.coroutine()local e={}local e={stamp=e,sending={name="sending",set=s(),cortn={},stamp=e},receiving={name="receiving",set=s(),cortn={},stamp=e},}function e.tcp()return a(e,r.tcp())end
return n.setmetatable(e,i)end
end)package.preload['revmob_messages']=(function(...)REVMOB_MSG_NO_ADS="No ads for this device/country right now, or your App ID is paused."REVMOB_MSG_APP_IDLING="No ads because your App ID or Placement ID is idling."REVMOB_MSG_NO_SESSION="The method RevMob.startSession(REVMOB_IDS) has not been called."REVMOB_MSG_UNKNOWN_REASON="Ad was not received for an unknown reason: "REVMOB_MSG_INVALID_DEVICE_ID="Device requirements not met."REVMOB_MSG_INVALID_APPID="App not recognized due to invalid App ID."REVMOB_MSG_INVALID_PLACEMENTID="No ads because you type an invalid Placement ID."REVMOB_MSG_OPEN_MARKET="Opening market"REVMOB_EVENT_AD_RECEIVED="adReceived"REVMOB_EVENT_AD_NOT_RECEIVED="adNotReceived"REVMOB_EVENT_AD_DISPLAYED="adDisplayed"REVMOB_EVENT_AD_CLICKED="adClicked"REVMOB_EVENT_AD_CLOSED="adClosed"REVMOB_EVENT_INSTALL_RECEIVED="installReceived"REVMOB_EVENT_INSTALL_NOT_RECEIVED="installNotReceived"end)package.preload['revmob_about']=(function(...)require('revmob_utils')REVMOB_SDK={VERSION="3.4.7"}local e=function()if RevMobUtils.isAndroid()then
return"corona-android"elseif RevMobUtils.isIOS()then
return"corona-ios"else
return"corona"end
end
REVMOB_SDK.NAME=e()end)package.preload['revmob_client']=(function(...)local i=require('json')require('revmob_about')require('revmob_messages')require('revmob_utils')require('asyncHttp')local n='https://api.bcfads.com'local e='9774d5f368157442'local o='4c6dbc5d000387f3679a53d76f6944211a7f2224'local t=e
local r=10
RevMobConnection={wifi=nil,wwan=nil,hasInternetConnection=function()return(not network.canDetectNetworkStatusChanges)or(RevMobConnection.wifi or RevMobConnection.wwan)end}function RevMobNetworkReachabilityListener(e)if e.isReachable then
log("Internet connection available.")else
log("Could not connect to RevMob site. No ads will be available.")end
RevMobConnection.wwan=e.isReachableViaCellular
RevMobConnection.wifi=e.isReachableViaWiFi
log("IsReachableViaCellular: "..tostring(e.isReachableViaCellular))log("IsReachableViaWiFi: "..tostring(e.isReachableViaWiFi))end
if network.canDetectNetworkStatusChanges then
network.setStatusListener("revmob.com",RevMobNetworkReachabilityListener)log("Listening network reachability.")end
RevMobDevice={identities=nil,country=nil,manufacturer=nil,model=nil,os_version=nil,connection_speed=nil,new=function(n,e)e=e or{}setmetatable(e,n)n.__index=n
e.identities=e:buildDeviceIdentifierAsTable()e.country=system.getPreference("locale","country")e.locale=system.getPreference("locale","language")e.manufacturer=e:getManufacturer()e.model=e:getModel()e.os_version=system.getInfo("platformVersion")if RevMobConnection.wifi then
e.connection_speed="wifi"elseif RevMobConnection.wwan then
e.connection_speed="wwan"else
e.connection_speed="other"end
return e
end,isSimulator=function(e)return"simulator"==system.getInfo("environment")or system.getInfo("name")==""or e:isIosSimulator()end,isIosSimulator=function(e)return system.getInfo("name")=="iPhone Simulator"or system.getInfo("name")=="iPad Simulator"end,isIPad=function(e)return"iPad"==system.getInfo("model")end,getDeviceId=function(e)if e:isIosSimulator()then
return o or system.getInfo("deviceID")elseif e:isSimulator()then
return t or system.getInfo("deviceID")end
return system.getInfo("deviceID")end,buildDeviceIdentifierAsTable=function(e)local e=e:getDeviceId()e=string.gsub(e,"-","")e=string.lower(e)if(string.len(e)==40)then
return{udid=e}elseif(string.len(e)==14 or string.len(e)==15 or string.len(e)==17 or string.len(e)==18)then
return{mobile_id=e}elseif(string.len(e)==16)then
return{android_id=e}else
log("WARNING: device not identified, no registration or ad unit will work")return nil
end
end,getManufacturer=function(e)local e=system.getInfo("platformName")if(e=="iPhone OS")then
return"Apple"end
return e
end,getModel=function(e)local e=e:getManufacturer()if(e=="Apple")then
return system.getInfo("architectureInfo")end
return system.getInfo("model")end}RevMobClient={payload={},adunit=nil,applicationId=nil,device=nil,placementID=nil,TEST_WITH_ADS="with_ads",TEST_WITHOUT_ADS="without_ads",new=function(e,t,n)local n={adunit=t,device=RevMobDevice:new(),applicationId=RevMobSessionManager.appID,placementID=n}setmetatable(n,e)e.__index=e
return n
end,url=function(e)if e.placementID==nil then
return n.."/api/v4/mobile_apps/"..e.applicationId.."/"..e.adunit.."/fetch.json"else
return n.."/api/v4/mobile_apps/"..e.applicationId.."/placements/"..e.placementID.."/"..e.adunit.."/fetch.json"end
end,urlInstall=function(e)return n.."/api/v4/mobile_apps/"..e.applicationId.."/install.json"end,urlSession=function(e)return n.."/api/v4/mobile_apps/"..e.applicationId.."/sessions.json"end,payloadAsJsonString=function(n)if RevMobSessionManager.testMode~=nil then
log("TESTING MODE ACTIVE")local e=nil
if RevMobSessionManager.testMode==RevMobClient.TEST_WITHOUT_ADS then
e={response=RevMobClient.TEST_WITHOUT_ADS}else
e={response=RevMobClient.TEST_WITH_ADS}end
return i.encode({device=n.device,sdk={name=REVMOB_SDK["NAME"],version=REVMOB_SDK["VERSION"]},testing=e})end
return i.encode({device=n.device,sdk={name=REVMOB_SDK["NAME"],version=REVMOB_SDK["VERSION"]}})end,post=function(i,t,n)if t==nil then return end
if not n then n=function(e)end
end
local e={}e.body=t
if RevMobUtils.isAndroid()then
e.headers={["Content-Length"]=tostring(#t),["Content-Type"]="application/json"}asyncHttp.request(i,"POST",n,e)else
e.headers={["Content-Type"]="application/json"}e.timeout=r
network.request(i,"POST",n,e)end
end,postWithoutFollowRedirect=function(i,e,n)if e==nil then return end
if not n then n=function(e)end
end
local t={}t.body=e
t.headers={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"}asyncHttp.request(i,"POST",n,t)end,fetch=function(e,n)if RevMobSessionManager.isSessionStarted()then
if e.placementID~=nil then
log("Ad registered with Placement ID "..e.placementID)end
RevMobClient.post(e:url(),e:payloadAsJsonString(),n)else
local e={statusCode=0,response={error="Session not started"},headers={}}if n then
n(e)end
end
end,install=function(e,n)RevMobClient.post(e:urlInstall(),e:payloadAsJsonString(),n)end,startSession=function(e)RevMobClient.post(e:urlSession(),e:payloadAsJsonString(),listener)end,theFetchSucceed=function(r,o,t)local e=o.status or o.statusCode
if(e~=200 and e~=302 and e~=303)then
local n=nil
if e==204 then
n=REVMOB_MSG_NO_ADS
elseif e==404 then
n=REVMOB_MSG_INVALID_APPID
elseif e==409 then
n=REVMOB_MSG_INVALID_PLACEMENTID
elseif e==422 then
n=REVMOB_MSG_INVALID_DEVICE_ID
elseif e==423 then
n=REVMOB_MSG_APP_IDLING
elseif e==500 then
n=REVMOB_MSG_UNKNOWN_REASON.."Please, contact us for more details."end
log("Reason: "..tostring(n))if t~=nil then t({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=r,reason=n})end
return false,nil
end
if e==302 or e==303 then
return true,nil
end
local n,e=pcall(i.decode,o.response)if(not n or e==nil)then
local n=REVMOB_MSG_UNKNOWN_REASON..tostring(n).." / "..tostring(e)log("Reason: "..tostring(n))if t~=nil then t({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=r,reason=n})end
return false,e
end
return n,e
end,getMarketURL=function(i,e)local t=require('socket.http')local n=require("ltn12")local o={}if e==nil then
e=""end
local n,e,o=t.request{method="POST",url=i,source=n.source.string(e),headers={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"},sink=n.sink.table(o),}if(e==302 or e==303)then
local t="details%?id=[a-zA-Z0-9%.]+"local n="android%?p=[a-zA-Z0-9%.]+"local e=o['location']if(string.sub(e,1,string.len("market://"))=="market://")then
return e
elseif(string.match(e,t,1))then
local e=string.match(e,t,1)return"market://"..e
elseif(string.sub(e,1,string.len("amzn://"))=="amzn://")then
return e
elseif(string.match(e,n,1))then
local e=string.match(e,n,1)return"amzn://apps/"..e
else
return RevMobClient.getMarketURL(e)end
end
return i
end}end)package.preload['revmob_utils']=(function(...)function log(e)print("[RevMob] "..tostring(e))io.output():flush()end
function logTable(e)for e,n in pairs(e)do log(tostring(e)..': '..tostring(n))end
end
RevMobUtils={isAndroid=function()return"Android"==system.getInfo("platformName")end,isIOS=function()return"iPhone OS"==system.getInfo("platformName")end,getLink=function(n,e)for t,e in ipairs(e)do
if e.rel==n then
return e.href
end
end
return nil
end,loadAsset=function(e,t,n)timer.performWithDelay(1,function()display.loadRemoteImage(e,"GET",t,n,system.TemporaryDirectory)end)end}RevMobScreen={left=function()return display.screenOriginX end,top=function()return display.screenOriginY end,right=function()return display.contentWidth-display.screenOriginX end,bottom=function()return display.contentHeight-display.screenOriginY end,width=function()return RevMobScreen.right()-RevMobScreen.left()end,height=function()return RevMobScreen.bottom()-RevMobScreen.top()end,}end)package.preload['fullscreen']=(function(...)require('revmob_messages')require('revmob_client')require('revmob_utils')local n="fullscreen"Fullscreen={autoshow=true,listener=nil,clickUrl=nil,imageUrl=nil,closeButtonUrl=nil,component=nil,_clicked=false,_released=false,_updateAccordingToOrientation=nil,_loadCloseButtonListener=nil,_loadImageListener=nil,_networkListener=nil,_moveToFront=nil,new=function(e)local e=e or{}setmetatable(e,Fullscreen)e.component=display.newGroup()e.component.alpha=0
return e
end,load=function(e,i)e._networkListener=function(t)local n,t=RevMobClient.theFetchSucceed(n,t,e.listener)if n then
local n=t['fullscreen']['links']e.clickUrl=RevMobUtils.getLink('clicks',n)e.imageUrl=RevMobUtils.getLink('image',n)e.closeButtonUrl=RevMobUtils.getLink('close_button',n)e:loadImage()e:loadCloseButton()end
end
local n=RevMobClient:new("fullscreens",i)n:fetch(e._networkListener)end,loadImage=function(e)if e._released==true then log("Fullscreen was closed.")return end
e._loadImageListener=function(t)if e._released==true then if t.target then t.target:removeSelf()end log("Fullscreen was closed.")return end
if t.isError or t.target==nil or e.imageUrl==nil then
log("Fail to load ad image: "..tostring(e.imageUrl))if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=n})end
return
end
e.image=t.target
e:_configureDimensions()e.image.tap=function(t)if not e._clicked then
e._clicked=true
if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_CLICKED,ad=n})end
local n=RevMobClient.getMarketURL(e.clickUrl)log(REVMOB_MSG_OPEN_MARKET)if n then system.openURL(n)end
e:close()end
return true
end
e.image.touch=function(n)return true end
e.image:addEventListener("tap",e.image)e.image:addEventListener("touch",e.image)e.component:insert(1,e.image)e:_update_resources_loaded()end
RevMobUtils.loadAsset(e.imageUrl,e._loadImageListener,"fullscreen.jpg")end,loadCloseButton=function(e)if e._released==true then return end
e._loadCloseButtonListener=function(t)if e._released==true then if t.target then t.target:removeSelf()end return end
if t.isError or t.target==nil or e.closeButtonUrl==nil then
log("Fail to load close button image: "..tostring(e.closeButtonUrl))if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=n})end
return
end
e.closeButtonImage=t.target
e:_configureDimensions()e.closeButtonImage.tap=function(t)if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_CLOSED,ad=n})end
e:close()return true
end
e.closeButtonImage.touch=function(n)return true end
e.closeButtonImage:addEventListener("tap",e.closeButtonImage)e.closeButtonImage:addEventListener("touch",e.closeButtonImage)e.component:insert(2,e.closeButtonImage)e:_update_resources_loaded()end
RevMobUtils.loadAsset(e.closeButtonUrl,e._loadCloseButtonListener,"close_button.jpg")end,_update_resources_loaded=function(e)if e:isLoaded()then
if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_RECEIVED,ad=n})end
if e.autoshow then
e:show()end
end
end,_configureDimensions=function(e)if(e.image~=nil)then
e.image.x=display.contentWidth/2
e.image.y=display.contentHeight/2
e.image.width=RevMobScreen.width()e.image.height=RevMobScreen.height()end
if(e.closeButtonImage~=nil)then
e.closeButtonImage.x=display.contentWidth-45
e.closeButtonImage.y=40
e.closeButtonImage.width=RevMobDevice:isIPad()and 35 or 40
e.closeButtonImage.height=RevMobDevice:isIPad()and 35 or 40
end
end,isLoaded=function(e)return e.clickUrl~=nil and e.component~=nil and e.component.numChildren>=2
end,hide=function(e)if not e:isLoaded()then e.autoshow=false end
if e.component~=nil then e.component.alpha=0 end
end,show=function(e)if not e:isLoaded()then
log("Ad is not loaded yet to be shown")e.autoshow=true
return
end
if e.component~=nil then
e.component.alpha=1
e._moveToFront=function(n)if e.component~=nil then e.component:toFront()end end
Runtime:addEventListener("enterFrame",e._moveToFront)e._updateAccordingToOrientation=function(n)e:_configureDimensions()end
Runtime:addEventListener("orientation",e._updateAccordingToOrientation)if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_DISPLAYED,ad=n})end
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
log("Fullscreen closed")end,}Fullscreen.__index=Fullscreen
end)package.preload['fullscreen_web']=(function(...)require('revmob_messages')require('revmob_client')require('revmob_utils')local n="fullscreen"FullscreenWeb={autoshow=true,listener=nil,clickUrl=nil,htmlUrl=nil,new=function(e)local e=e or{}setmetatable(e,FullscreenWeb)return e
end,load=function(e,i)e.networkListener=function(t)local i,t=RevMobClient.theFetchSucceed(n,t,e.listener)if i then
local t=t['fullscreen']['links']e.clickUrl=RevMobUtils.getLink('clicks',t)e.htmlUrl=RevMobUtils.getLink('html',t)if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_RECEIVED,ad=n})end
if e.autoshow then
e:show()end
end
end
local n=RevMobClient:new("fullscreens",i)n:fetch(e.networkListener)end,isLoaded=function(e)return e.htmlUrl~=nil and e.clickUrl~=nil
end,hide=function(e)if not e:isLoaded()then e.autoshow=false end
end,show=function(e)if not e:isLoaded()then
log("Ad is not loaded yet to be shown")return
end
e.clickListener=function(t)if string.sub(t.url,-string.len("#close"))=="#close"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_CLOSED,ad=n})end
return false
end
if string.sub(t.url,-string.len("#click"))=="#click"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_CLICKED,ad=n})end
local e=RevMobClient.getMarketURL(e.clickUrl)log(REVMOB_MSG_OPEN_MARKET)if e then system.openURL(e)end
return false
end
if t.errorCode then
log("Error: "..tostring(t.errorMessage))end
return true
end
local t={hasBackground=false,autoCancel=true,urlRequest=e.clickListener}e.changeOrientationListener=function(n)native.cancelWebPopup()timer.performWithDelay(200,function()native.showWebPopup(e.htmlUrl,t)end)end
timer.performWithDelay(1,function()if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_DISPLAYED,ad=n})end
native.showWebPopup(e.htmlUrl,t)end)Runtime:addEventListener("orientation",e.changeOrientationListener)end,close=function(e)if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
native.cancelWebPopup()end,}FullscreenWeb.__index=FullscreenWeb
end)package.preload['fullscreen_chooser']=(function(...)require('revmob_messages')require('revmob_client')require('revmob_utils')require('fullscreen')require('fullscreen_web')local t="fullscreen"FullscreenChooser={listener=nil,placementID=nil,fullscreen=nil,autoshow=true,new=function(e)local e=e or{}setmetatable(e,FullscreenChooser)return e
end,load=function(e)local n=function(n)local i,n=RevMobClient.theFetchSucceed(t,n,e.listener)if i then
local n=n['fullscreen']['links']local o=RevMobUtils.getLink('clicks',n)local i=RevMobUtils.getLink('html',n)local r=RevMobUtils.getLink('image',n)local n=RevMobUtils.getLink('close_button',n)if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_RECEIVED,ad=t})end
if i then
log("Rich fullscreen")e.fullscreen=FullscreenWeb.new({listener=e.listener})e.fullscreen.htmlUrl=i
e.fullscreen.clickUrl=o
e.fullscreen.autoshow=e.autoshow
if e.autoshow==true then
e.fullscreen:show()end
else
log("Static fullscreen")e.fullscreen=Fullscreen.new({listener=e.listener})e.fullscreen.imageUrl=r
e.fullscreen.closeButtonUrl=n
e.fullscreen.clickUrl=o
e.fullscreen.autoshow=e.autoshow
e.fullscreen:loadImage()e.fullscreen:loadCloseButton()end
end
end
local e=RevMobClient:new("fullscreens",e.placementID)e:fetch(n)end,hide=function(e)e.autoshow=false
if e.fullscreen~=nil then e.fullscreen:hide()end
end,show=function(e)e.autoshow=true
if e.fullscreen~=nil then e.fullscreen:show()end
end,close=function(e)e.autoshow=false
if e.fullscreen~=nil then e.fullscreen:close()end
end}FullscreenChooser.__index=FullscreenChooser
end)package.preload['banner']=(function(...)require('revmob_messages')require('revmob_client')require('revmob_utils')local n="banner"Banner={autoshow=true,listener=nil,clickUrl=nil,imageUrl=nil,component=nil,_clicked=false,_released=false,width=nil,height=nil,x=nil,y=nil,new=function(e)local e=e or{}setmetatable(e,Banner)e.component=display.newGroup()e.component.alpha=0
return e
end,load=function(e,i)e.networkListener=function(t)local t,n=RevMobClient.theFetchSucceed(n,t,e.listener)if t then
local n=n['banners'][1]['links']e.clickUrl=RevMobUtils.getLink('clicks',n)e.imageUrl=RevMobUtils.getLink('image',n)e:loadImage()end
end
local n=RevMobClient:new("banners",i)n:fetch(e.networkListener)end,loadImage=function(e)if e._released==true then log("Banner was released.")return end
e._loadImageListener=function(t)if e._released==true then if t.target then t.target:removeSelf()end log("Banner was released.")return end
if t.isError or t.target==nil or e.imageUrl==nil then
log("Fail to load ad image: "..tostring(e.imageUrl))if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=n})end
return
end
e.image=t.target
local t=(RevMobScreen.width()>640)and 640 or RevMobScreen.width()local i=(RevMobDevice:isIPad()and 100 or 50*(RevMobScreen.bottom()-RevMobScreen.top())/display.contentHeight)local o=(RevMobScreen.left()+t/2)local r=(RevMobScreen.bottom()-i/2)e:setPosition(e.x or o,e.y or r)e:setDimension(e.width or t,e.height or i)e.image.tap=function(t)if not e._clicked then
e._clicked=true
if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_CLICKED,ad=n})end
local n=RevMobClient.getMarketURL(e.clickUrl)log(REVMOB_MSG_OPEN_MARKET)if n then system.openURL(n)end
e:release()end
return true
end
e.image.touch=function(n)return true end
e.image:addEventListener("tap",e.image)e.image:addEventListener("touch",e.image)e.component:insert(1,e.image)if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_RECEIVED,ad=n})end
if e.autoshow then
e:show()end
end
RevMobUtils.loadAsset(e.imageUrl,e._loadImageListener,"revmob_banner.jpg")end,isLoaded=function(e)return e.image~=nil and e.clickUrl~=nil and e.component~=nil
end,hide=function(e)if not e:isLoaded()then e.autoshow=false end
if e.component~=nil then e.component.alpha=0 end
end,show=function(e)if not e:isLoaded()then
log("Ad is not loaded yet to be shown")e.autoshow=true
return
end
if e.component~=nil then
e.component.alpha=1
if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_DISPLAYED,ad=n})end
end
end,setPosition=function(e,t,n)if e.image~=nil then
e.image.x=t or e.image.x
e.image.y=n or e.image.y
end
end,setDimension=function(e,i,t,n)if e.image~=nil then
e.image.width=i or e.image.width
e.image.height=t or e.image.height
e.image.rotation=n or e.image.rotation
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
end,}Banner.__index=Banner
end)package.preload['banner_web']=(function(...)require('revmob_messages')require('revmob_client')require('revmob_utils')local n="banner"BannerWeb={autoshow=true,listener=nil,clickUrl=nil,htmlUrl=nil,webView=nil,x=0,y=0,width=320,height=50,rotation=0,new=function(e)local e=e or{}setmetatable(e,BannerWeb)return e
end,load=function(e,o)e.networkListener=function(t)local i,t=RevMobClient.theFetchSucceed(n,t,e.listener)if i then
local t=t['banners'][1]['links']e.clickUrl=RevMobUtils.getLink('clicks',t)e.htmlUrl=RevMobUtils.getLink('html',t)if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_RECEIVED,ad=n})end
e:configWebView()if e.autoshow then
e:show()end
end
end
local n=RevMobClient:new("banners",o)n:fetch(e.networkListener)end,configWebView=function(e)e.clickListener=function(t)if string.sub(t.url,-string.len("#click"))=="#click"then
if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_CLICKED,ad=n})end
local n=RevMobClient.getMarketURL(e.clickUrl)log(REVMOB_MSG_OPEN_MARKET)if n then system.openURL(n)end
e:hide()end
if t.errorCode then
log("Error: "..tostring(t.errorMessage))end
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
log("Ad is not loaded yet to be shown")return
end
if e.webView~=nil then
timer.performWithDelay(1,function()if e.listener~=nil then e.listener({type=REVMOB_EVENT_AD_DISPLAYED,ad=n})end
e.webView.alpha=1
end)end
end,setPosition=function(e,n,t)if e.webView then
e.webView.x=n or e.webView.x
e.webView.y=t or e.webView.y
end
end,setDimension=function(e,n,i,t)if e.webView then
e.webView.width=n or e.webView.width
e.webView.height=i or e.webView.height
e.webView.rotation=t or e.webView.rotation
end
end,update=function(e,n,t,i,r,o)e:setPosition(n,t)e:setDimension(i,r,o)end,release=function(e)if e.webView then
e.webView:removeEventListener("tap",e.webView)e.webView:removeEventListener("touch",e.webView)e.webView:removeSelf()e.webView=nil
end
end,hide=function(e)if e.webView~=nil then e.webView.alpha=0 end
end,}BannerWeb.__index=BannerWeb
end)package.preload['adlink']=(function(...)require('revmob_messages')require('revmob_client')require('revmob_utils')require('session_manager')local t="link"AdLink={open=function(e,i)if RevMobSessionManager.isSessionStarted()then
local n=function(n)local i,o=RevMobClient.theFetchSucceed(t,n,e)if i then
if(n.statusCode==302 or n.statusCode==303)then
local n=RevMobClient.getMarketURL(n.headers['location'])or n.headers['location']if n then
if e then e({type=REVMOB_EVENT_AD_RECEIVED,ad=t})end
log(REVMOB_MSG_OPEN_MARKET)system.openURL(n)else
local n=REVMOB_MSG_UNKNOWN_REASON.."No market url"log(n)if e then e({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=t,reason=n})end
end
end
end
end
local e=RevMobClient:new("links",i)e.postWithoutFollowRedirect(e:url(),e:payloadAsJsonString(),n)else
log(REVMOB_MSG_NO_SESSION)if e then e({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=t,reason=REVMOB_MSG_NO_SESSION})end
end
end,}end)package.preload['popup']=(function(...)require('revmob_messages')require('revmob_client')local e="popup"RevMobPopup={DELAYED_LOAD_IMAGE=10,YES_BUTTON_POSITION=2,message=nil,click_url=nil,adListener=nil,notifyAdListener=function(e)if RevMobPopup.adListener then
RevMobPopup.adListener(e)end
end,show=function(e,n)RevMobPopup.adListener=e
client=RevMobClient:new("pop_ups",n)client:fetch(RevMobPopup.networkListener)end,networkListener=function(n)local t,n=RevMobClient.theFetchSucceed(e,n,RevMobPopup.adListener)if t then
if RevMobPopup.isParseOk(n)then
RevMobPopup.message=n["pop_up"]["message"]RevMobPopup.click_url=n["pop_up"]["links"][1]["href"]timer.performWithDelay(RevMobPopup.DELAYED_LOAD_IMAGE,function()RevMobPopup.notifyAdListener({type=REVMOB_EVENT_AD_DISPLAYED,ad=e})local e=native.showAlert(RevMobPopup.message,"",{"No, thanks.","Yes, Sure!"},RevMobPopup.click)end)RevMobPopup.notifyAdListener({type=REVMOB_EVENT_AD_RECEIVED,ad=e})else
log(REVMOB_MSG_UNKNOWN_REASON)RevMobPopup.notifyAdListener({type=REVMOB_EVENT_AD_NOT_RECEIVED,ad=e,reason=REVMOB_MSG_UNKNOWN_REASON})end
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
end,click=function(n)if"clicked"==n.action then
if RevMobPopup.YES_BUTTON_POSITION==n.index then
RevMobPopup.notifyAdListener({type=REVMOB_EVENT_AD_CLICKED,ad=e})local e=RevMobClient.getMarketURL(RevMobPopup.click_url)log(REVMOB_MSG_OPEN_MARKET)if e then system.openURL(e)end
else
RevMobPopup.notifyAdListener({type=REVMOB_EVENT_AD_CLOSED,ad=e})end
end
end}end)package.preload['advertiser']=(function(...)local e=require('json')require('revmob_messages')require('revmob_client')require('revmob_utils')require('loadsave')Advertiser={registerInstall=function(n,e)local t=function(t)if(t.statusCode==200)then
RevMobPrefs.addItem(n,true)RevMobPrefs.saveToFile()log("Install received.")if e~=nil then
e.notifyAdListener({type=REVMOB_EVENT_INSTALL_RECEIVED})end
else
log("Install not received.")if e~=nil then
e.notifyAdListener({type=REVMOB_EVENT_INSTALL_NOT_RECEIVED})end
end
end
local e=RevMobPrefs.loadFromFile()if not e then
RevMobPrefs.saveToFile()RevMobPrefs.loadFromFile()end
local e=RevMobPrefs.getItem(n)if e==true then
log("Install already registered in this device")else
local e=RevMobClient:new("")e:install(t)end
end}end)package.preload['loadsave']=(function(...)local n=require('json')RevMobPrefs={FILENAME="revmob_sdk.json",preferences={},getItem=function(e)return RevMobPrefs.preferences[e]or nil
end,addItem=function(n,e)RevMobPrefs.preferences[n]=e
end,saveToFile=function()local e=RevMobPrefs.getFileAbsolutePath()local e=io.open(e,"w")local n=n.encode(RevMobPrefs.preferences)e:write(n)io.close(e)end,getFileAbsolutePath=function()local e=system.pathForFile(RevMobPrefs.FILENAME,system.CachesDirectory)if not e then
e=system.pathForFile(RevMobPrefs.FILENAME,system.TemporaryDirectory)end
return e
end,loadFromFile=function()local t=RevMobPrefs.getFileAbsolutePath()local e=nil
if t then
e=io.open(t,"r")end
if e then
local t=e:read("*a")RevMobPrefs.preferences=n.decode(t)if RevMobPrefs.preferences==nil then
RevMobPrefs.preferences={}end
io.close(e)return true
end
return false
end}end)package.preload['session_manager']=(function(...)require("revmob_utils")RevMobSessionManager={listenersRegistered=false,appID=nil,sessionStarted=false,testMode=nil,isAppIdValid=function(e)return e and string.len(e)==24
end,startSession=function(e,n)RevMobSessionManager.testMode=n
if RevMobSessionManager.isAppIdValid(e)then
if not RevMobSessionManager.sessionStarted then
RevMobSessionManager.appID=e
RevMobSessionManager.sessionStarted=true
local e=RevMobClient:new("")e:startSession()log("Session started for App ID: "..RevMobSessionManager.appID)else
log("Session has already been started for App ID: "..e)end
else
log("Invalid App ID: "..tostring(e))end
end,sessionManagement=function(e)if e.type=="applicationSuspend"then
RevMobSessionManager.sessionStarted=false
elseif e.type=="applicationResume"then
RevMobSessionManager.startSession(RevMobSessionManager.appID)end
end,isSessionStarted=function()return RevMobSessionManager.sessionStarted
end,}if RevMobSessionManager.listenersRegistered==false then
RevMobSessionManager.listenersRegistered=true
Runtime:removeEventListener("system",RevMobSessionManager.sessionManagement)Runtime:addEventListener("system",RevMobSessionManager.sessionManagement)end end)require('revmob_about')require('revmob_utils')require('revmob_client')require('revmob_messages')require('fullscreen')require('fullscreen_web')require('fullscreen_chooser')require('banner')require('banner_web')require('adlink')require('popup')require('advertiser')require('session_manager')local e=5e3
RevMob={TEST_WITH_ADS=RevMobClient.TEST_WITH_ADS,TEST_WITHOUT_ADS=RevMobClient.TEST_WITHOUT_ADS,getRevMobIDAccordingToPlatform=function(n)if n==nil then return nil end
local e=n[system.getInfo("platformName")]if e==nil then
e=n["iPhone OS"]if RevMobSessionManager.isAppIdValid(e)then
log("Using iPhone App ID for simulator: "..tostring(e))else
e=n["Android"]log("Using Android App ID for simulator: "..tostring(e))end
end
return e
end,startSession=function(e,n)local e=RevMob.getRevMobIDAccordingToPlatform(e)RevMobSessionManager.startSession(e,n)Advertiser.registerInstall(e)end,showFullscreen=function(e,n)if not RevMobSessionManager.isSessionStarted()then return log(REVMOB_MSG_NO_SESSION)end
local n=RevMob.getRevMobIDAccordingToPlatform(n)local e=FullscreenChooser.new({listener=e,placementID=n})e:load()return e
end,openAdLink=function(n,e)if not RevMobSessionManager.isSessionStarted()then return log(REVMOB_MSG_NO_SESSION)end
local e=RevMob.getRevMobIDAccordingToPlatform(e)AdLink.open(n,e)end,createBanner=function(e,n)if not RevMobSessionManager.isSessionStarted()then return log(REVMOB_MSG_NO_SESSION)end
if e==nil then e={}end
local n=RevMob.getRevMobIDAccordingToPlatform(n)e["placementID"]=n
local e=Banner.new(e)e:load()return e
end,showPopup=function(e,n)if not RevMobSessionManager.isSessionStarted()then return log(REVMOB_MSG_NO_SESSION)end
local n=RevMob.getRevMobIDAccordingToPlatform(n)RevMobPopup.show(e,n)end,printEnvironmentInformation=function(e)log("==============================================")log("RevMob Corona SDK: "..REVMOB_SDK["NAME"].." - "..REVMOB_SDK["VERSION"])log("App ID in session: "..tostring(RevMobSessionManager.appID))if e then
log("User App ID for Android: "..tostring(e["Android"]))log("User App ID for iOS: "..tostring(e["iPhone OS"]))end
log("Device name: "..system.getInfo("name"))log("Model name: "..system.getInfo("model"))log("Device ID: "..system.getInfo("deviceID"))log("Environment: "..system.getInfo("environment"))log("Platform name: "..system.getInfo("platformName"))log("Platform version: "..system.getInfo("platformVersion"))log("Corona version: "..system.getInfo("version"))log("Corona build: "..system.getInfo("build"))log("Architecture: "..system.getInfo("architectureInfo"))log("Locale-Country: "..system.getPreference("locale","country"))log("Locale-Language: "..system.getPreference("locale","language"))end}