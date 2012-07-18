package.preload['json']=(function(...)local e=string
local c=math
local s=table
local i=error
local d=tonumber
local u=tostring
local a=type
local o=setmetatable
local r=pairs
local f=ipairs
local l=assert
local n=Chipmunk
module("json")local n={buffer={}}function n:New()local e={}o(e,self)self.__index=self
e.buffer={}return e
end
function n:Append(e)self.buffer[#self.buffer+1]=e
end
function n:ToString()return s.concat(self.buffer)end
local t={backslashes={['\b']="\\b",['\t']="\\t",['\n']="\\n",['\f']="\\f",['\r']="\\r",['"']='\\"',['\\']="\\\\",['/']="\\/"}}function t:New()local e={}e.writer=n:New()o(e,self)self.__index=self
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
function t:WriteString(e)self:Append(u(e))end
function t:ParseString(n)self:Append('"')self:Append(e.gsub(n,'[%z%c\\"/]',function(t)local n=self.backslashes[t]if n then return n end
return e.format("\\u%.4X",e.byte(t))end))self:Append('"')end
function t:IsArray(t)local n=0
local i=function(e)if a(e)=="number"and e>0 then
if c.floor(e)==e then
return true
end
end
return false
end
for e,t in r(t)do
if not i(e)then
return false,'{','}'else
n=c.max(n,e)end
end
return true,'[',']',n
end
function t:WriteTable(e)local i,t,l,n=self:IsArray(e)self:Append(t)if i then
for t=1,n do
self:Write(e[t])if t<n then
self:Append(',')end
end
else
local n=true;for e,t in r(e)do
if not n then
self:Append(',')end
n=false;self:ParseString(e)self:Append(':')self:Write(t)end
end
self:Append(l)end
function t:WriteError(n)i(e.format("Encoding of %s unsupported",u(n)))end
function t:WriteFunction(e)if e==Null then
self:WriteNil()else
self:WriteError(e)end
end
local r={s="",i=0}function r:New(n)local e={}o(e,self)self.__index=self
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
local n={escapes={['t']='\t',['n']='\n',['f']='\f',['r']='\r',['b']='\b',}}function n:New(n)local e={}e.reader=r:New(n)o(e,self)self.__index=self
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
function n:TestReservedWord(n)for l,t in f(n)do
if self:Next()~=t then
i(e.format("Error reading '%s': %s",s.concat(n),self:All()))end
end
end
function n:ReadNumber()local n=self:Next()local t=self:Peek()while t~=nil and e.find(t,"[%+%-%d%.eE]")do
n=n..self:Next()t=self:Peek()end
n=d(n)if n==nil then
i(e.format("Invalid number: '%s'",n))else
return n
end
end
function n:ReadString()local n=""l(self:Next()=='"')while self:Peek()~='"'do
local e=self:Next()if e=='\\'then
e=self:Next()if self.escapes[e]then
e=self.escapes[e]end
end
n=n..e
end
l(self:Next()=='"')local t=function(n)return e.char(d(n,16))end
return e.gsub(n,"u%x%x(%x%x)",t)end
function n:ReadComment()l(self:Next()=='/')local n=self:Next()if n=='/'then
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
function n:ReadArray()local t={}l(self:Next()=='[')local n=false
if self:Peek()==']'then
n=true;end
while not n do
local l=self:Read()t[#t+1]=l
self:SkipWhiteSpace()if self:Peek()==']'then
n=true
end
if not n then
local n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' due to: '%s'",self:All(),n))end
end
end
l(']'==self:Next())return t
end
function n:ReadObject()local r={}l(self:Next()=='{')local t=false
if self:Peek()=='}'then
t=true
end
while not t do
local l=self:Read()if a(l)~="string"then
i(e.format("Invalid non-string object key: %s",l))end
self:SkipWhiteSpace()local n=self:Next()if n~=':'then
i(e.format("Invalid object: '%s' due to: '%s'",self:All(),n))end
self:SkipWhiteSpace()local o=self:Read()r[l]=o
self:SkipWhiteSpace()if self:Peek()=='}'then
t=true
end
if not t then
n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' near: '%s'",self:All(),n))end
end
end
l(self:Next()=="}")return r
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
end)package.preload['revmob_client']=(function(...)local i=require('json')require('revmob_utils')local e="1.3.0"local t='api.bcfads.com'local l='https://'..t
local e='9774d5f368157442'local n='4c6dbc5d000387f3679a53d76f6944211a7f2224'local r=e
Device={identities=nil,country=nil,manufacturer=nil,model=nil,os_version=nil,new=function(n,e)e=e or{}setmetatable(e,n)n.__index=n
e.identities=e:buildDeviceIdentifierAsTable()e.country=system.getPreference("locale","country")e.manufacturer=e:getManufacturer()e.model=e:getModel()e.os_version=system.getInfo("platformVersion")return e
end,isSimulator=function(e)return"simulator"==system.getInfo("environment")end,isAndroid=function(e)return"Android"==system.getInfo("platformName")end,isIphoneOS=function(e)return"iPhone OS"==system.getInfo("platformName")end,isIPad=function(e)return"iPad"==system.getInfo("model")end,getDeviceId=function(e)return(e:isSimulator()and r)or system.getInfo("deviceID")end,buildDeviceIdentifierAsTable=function(e)local e=e:getDeviceId()e=string.gsub(e,"-","")e=string.lower(e)if(string.len(e)==40)then
return{udid=e}elseif(string.len(e)==14 or string.len(e)==15 or string.len(e)==17 or string.len(e)==18)then
return{mobile_id=e}elseif(string.len(e)==16)then
return{android_id=e}else
log("WARNING: device not identified, no registration or popup will work")return nil
end
end,getManufacturer=function(e)local e=system.getInfo("platformName")if(e=="iPhone OS")then
return"Apple"end
return e
end,getModel=function(e)local e=e:getManufacturer()if(e=="Apple")then
return system.getInfo("architectureInfo")end
return system.getInfo("model")end}Client={payload={},adunit=nil,applicationId=nil,hostname=t,device=nil,new=function(e,n,t)local n={adunit=n,applicationId=t,device=Device:new()}setmetatable(n,e)e.__index=e
return n
end,url=function(e)return l.."/api/v4/mobile_apps/"..e.applicationId.."/"..e.adunit.."/fetch.json"end,payloadAsJsonString=function(e)return i.encode({device=e.device})end,post=function(r,e,n)if(e==nil)then
return
end
local l=require('socket.http')local t=require("ltn12")local i={}local l,t,e=l.request{method="POST",url=r,source=t.source.string(e),headers={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"},sink=t.sink.table(i),}local e={statusCode=t,response=i[1],headers=e}if n then
n(e)end
return e
end,fetch=function(e,n)local t=coroutine.create(Client.post)coroutine.resume(t,e:url(),e:payloadAsJsonString(),n)end}end)package.preload['revmob_utils']=(function(...)function log(e)print("[RevMob] "..tostring(e))io.output():flush()end
getLink=function(n,e)for t,e in ipairs(e)do
if e.rel==n then
return e.href
end
end
return nil
end
Screen={left=display.screenOriginX,top=display.screenOriginY,right=display.contentWidth-display.screenOriginX,bottom=display.contentHeight-display.screenOriginY,scaleX=display.contentScaleX,scaleY=display.contentScaleY,width=function(e)return e.right-e.left
end,height=function(e)return e.bottom-e.top
end,}end)package.preload['fullscreen']=(function(...)local n=require('json')require('revmob_client')require('revmob_utils')Fullscreen={CLOSE_BUTTON_X=Device:isIPad()and Screen.right-(50*Screen.scaleX)or Screen.right-(30*Screen.scaleY),CLOSE_BUTTON_Y=Device:isIPad()and Screen.top+(80*Screen.scaleX)or Screen.top+(30*Screen.scaleY),CLOSE_BUTTON_WIDTH=Device:isIPad()and 80*Screen.scaleX or 50*Screen.scaleY,ASSETS_PATH='revmob-assets/fullscreen/',LOCALIZED_MSG={ar="Arabic.jpg",bg="Bulgarian.jpg",cs="Czech.jpg",da="Danish.jpg",de="German.jpg",el="Greek.jpg",en="English.jpg",es="Spanish.jpg",fi="Finnish.jpg",fr="French.jpg",hr="Croatian.jpg",hu="Hungarian.jpg",id="Indonesian.jpg",is="Icelandic.jpg",it="Italian.jpg",ja="Japanese.jpg",ko="Korean.jpg",nb="Norwegian.jpg",pl="Polish.jpg",pt="Portuguese.jpg",ro="Romanian.jpg",ru="Russian.jpg",sv="Swedish.jpg",tr="Turkish.jpg",uk="Ukrainian.jpg",zh="Chinese.jpg"},DELAY=200,getLocalizedMessagePath=function(e)return Fullscreen.ASSETS_PATH..(Fullscreen.LOCALIZED_MSG[e]or Fullscreen.LOCALIZED_MSG["en"])end,language=system.getPreference("locale","language"),adClicked=false,clickUrl=nil,screenGroup=nil,adListener=nil,notifyAdListener=function(e)if Fullscreen.adListener then
Fullscreen.adListener(e)end
end,networkListener=function(e)local n,e=pcall(n.decode,e.response)if(not n or e==nil)then
log("Ad not received.")Fullscreen.notifyAdListener({type="adFailed"})return
end
local e=e['fullscreen']['links']Fullscreen.clickUrl=getLink('clicks',e)Fullscreen.create()log("Ad received.")Fullscreen.notifyAdListener({type="adReceived"})end,release=function(e)Runtime:removeEventListener("enterFrame",Fullscreen.update)Runtime:removeEventListener("system",Fullscreen.onApplicationResume)pcall(Fullscreen.localizedImage.removeEventListener,Fullscreen.localizedImage,"touch",Fullscreen.localizedImage)pcall(Fullscreen.closeButton.removeEventListener,Fullscreen.closeButton,"touch",Fullscreen.closeButton)if Fullscreen.screenGroup then
Fullscreen.screenGroup:removeSelf()Fullscreen.screenGroup=nil
end
Fullscreen.adClicked=false
log("Fullscreen Released.")return true
end,back=function()timer.performWithDelay(Fullscreen.DELAY,Fullscreen.release)return true
end,adClick=function()if not Fullscreen.adClicked then
Fullscreen.adClicked=true
Fullscreen.notifyAdListener({type="adClicked"})system.openURL(Fullscreen.clickUrl)Fullscreen.back()end
return true
end,update=function(e)if(Fullscreen.screenGroup)then
Fullscreen.screenGroup:toFront()end
end,show=function(n,e)Fullscreen.adListener=e
local e=Client:new("fullscreens",n)e:fetch(Fullscreen.networkListener)end,create=function()Fullscreen.screenGroup=display.newGroup()Fullscreen.localizedImage=display.newImageRect(Fullscreen.getLocalizedMessagePath(Fullscreen.language),Screen:width(),Screen:height())Fullscreen.localizedImage.x=display.contentWidth/2
Fullscreen.localizedImage.y=display.contentHeight/2
Fullscreen.localizedImage.touch=function(e,e)Fullscreen.adClick()return true
end
local e=Fullscreen.ASSETS_PATH..'close_button.png'Fullscreen.closeButton=display.newImageRect(e,Fullscreen.CLOSE_BUTTON_WIDTH,Fullscreen.CLOSE_BUTTON_WIDTH)Fullscreen.closeButton.x=Fullscreen.CLOSE_BUTTON_X
Fullscreen.closeButton.y=Fullscreen.CLOSE_BUTTON_Y
Fullscreen.closeButton.touch=function(e,e)Fullscreen.back()Fullscreen.notifyAdListener({type="adClosed"})return true
end
Fullscreen.localizedImage:addEventListener("touch",Fullscreen.localizedImage)Fullscreen.closeButton:addEventListener("touch",Fullscreen.closeButton)Runtime:addEventListener("enterFrame",Fullscreen.update)Runtime:addEventListener("system",Fullscreen.onApplicationResume)Fullscreen.screenGroup:insert(Fullscreen.localizedImage)Fullscreen.screenGroup:insert(Fullscreen.closeButton)end,onApplicationResume=function(e)if e.type=="applicationResume"then
log("Application resumed.")Fullscreen.release()end
end,}end)package.preload['banner']=(function(...)local t=require('json')require('revmob_client')require('revmob_utils')Banner={DELAYED_LOAD_IMAGE=10,TMP_IMAGE_NAME="bannerImage.jpg",WIDTH=(Screen:width()>640)and 640 or Screen:width(),HEIGHT=Device:isIPad()and 100 or 50*(Screen.bottom-Screen.top)/display.contentHeight,clickUrl=nil,imageUrl=nil,image=nil,x=nil,y=nil,width=nil,height=nil,adListener=nil,new=function(n,e)local e=e or{}setmetatable(e,n)n.__index=n
e.notifyAdListener=function(n)if e.adListener then
e.adListener(n)end
end
e.adClick=function(n)e.notifyAdListener({type="adClicked"})system.openURL(e.clickUrl)return true
end
e.update=function(n)if(e.image)then
if(e.image.toFront~=nil)then
e.image:toFront()else
e:release()end
end
end
local i=function(n)if e.image~=nil then
e:release()end
e.image=n.target
e:show()end
local n=function(n)local t,n=pcall(t.decode,n.response)if(not t or n==nil)then
log("Ad not received.")e.notifyAdListener({type="adFailed"})return
end
local n=n['banners'][1]['links']e.clickUrl=getLink('clicks',n)e.imageUrl=getLink('image',n)timer.performWithDelay(e.DELAYED_LOAD_IMAGE,function()display.loadRemoteImage(e.imageUrl,"GET",i,e.TMP_IMAGE_NAME,system.TemporaryDirectory)log("Ad received")e.notifyAdListener({type="adReceived"})end)end
local t=Client:new("banners",e.applicationId)t:fetch(n)return e
end,notifyAdListener=function(e)if self.adListener then
self.adListener(e)end
end,show=function(e)e:setDimension()e:setPosition()e.image.tap=e.adClick
e.image:addEventListener("tap",e.image)Runtime:addEventListener("enterFrame",e.update)end,release=function(e)log("Releasing event listeners.")Runtime:removeEventListener("enterFrame",e.update)if e.image then
log("Removing image")pcall(e.image.removeEventListener,e.image,"tap",e.image)e.image:removeSelf()end
e.image=nil
end,setPosition=function(e,t,n)e.x=t or e.x
e.y=n or e.y
if e.image then
e.image.x=e.x or(Screen.left+e.WIDTH/2)e.image.y=e.y or(Screen.bottom-e.HEIGHT/2)end
end,setDimension=function(e,t,n)e.width=t or e.width
e.height=n or e.height
if e.image then
e.image.width=e.width or e.WIDTH
e.image.height=e.height or e.HEIGHT
end
end,}end)package.preload['adlink']=(function(...)local e=require('json')require('revmob_client')require('revmob_utils')AdLink={open=function(e)local e=Client:new("links",e)local e=e.post(e:url(),e:payloadAsJsonString(),nil)log("Status code: "..e.statusCode)if(e.statusCode==302)then
system.openURL(e.headers['location'])end
end,}end)package.preload['popup']=(function(...)local n=require('json')require('revmob_client')Popup={DELAYED_LOAD_IMAGE=10,YES_BUTTON_POSITION=2,message=nil,click_url=nil,adListener=nil,notifyAdListener=function(e)if Popup.adListener then
Popup.adListener(e)end
end,show=function(e,n)Popup.adListener=n
client=Client:new("pop_ups",e)client:fetch(Popup.networkListener)end,networkListener=function(e)local n,e=pcall(n.decode,e.response)if Popup.isParseOk(n,e)then
Popup.message=e["pop_up"]["message"]Popup.click_url=e["pop_up"]["links"][1]["href"]timer.performWithDelay(Popup.DELAYED_LOAD_IMAGE,function()local e=native.showAlert(Popup.message,"",{"No, thanks.","Yes, Sure!"},Popup.click)end)Popup.notifyAdListener({type="adReceived"})else
Popup.notifyAdListener({type="adFailed"})end
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
Popup.notifyAdListener({type="adClicked"})system.openURL(Popup.click_url)else
Popup.notifyAdListener({type="adClosed"})end
end
end}end)require('revmob_utils')require('fullscreen')require('banner')require('adlink')require('popup')local n='4f56aa6e3dc441000e005a20'RevMob={showPopup=function(t,e)if Device:isSimulator()then
Popup.show(n,e)else
applicationId=t[system.getInfo("platformName")]Popup.show(applicationId,e)end
end,showFullscreen=function(t,e)if Device:isSimulator()then
Fullscreen.show(n,e)else
applicationId=t[system.getInfo("platformName")]Fullscreen.show(applicationId,e)end
end,openAdLink=function(e)if Device:isSimulator()then
AdLink.open(n)else
applicationId=e[system.getInfo("platformName")]AdLink.open(applicationId)end
end,createBanner=function(e,t)if Device:isSimulator()then
e['applicationId']=n
e['adListener']=t
return Banner:new(e)else
e['applicationId']=e[system.getInfo("platformName")]e['adListener']=t
return Banner:new(e)end
end,printEnvironmentInformation=function()log("Device name: "..system.getInfo("name"))log("Model name: "..system.getInfo("model"))log("Device ID: "..system.getInfo("deviceID"))log("Environment: "..system.getInfo("environment"))log("Platform name: "..system.getInfo("platformName"))log("Platform version: "..system.getInfo("platformVersion"))log("Corona version: "..system.getInfo("version"))log("Corona build: "..system.getInfo("build"))log("Architecture: "..system.getInfo("architectureInfo"))end}