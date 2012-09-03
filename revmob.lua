package.preload['json']=(function(...)local e=string
local l=math
local c=table
local i=error
local a=tonumber
local d=tostring
local s=type
local o=setmetatable
local u=pairs
local f=ipairs
local r=assert
local n=Chipmunk
module("json")local n={buffer={}}function n:New()local e={}o(e,self)self.__index=self
e.buffer={}return e
end
function n:Append(e)self.buffer[#self.buffer+1]=e
end
function n:ToString()return c.concat(self.buffer)end
local t={backslashes={['\b']="\\b",['\t']="\\t",['\n']="\\n",['\f']="\\f",['\r']="\\r",['"']='\\"',['\\']="\\\\",['/']="\\/"}}function t:New()local e={}e.writer=n:New()o(e,self)self.__index=self
return e
end
function t:Append(e)self.writer:Append(e)end
function t:ToString()return self.writer:ToString()end
function t:Write(e)local n=s(e)if n=="nil"then
self:WriteNil()elseif n=="boolean"then
self:WriteString(e)elseif n=="number"then
self:WriteString(e)elseif n=="string"then
self:ParseString(e)elseif n=="table"then
self:WriteTable(e)elseif n=="function"then
self:WriteFunction(e)elseif n=="thread"then
self:WriteError(e)elseif n=="userdata"then
self:WriteError(e)end
end
function t:WriteNil()self:Append("null")end
function t:WriteString(e)self:Append(d(e))end
function t:ParseString(n)self:Append('"')self:Append(e.gsub(n,'[%z%c\\"/]',function(n)local t=self.backslashes[n]if t then return t end
return e.format("\\u%.4X",e.byte(n))end))self:Append('"')end
function t:IsArray(i)local n=0
local t=function(e)if s(e)=="number"and e>0 then
if l.floor(e)==e then
return true
end
end
return false
end
for e,i in u(i)do
if not t(e)then
return false,'{','}'else
n=l.max(n,e)end
end
return true,'[',']',n
end
function t:WriteTable(e)local t,r,i,n=self:IsArray(e)self:Append(r)if t then
for t=1,n do
self:Write(e[t])if t<n then
self:Append(',')end
end
else
local n=true;for t,e in u(e)do
if not n then
self:Append(',')end
n=false;self:ParseString(t)self:Append(':')self:Write(e)end
end
self:Append(i)end
function t:WriteError(n)i(e.format("Encoding of %s unsupported",d(n)))end
function t:WriteFunction(e)if e==Null then
self:WriteNil()else
self:WriteError(e)end
end
local l={s="",i=0}function l:New(n)local e={}o(e,self)self.__index=self
e.s=n or e.s
return e
end
function l:Peek()local n=self.i+1
if n<=#self.s then
return e.sub(self.s,n,n)end
return nil
end
function l:Next()self.i=self.i+1
if self.i<=#self.s then
return e.sub(self.s,self.i,self.i)end
return nil
end
function l:All()return self.s
end
local n={escapes={['t']='\t',['n']='\n',['f']='\f',['r']='\r',['b']='\b',}}function n:New(n)local e={}e.reader=l:New(n)o(e,self)self.__index=self
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
function n:TestReservedWord(n)for r,t in f(n)do
if self:Next()~=t then
i(e.format("Error reading '%s': %s",c.concat(n),self:All()))end
end
end
function n:ReadNumber()local n=self:Next()local t=self:Peek()while t~=nil and e.find(t,"[%+%-%d%.eE]")do
n=n..self:Next()t=self:Peek()end
n=a(n)if n==nil then
i(e.format("Invalid number: '%s'",n))else
return n
end
end
function n:ReadString()local n=""r(self:Next()=='"')while self:Peek()~='"'do
local e=self:Next()if e=='\\'then
e=self:Next()if self.escapes[e]then
e=self.escapes[e]end
end
n=n..e
end
r(self:Next()=='"')local t=function(n)return e.char(a(n,16))end
return e.gsub(n,"u%x%x(%x%x)",t)end
function n:ReadComment()r(self:Next()=='/')local n=self:Next()if n=='/'then
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
function n:ReadArray()local t={}r(self:Next()=='[')local n=false
if self:Peek()==']'then
n=true;end
while not n do
local r=self:Read()t[#t+1]=r
self:SkipWhiteSpace()if self:Peek()==']'then
n=true
end
if not n then
local n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' due to: '%s'",self:All(),n))end
end
end
r(']'==self:Next())return t
end
function n:ReadObject()local l={}r(self:Next()=='{')local t=false
if self:Peek()=='}'then
t=true
end
while not t do
local r=self:Read()if s(r)~="string"then
i(e.format("Invalid non-string object key: %s",r))end
self:SkipWhiteSpace()local n=self:Next()if n~=':'then
i(e.format("Invalid object: '%s' due to: '%s'",self:All(),n))end
self:SkipWhiteSpace()local o=self:Read()l[r]=o
self:SkipWhiteSpace()if self:Peek()=='}'then
t=true
end
if not t then
n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' near: '%s'",self:All(),n))end
end
end
r(self:Next()=="}")return l
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
end)package.preload['asyncHttp']=(function(...)local e=require"socket"local n=require"dispatch"local c=require"socket.http"local r=require"ltn12"n.TIMEOUT=10
local t=Runtime
local f=table
local e=print
local e=coroutine
module(...)function request(u,d,i,e)local n=n.newhandler("coroutine")local s=true
n:start(function()local l,a=r.sink.table()local o,t
if e then
if e.headers then
o=e.headers
end
if e.body then
t=r.source.string(e.body)end
end
local n,e,t=c.request{url=u,method=d,create=n.tcp,sink=l,source=t,headers=o}if n then
i{statusCode=e,headers=t,response=f.concat(a),sink=l,isError=false}else
i{isError=true}end
s=false
end)local e={}function e.enterFrame()if s then
n:step()else
t:removeEventListener("enterFrame",e)end
end
function e:cancel()t:removeEventListener("enterFrame",self)n=nil
end
t:addEventListener("enterFrame",e)return e
end
end)package.preload['dispatch']=(function(...)local n=_G
local i=require("table")local l=require("socket")local t=require("coroutine")local s=type
module("dispatch")TIMEOUT=60
local o={}function newhandler(e)e=e or"coroutine"return o[e]()end
local function r(n,e)return e()end
function o.sequential()return{tcp=l.tcp,start=r}end
function l.protect(e)return function(...)local r=t.create(e)while true do
local e={t.resume(r,n.unpack(arg))}local i=i.remove(e,1)if not i then
if s(e[1])=='table'then
return nil,e[1][1]else n.error(e[1])end
end
if t.status(r)=="suspended"then
arg={t.yield(n.unpack(e))}else
return n.unpack(e)end
end
end
end
local function a()local e={}local t={}return n.setmetatable(t,{__index={insert=function(t,n)if not e[n]then
i.insert(t,n)e[n]=i.getn(t)end
end,remove=function(l,n)local r=e[n]if r then
e[n]=nil
local t=i.remove(l)if t~=n then
e[t]=r
l[r]=t
end
end
end}})end
local function s(i,e,r)if not e then return nil,r end
e:settimeout(0)local a={__index=function(i,t)i[t]=function(...)arg[1]=e
return e[t](n.unpack(arg))end
return i[t]end}local l=false
local r={}function r:settimeout(e,n)if e==0 then l=true
else l=false end
return 1
end
function r:send(s,n,o)n=(n or 1)-1
local l,r
while true do
if t.yield(i.sending,e)=="timeout"then
return nil,"timeout"end
l,r,n=e:send(s,n+1,o)if r~="timeout"then return l,r,n end
end
end
function r:receive(s,n)local r="timeout"local o
while true do
if t.yield(i.receiving,e)=="timeout"then
return nil,"timeout"end
o,r,n=e:receive(s,n)if(r~="timeout")or l then
return o,r,n
end
end
end
function r:connect(o,l)local r,n=e:connect(o,l)if n=="timeout"then
if t.yield(i.sending,e)=="timeout"then
return nil,"timeout"end
r,n=e:connect(o,l)if r or n=="already connected"then return 1
else return nil,"non-blocking connect failed"end
else return r,n end
end
function r:accept()while 1 do
if t.yield(i.receiving,e)=="timeout"then
return nil,"timeout"end
local n,e=e:accept()if e~="timeout"then
return s(i,n,e)end
end
end
function r:close()i.stamp[e]=nil
i.sending.set:remove(e)i.sending.cortn[e]=nil
i.receiving.set:remove(e)i.receiving.cortn[e]=nil
return e:close()end
return n.setmetatable(r,a)end
local i={__index={}}function schedule(i,r,e,t)if r then
if i and e then
e.set:insert(t)e.cortn[t]=i
e.stamp[t]=l.gettime()end
else n.error(e)end
end
function kick(n,e)n.cortn[e]=nil
n.set:remove(e)end
function wakeup(n,i)local e=n.cortn[i]if e then
kick(n,i)return e,t.resume(e)else
return nil,true
end
end
function abort(n,e)local i=n.cortn[e]if i then
kick(n,e)t.resume(i,"timeout")end
end
function i.__index:step()local e,t=l.select(self.receiving.set,self.sending.set,.1)for n,e in n.ipairs(e)do
schedule(wakeup(self.receiving,e))end
for n,e in n.ipairs(t)do
schedule(wakeup(self.sending,e))end
local t=l.gettime()for e,n in n.pairs(self.stamp)do
if e.class=="tcp{client}"and t-n>TIMEOUT then
abort(self.sending,e)abort(self.receiving,e)end
end
end
function i.__index:start(e)local e=t.create(e)schedule(e,t.resume(e))end
function o.coroutine()local e={}local e={stamp=e,sending={name="sending",set=a(),cortn={},stamp=e},receiving={name="receiving",set=a(),cortn={},stamp=e},}function e.tcp()return s(e,l.tcp())end
return n.setmetatable(e,i)end
end)package.preload['revmob_about']=(function(...)REVMOB_SDK={NAME="corona",VERSION="3.2.2"}end)package.preload['revmob_client']=(function(...)local r=require('json')require('revmob_about')require('revmob_utils')require("asyncHttp")local t='https://api.bcfads.com'local e='9774d5f368157442'local n='4c6dbc5d000387f3679a53d76f6944211a7f2224'local i=e
Connection={wifi=nil,wwan=nil,hasInternetConnection=function()return(not network.canDetectNetworkStatusChanges)or(Connection.wifi or Connection.wwan)end}function RevMobNetworkReachabilityListener(e)if e.isReachable then
log("Internet connection available.")else
log("Could not connect to RevMob site. No ads will be available.")end
Connection.wwan=e.isReachableViaCellular
Connection.wifi=e.isReachableViaWiFi
log("IsReachableViaCellular: "..tostring(e.isReachableViaCellular))log("IsReachableViaWiFi: "..tostring(e.isReachableViaWiFi))end
if network.canDetectNetworkStatusChanges then
network.setStatusListener("revmob.com",RevMobNetworkReachabilityListener)log("Listening network reachability.")end
Device={identities=nil,country=nil,manufacturer=nil,model=nil,os_version=nil,connection_speed=nil,new=function(n,e)e=e or{}setmetatable(e,n)n.__index=n
e.identities=e:buildDeviceIdentifierAsTable()e.country=system.getPreference("locale","country")e.locale=system.getPreference("locale","language")e.manufacturer=e:getManufacturer()e.model=e:getModel()e.os_version=system.getInfo("platformVersion")if Connection.wifi then
e.connection_speed="wifi"elseif Connection.wwan then
e.connection_speed="wwan"else
e.connection_speed="other"end
return e
end,isSimulator=function(e)return"simulator"==system.getInfo("environment")or system.getInfo("name")==""or system.getInfo("name")=="iPhone Simulator"or system.getInfo("name")=="iPad Simulator"end,isAndroid=function(e)return"Android"==system.getInfo("platformName")end,isIphoneOS=function(e)return"iPhone OS"==system.getInfo("platformName")end,isIPad=function(e)return"iPad"==system.getInfo("model")end,getDeviceId=function(e)return(e:isSimulator()and i)or system.getInfo("deviceID")end,buildDeviceIdentifierAsTable=function(e)local e=e:getDeviceId()e=string.gsub(e,"-","")e=string.lower(e)if(string.len(e)==40)then
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
return system.getInfo("model")end}Client={payload={},adunit=nil,applicationId=nil,device=nil,new=function(e,n,t)local n={adunit=n,applicationId=t or RevMobSessionManager.appID,device=Device:new()}setmetatable(n,e)e.__index=e
return n
end,url=function(e)return t.."/api/v4/mobile_apps/"..e.applicationId.."/"..e.adunit.."/fetch.json"end,urlInstall=function(e)return t.."/api/v4/mobile_apps/"..e.applicationId.."/install.json"end,urlSession=function(e)return t.."/api/v4/mobile_apps/"..e.applicationId.."/sessions.json"end,payloadAsJsonString=function(e)return r.encode({device=e.device,sdk={name=REVMOB_SDK["NAME"],version=REVMOB_SDK["VERSION"]}})end,post=function(t,e,n)if e==nil then return end
if not n then n=function(e)end
end
local i={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"}asyncHttp.request(t,"POST",n,{body=e,headers=i})end,fetch=function(n,e)if RevMobSessionManager.isSessionStarted()then
local t=coroutine.create(Client.post)coroutine.resume(t,n:url(),n:payloadAsJsonString(),e)else
local n={statusCode=0,response={error="Session not started"},headers={}}if e then
e(n)end
end
end,install=function(e,n)local t=coroutine.create(Client.post)coroutine.resume(t,e:urlInstall(),e:payloadAsJsonString(),n)end,startSession=function(e)local n=coroutine.create(Client.post)coroutine.resume(n,e:urlSession(),e:payloadAsJsonString(),listener)end}end)package.preload['revmob_utils']=(function(...)function log(e)print("[RevMob] "..tostring(e))io.output():flush()end
getLink=function(n,e)for t,e in ipairs(e)do
if e.rel==n then
return e.href
end
end
return nil
end
Screen={left=display.screenOriginX,top=display.screenOriginY,right=display.contentWidth-display.screenOriginX,bottom=display.contentHeight-display.screenOriginY,scaleX=display.contentScaleX,scaleY=display.contentScaleY,width=function(e)return e.right-e.left
end,height=function(e)return e.bottom-e.top
end,}getMarketURL=function(i,e)local r=require('socket.http')local n=require("ltn12")local t={}if e==nil then
e=""end
local n,e,i=r.request{method="POST",url=i,source=n.source.string(e),headers={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"},sink=n.sink.table(t),}if(e==302 or e==303)then
local t="details%?id=[a-zA-Z0-9%.]+"local n="android%?p=[a-zA-Z0-9%.]+"local e=i['location']if(string.sub(e,1,string.len("market://"))=="market://")then
return e
elseif(string.match(e,t,1))then
local e=string.match(e,t,1)return"market://"..e
elseif(string.sub(e,1,string.len("amzn://"))=="amzn://")then
return e
elseif(string.match(e,n,1))then
local e=string.match(e,n,1)return"amzn://apps/"..e
else
return getMarketURL(e)end
end
return nil
end
end)package.preload['fullscreen']=(function(...)local e=require('json')require('revmob_client')require('revmob_utils')Fullscreen={ASSETS_PATH='revmob-assets/fullscreen/',DELAYED_LOAD_IMAGE=10,TMP_IMAGE_NAME="fullscreen.jpg",TMP_CLOSE_BUTTON_IMAGE_NAME='close_button.jpg',CLOSE_BUTTON_X=Screen.right-30,CLOSE_BUTTON_Y=Screen.top+40,CLOSE_BUTTON_WIDTH=Device:isIPad()and 30 or 35,DELAY=200,adClicked=false,clickUrl=nil,screenGroup=nil,adListener=nil,notifyAdListener=function(e)if Fullscreen.adListener then
Fullscreen.adListener(e)end
end,networkListener=function(n)local n,e=pcall(e.decode,n.response)if(not n or e==nil)then
log("Ad not received.")native.setActivityIndicator(false)Fullscreen.notifyAdListener({type="adNotReceived",ad="fullscreen"})return
end
local e=e['fullscreen']['links']Fullscreen.clickUrl=getLink('clicks',e)Fullscreen.imageUrl=getLink('image',e)Fullscreen.closeButtonImageUrl=getLink('close_button',e)timer.performWithDelay(Fullscreen.DELAYED_LOAD_IMAGE,function()display.loadRemoteImage(Fullscreen.imageUrl,"GET",Fullscreen.loadImage,Fullscreen.TMP_IMAGE_NAME,system.TemporaryDirectory)end)end,loadImage=function(e)if e.isError then
log("Ad not received.")native.setActivityIndicator(false)Fullscreen.notifyAdListener({type="adNotReceived",ad="fullscreen"})return
end
Fullscreen.localizedImage=e.target
Fullscreen.localizedImage.x=display.contentWidth/2
Fullscreen.localizedImage.y=display.contentHeight/2
Fullscreen.localizedImage.width=Screen:width()Fullscreen.localizedImage.height=Screen:height()Fullscreen.localizedImage.tap=function(e,e)Fullscreen.adClick()return true
end
Fullscreen.localizedImage.touch=function(e,e)return true
end
Fullscreen.localizedImage:addEventListener("tap",Fullscreen.localizedImage)Fullscreen.localizedImage:addEventListener("touch",Fullscreen.localizedImage)Fullscreen.loadCloseButtonImage()Fullscreen.create()log("Ad received")native.setActivityIndicator(false)Fullscreen.notifyAdListener({type="adReceived",ad="fullscreen"})end,loadCloseButtonImage=function()local e=Fullscreen.ASSETS_PATH..'close_button.png'Fullscreen.closeButton=display.newImageRect(e,Fullscreen.CLOSE_BUTTON_WIDTH,Fullscreen.CLOSE_BUTTON_WIDTH)Fullscreen.closeButton.x=Fullscreen.CLOSE_BUTTON_X
Fullscreen.closeButton.y=Fullscreen.CLOSE_BUTTON_Y
Fullscreen.closeButton.width=Fullscreen.CLOSE_BUTTON_WIDTH
Fullscreen.closeButton.height=Fullscreen.CLOSE_BUTTON_WIDTH
Fullscreen.closeButton.tap=function(e,e)Fullscreen.back()Fullscreen.notifyAdListener({type="adClosed",ad="fullscreen"})return true
end
Fullscreen.closeButton.touch=function(e,e)return true
end
Fullscreen.closeButton:addEventListener("tap",Fullscreen.closeButton)Fullscreen.closeButton:addEventListener("touch",Fullscreen.closeButton)end,create=function()Fullscreen.screenGroup=display.newGroup()Runtime:addEventListener("enterFrame",Fullscreen.update)Runtime:addEventListener("system",Fullscreen.onApplicationResume)Fullscreen.screenGroup:insert(Fullscreen.localizedImage)Fullscreen.screenGroup:insert(Fullscreen.closeButton)end,release=function(e)Runtime:removeEventListener("enterFrame",Fullscreen.update)Runtime:removeEventListener("system",Fullscreen.onApplicationResume)pcall(Fullscreen.localizedImage.removeEventListener,Fullscreen.localizedImage,"tap",Fullscreen.localizedImage)pcall(Fullscreen.localizedImage.removeEventListener,Fullscreen.localizedImage,"touch",Fullscreen.localizedImage)pcall(Fullscreen.closeButton.removeEventListener,Fullscreen.closeButton,"tap",Fullscreen.closeButton)pcall(Fullscreen.closeButton.removeEventListener,Fullscreen.closeButton,"touch",Fullscreen.closeButton)if Fullscreen.screenGroup then
Fullscreen.screenGroup:removeSelf()Fullscreen.screenGroup=nil
end
Fullscreen.adClicked=false
log("Fullscreen Released.")return true
end,back=function()timer.performWithDelay(Fullscreen.DELAY,Fullscreen.release)return true
end,adClick=function()if not Fullscreen.adClicked then
Fullscreen.adClicked=true
Fullscreen.notifyAdListener({type="adClicked",ad="fullscreen"})local e=getMarketURL(Fullscreen.clickUrl)if e then
system.openURL(e)else
system.openURL(Fullscreen.clickUrl)end
Fullscreen.back()end
return true
end,update=function(e)if(Fullscreen.screenGroup)then
Fullscreen.screenGroup:toFront()end
end,show=function(e)Fullscreen.adListener=e
local e=Client:new("fullscreens")e:fetch(Fullscreen.networkListener)end,onApplicationResume=function(e)if e.type=="applicationResume"then
log("Application resumed.")Fullscreen.release()end
end,}end)package.preload['fullscreen_web']=(function(...)local t=require('json')require('revmob_client')require('revmob_utils')FullscreenWeb={autoshow=true,listener=nil,clickUrl=nil,htmlUrl=nil,new=function(e)local e=e or{}setmetatable(e,FullscreenWeb)return e
end,load=function(e)e.networkListener=function(n)local t,n=pcall(t.decode,n.response)if(not t or n==nil)then
log("Ad not received.")if e.listener~=nil then e.listener({type="adNotReceived",ad="fullscreen"})end
native.setActivityIndicator(false)return
end
local n=n['fullscreen']['links']e.clickUrl=getLink('clicks',n)e.htmlUrl=getLink('html',n)if e.listener~=nil then e.listener({type="adReceived",ad="fullscreen"})end
if e.autoshow then
e:show()end
end
local n=Client:new("fullscreens")n:fetch(e.networkListener)end,isLoaded=function(e)return e.htmlUrl~=nil and e.clickUrl~=nil
end,show=function(e)native.setActivityIndicator(false)if not e:isLoaded()then
log("The Fullscreen Ad is not loaded yet to be shown")return
end
e.clickListener=function(n)if string.sub(n.url,-string.len("#close"))=="#close"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
if e.listener~=nil then e.listener({type="adClosed",ad="fullscreen"})end
return false
end
if string.sub(n.url,-string.len("#click"))=="#click"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
if e.listener~=nil then e.listener({type="adClicked",ad="fullscreen"})end
local n=getMarketURL(e.clickUrl)system.openURL(n or e.clickUrl)return false
end
if n.errorCode then
log("Error: "..tostring(n.errorMessage))end
return true
end
local n={hasBackground=false,autoCancel=true,urlRequest=e.clickListener}e.changeOrientationListener=function(t)native.cancelWebPopup()timer.performWithDelay(200,function()native.showWebPopup(e.htmlUrl,n)end)end
timer.performWithDelay(1,function()native.showWebPopup(e.htmlUrl,n)end)Runtime:addEventListener("orientation",e.changeOrientationListener)end,close=function(e)if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
native.cancelWebPopup()end,}FullscreenWeb.__index=FullscreenWeb
end)package.preload['fullscreen_chooser']=(function(...)local n=require('json')require('revmob_client')require('revmob_utils')require('fullscreen')require('fullscreen_web')FullscreenChooser={show=function(e)networkListener=function(t)local t,n=pcall(n.decode,t.response)if(not t or n==nil)then
log("Ad not received.")if e~=nil then e({type="adNotReceived",ad="fullscreen"})end
native.setActivityIndicator(false)return
end
local n=n['fullscreen']['links']local t=getLink('clicks',n)local i=getLink('html',n)local r=getLink('image',n)local n=getLink('close_button',n)if e~=nil then e({type="adReceived",ad="fullscreen"})end
if i then
local e=FullscreenWeb.new({listener=e})e.htmlUrl=i
e.clickUrl=t
e:show()else
Fullscreen.adListener=e
Fullscreen.clickUrl=t
Fullscreen.imageUrl=r
Fullscreen.closeButtonImageUrl=n
timer.performWithDelay(Fullscreen.DELAYED_LOAD_IMAGE,function()display.loadRemoteImage(Fullscreen.imageUrl,"GET",Fullscreen.loadImage,Fullscreen.TMP_IMAGE_NAME,system.TemporaryDirectory)end)end
end
local e=Client:new("fullscreens")e:fetch(networkListener)end,}end)package.preload['banner']=(function(...)local i=require('json')require('revmob_client')require('revmob_utils')Banner={DELAYED_LOAD_IMAGE=10,TMP_IMAGE_NAME="bannerImage.jpg",WIDTH=(Screen:width()>640)and 640 or Screen:width(),HEIGHT=Device:isIPad()and 100 or 50*(Screen.bottom-Screen.top)/display.contentHeight,clickUrl=nil,imageUrl=nil,image=nil,x=nil,y=nil,width=nil,height=nil,listener=nil,new=function(n,e)local e=e or{}setmetatable(e,n)n.__index=n
e.notifyListener=function(n)if e.listener then
e.listener(n)end
end
e.adClick=function(n)e.notifyListener({type="adClicked",ad="banner"})local n=getMarketURL(e.clickUrl)if n then
system.openURL(n)else
system.openURL(e.clickUrl)end
return true
end
e.adTouch=function(n)return true
end
e.update=function(n)if(e.image)then
if(e.image.toFront~=nil)then
e.image:toFront()else
e:release()end
end
end
local t=function(n)if e.image~=nil then
e:release()end
e.image=n.target
e:show()end
local n=function(n)local i,n=pcall(i.decode,n.response)if(not i or n==nil)then
log("Ad not received.")e.notifyListener({type="adNotReceived",ad="banner"})return
end
local n=n['banners'][1]['links']e.clickUrl=getLink('clicks',n)e.imageUrl=getLink('image',n)timer.performWithDelay(e.DELAYED_LOAD_IMAGE,function()display.loadRemoteImage(e.imageUrl,"GET",t,e.TMP_IMAGE_NAME,system.TemporaryDirectory)log("Ad received")e.notifyListener({type="adReceived",ad="banner"})end)end
local t=Client:new("banners")t:fetch(n)return e
end,show=function(e)if e.image~=nil then
e.image.alpha=1
end
e:setDimension()e:setPosition()e.image.tap=e.adClick
e.image.touch=e.adTouch
e.image:addEventListener("tap",e.image)e.image:addEventListener("touch",e.image)Runtime:addEventListener("enterFrame",e.update)end,hide=function(e)if e.image~=nil then
e.image.alpha=0
end
end,release=function(e)log("Releasing event listeners.")Runtime:removeEventListener("enterFrame",e.update)if e.image then
log("Removing image")pcall(e.image.removeEventListener,e.image,"tap",e.image)pcall(e.image.removeEventListener,e.image,"touch",e.image)e.image:removeSelf()end
e.image=nil
end,setPosition=function(e,n,t)e.x=n or e.x
e.y=t or e.y
if e.image then
e.image.x=e.x or(Screen.left+e.WIDTH/2)e.image.y=e.y or(Screen.bottom-e.HEIGHT/2)end
end,setDimension=function(e,n,t)e.width=n or e.width
e.height=t or e.height
if e.image then
e.image.width=e.width or e.WIDTH
e.image.height=e.height or e.HEIGHT
end
end,}end)package.preload['adlink']=(function(...)local e=require('json')require('revmob_client')require('revmob_utils')require('session_manager')AdLink={open=function(e)if RevMobSessionManager.isSessionStarted()then
internalListener=function(n)if(n.statusCode==302)then
local n=getMarketURL(n.headers['location'])or n.headers['location']if n then
if e then e({type="adReceived",ad="link"})end
system.openURL(n)else
if e then e({type="adNotReceived",ad="link",reason="No market url"})end
end
else
if e then e({type="adNotReceived",ad="link",reason="No ads for this device/country"})end
log(tostring(n.statusCode))end
end
local e=Client:new("links")e.post(e:url(),e:payloadAsJsonString(),internalListener)else
log("ERROR: The method RevMob.startSession(REVMOB_IDS) has not been called")if e then e({type="adNotReceived",ad="link",reason="Session was not started"})end
end
end,}end)package.preload['popup']=(function(...)local n=require('json')require('revmob_client')Popup={DELAYED_LOAD_IMAGE=10,YES_BUTTON_POSITION=2,message=nil,click_url=nil,adListener=nil,notifyAdListener=function(e)if Popup.adListener then
Popup.adListener(e)end
end,show=function(e)Popup.adListener=e
client=Client:new("pop_ups")client:fetch(Popup.networkListener)end,networkListener=function(e)local n,e=pcall(n.decode,e.response)if Popup.isParseOk(n,e)then
Popup.message=e["pop_up"]["message"]Popup.click_url=e["pop_up"]["links"][1]["href"]timer.performWithDelay(Popup.DELAYED_LOAD_IMAGE,function()local e=native.showAlert(Popup.message,"",{"No, thanks.","Yes, Sure!"},Popup.click)end)Popup.notifyAdListener({type="adReceived",ad="popup"})else
Popup.notifyAdListener({type="adNotReceived",ad="popup"})end
end,isParseOk=function(n,e)if(not n)then
return false
elseif(e==nil)then
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
if Popup.YES_BUTTON_POSITION==e.index then
Popup.notifyAdListener({type="adClicked",ad="popup"})local e=getMarketURL(Popup.click_url)if e then
system.openURL(e)else
system.openURL(Popup.click_url)end
else
Popup.notifyAdListener({type="adClosed",ad="popup"})end
end
end}end)package.preload['advertiser']=(function(...)local i=require('json')require('revmob_client')require('revmob_utils')require('loadsave')Advertiser={registerInstall=function(n,e)revMobListener=function(t)local i,r=pcall(i.decode,t.response)if(i and t.statusCode==200)then
RevMobPrefs.addItem(n,true)RevMobPrefs.saveToFile()log("Install received.")if e~=nil then
e.notifyAdListener({type="installReceived"})end
else
log("Install not received.")if e~=nil then
e.notifyAdListener({type="installNotReceived"})end
end
end
RevMobPrefs.loadFromFile()local e=RevMobPrefs.getItem(n)if e==true then
log("Install already registered in this device")else
local e=Client:new("",n)e:install(revMobListener)end
end}end)package.preload['loadsave']=(function(...)local n=require('json')RevMobPrefs={FILENAME="revmob_sdk.json",preferences={},getItem=function(e)return RevMobPrefs.preferences[e]or nil
end,addItem=function(n,e)RevMobPrefs.preferences[n]=e
end,saveToFile=function()local e=system.pathForFile(RevMobPrefs.FILENAME,system.DocumentsDirectory)local e=io.open(e,"w")local n=n.encode(RevMobPrefs.preferences)e:write(n)io.close(e)end,loadFromFile=function()local e=system.pathForFile(RevMobPrefs.FILENAME,system.DocumentsDirectory)local e=io.open(e,"r")if e then
local t=e:read("*a")RevMobPrefs.preferences=n.decode(t)if RevMobPrefs.preferences==nil then
RevMobPrefs.preferences={}end
io.close(e)else
RevMobPrefs.saveToFile()RevMobPrefs.loadFromFile()end
end}end)package.preload['session_manager']=(function(...)require("revmob_utils")RevMobSessionManager={listenersRegistered=false,appID=nil,sessionStarted=false,startSession=function(e)if e then
if not RevMobSessionManager.sessionStarted then
RevMobSessionManager.appID=e
RevMobSessionManager.sessionStarted=true
local e=Client:new("")e:startSession()log("Session started for App ID: "..RevMobSessionManager.appID)else
log("Session has already been started for App ID: "..e)end
end
end,sessionManagement=function(e)if e.type=="applicationSuspend"then
RevMobSessionManager.sessionStarted=false
elseif e.type=="applicationResume"then
RevMobSessionManager.startSession(RevMobSessionManager.appID)end
end,isSessionStarted=function()return RevMobSessionManager.sessionStarted
end,}if RevMobSessionManager.listenersRegistered==false then
RevMobSessionManager.listenersRegistered=true
Runtime:removeEventListener("system",RevMobSessionManager.sessionManagement)Runtime:addEventListener("system",RevMobSessionManager.sessionManagement)end end)require('revmob_about')require('revmob_utils')require('revmob_client')require('fullscreen')require('fullscreen_web')require('fullscreen_chooser')require('banner')require('adlink')require('popup')require('advertiser')require('session_manager')local t='4f56aa6e3dc441000e005a20'local n=5e3
local e=function()log("ERROR: The method RevMob.startSession(REVMOB_IDS) has not been called")end
RevMob={getRevMobApplicationID=function(n,e)local e=nil
if Device:isSimulator()then
e=t
log("Using App ID for simulator: "..e)else
e=n[system.getInfo("platformName")]log("App ID: "..tostring(e))end
return e
end,startSession=function(e)RevMobSessionManager.startSession(RevMob.getRevMobApplicationID(e))Advertiser.registerInstall(RevMob.getRevMobApplicationID(e))end,showFullscreen=function(t)if not RevMobSessionManager.isSessionStarted()then return e()end
native.setActivityIndicator(true)showFullscreenInTheNextFrame=function()Runtime:removeEventListener("enterFrame",showFullscreenInTheNextFrame)FullscreenChooser.show(t)end,timer.performWithDelay(n,function()native.setActivityIndicator(false)end)Runtime:addEventListener("enterFrame",showFullscreenInTheNextFrame)end,showFullscreenWeb=function(t)if not RevMobSessionManager.isSessionStarted()then return e()end
native.setActivityIndicator(true)local e=FullscreenWeb.new(t)showFullscreenWebInTheNextFrame=function()Runtime:removeEventListener("enterFrame",showFullscreenWebInTheNextFrame)e:load()end,timer.performWithDelay(n,function()native.setActivityIndicator(false)end)Runtime:addEventListener("enterFrame",showFullscreenWebInTheNextFrame)end,showFullscreenImage=function(e)native.setActivityIndicator(true)showFullscreenImageInTheNextFrame=function()Runtime:removeEventListener("enterFrame",showFullscreenImageInTheNextFrame)Fullscreen.show(e)end,timer.performWithDelay(n,function()native.setActivityIndicator(false)end)Runtime:addEventListener("enterFrame",showFullscreenImageInTheNextFrame)end,openAdLink=function(n)if not RevMobSessionManager.isSessionStarted()then return e()end
AdLink.open(n)end,createBanner=function(n)if not RevMobSessionManager.isSessionStarted()then return e()end
if n==nil then n={}end
return Banner:new(n)end,showPopup=function(n)if not RevMobSessionManager.isSessionStarted()then return e()end
Popup.show(n)end,printEnvironmentInformation=function(e)log("==============================================")log("RevMob Corona SDK: "..REVMOB_SDK["VERSION"])log("App ID in session: "..tostring(RevMobSessionManager.appID))if e then
log("User App ID for Android: "..tostring(e["Android"]))log("User App ID for iOS: "..tostring(e["iPhone OS"]))end
log("Device name: "..system.getInfo("name"))log("Model name: "..system.getInfo("model"))log("Device ID: "..system.getInfo("deviceID"))log("Environment: "..system.getInfo("environment"))log("Platform name: "..system.getInfo("platformName"))log("Platform version: "..system.getInfo("platformVersion"))log("Corona version: "..system.getInfo("version"))log("Corona build: "..system.getInfo("build"))log("Architecture: "..system.getInfo("architectureInfo"))log("Locale-Country: "..system.getPreference("locale","country"))log("Locale-Language: "..system.getPreference("locale","language"))end}