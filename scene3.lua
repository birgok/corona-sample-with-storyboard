---------------------------------------------------------------------------------
--
-- testscreen3.lua
--
---------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local image, text1, text2, text3

local function onSceneTouch( self, event )
	if event.phase == "began" then

		storyboard.gotoScene( "scene4", "fromLeft", 800  )

		return true
	end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view

	image = display.newImage( "assets/bg3.jpg" )
	screenGroup:insert( image )

	image.touch = onSceneTouch

	text1 = display.newText( "Scene 3", 0, 0, native.systemFontBold, 24 )
	text1:setTextColor( 255 )
	text1:setReferencePoint( display.CenterReferencePoint )
	text1.x, text1.y = display.contentWidth * 0.5, 270
	screenGroup:insert( text1 )

	text2 = display.newText( "MemUsage: ", 0, 0, native.systemFont, 16 )
	text2:setTextColor( 255 )
	text2:setReferencePoint( display.CenterReferencePoint )
	text2.x, text2.y = display.contentWidth * 0.5, display.contentHeight * 0.5
	screenGroup:insert( text2 )

	text3 = display.newText( "Touch to continue.", 0, 0, native.systemFontBold, 18 )
	text3:setTextColor( 255 ); text3.isVisible = false
	text3:setReferencePoint( display.CenterReferencePoint )
	text3.x, text3.y = display.contentWidth * 0.5, display.contentHeight - 100
	screenGroup:insert( text3 )

	print( "\n3: createScene event" )
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	print( "3: enterScene event" )

	-- remove previous scene's view
	storyboard.purgeScene( "scene2" )

	-- update Lua memory text display
	local showMem = function()
		image:addEventListener( "touch", image )
		text3.isVisible = true
		text2.text = text2.text .. collectgarbage("count")/1000 .. "MB"
		text2.x = display.contentWidth * 0.5
	end
	local memTimer = timer.performWithDelay( 1000, showMem, 1 )
end


-- Called when scene is about to move offscreen:
function scene:exitScene()

	print( "3: exitScene event" )

	-- remove touch listener for image
	image:removeEventListener( "touch", image )

	-- reset label text
	text2.text = "MemUsage: "
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

	print( "((destroying scene 3's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene