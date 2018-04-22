local joysticks = {}
local currentJoystick = 1

function love.joystickadded(joystick)
    	newJoystick = {}
	newJoystick.name = joystick:getName()
	newJoystick.axesNum = joystick:getAxisCount()
	newJoystick.buttonsNum = joystick:getButtonCount()
	newJoystick.hatsNum = joystick:getHatCount()
	newJoystick.guid = joystick:getGUID()
	newJoystick.id = joystick:getID()
	if joystick:isVibrationSupported() then newJoystick.hasVibration = "Yes" else newJoystick.hasVibration = "No" end
	if joystick:isGamepad() then newJoystick.isGamepad = "Yes" else newJoystick.isGamepad = "No" end
	newJoystick.obj = joystick
	
	joysticks[newJoystick.id] = newJoystick
end

function love.draw()
	text = "Press space to go to next Joystick!\nPress enter to let the controller vibrate!\n\n"
	
	if love.joystick.getJoystickCount() == 0 then
		text = text .. "No Joysticks connected."
		love.graphics.print(text, 10, 10)
		return
	end
	
	text = text .. "Joysticks connected: " .. love.joystick.getJoystickCount() .. "\n\n"
	
	joystick = joysticks[currentJoystick]
	text = text .. "Joystick " .. currentJoystick .. " - " .. joystick.name .. ":\n"
	
	if not joystick.obj:isConnected() then
		text = text .. "    Joystick not connected."
		love.graphics.print(text, 10, 10)
		return
	end
	
	text = text .. "    GUID: " .. joystick.guid .. "\n"
	text = text .. "    ID: " .. joystick.id .. "\n"
	text = text .. "    Number of Axes: " .. joystick.axesNum .. "\n"
	text = text .. "    Number of Buttons: " .. joystick.buttonsNum .. "\n"
	text = text .. "    Number of Hats: " .. joystick.hatsNum .. "\n"
	text = text .. "    Has Vibration: " .. joystick.hasVibration .. "\n"
	text = text .. "    Is Gamepad: " .. joystick.isGamepad .. "\n\n"
	text = text .. "    Input:\n"
	
	for i=1,joystick.buttonsNum do
		isDown = tostring(joystick.obj:isDown(i))
		text = text .. "        Button " .. i .. ": " .. isDown .. "\n"
	end
	text = text .. "\n"
	for i=1,joystick.axesNum do
		direction = tostring(joystick.obj:getAxis(i))
		text = text .. "        Axes " .. i .. ": " .. direction .. "\n"
	end
	text = text .. "\n"
	for i=1,joystick.hatsNum do
		direction = tostring(joystick.obj:getHat(i))
		
		if direction == "c" then
			direction = "Centered"
		elseif direction == "d" then
			direction = "Down"
		elseif direction == "l" then
			direction = "Left"
		elseif direction == "ld" then
			direction = "Left+Down"
		elseif direction == "lu" then
			direction = "Left+Up"
		elseif direction == "r" then
			direction = "Right"
		elseif direction == "rd" then
			direction = "Right+Down"
		elseif direction == "ru" then
			direction = "Right+Up"
		elseif direction == "u" then
			direction = "Up"
		end
		
		text = text .. "        Hat " .. i .. ": " .. direction .. "\n"
	end
	
	love.graphics.print(text, 10, 10)
end

function love.keypressed(key)
	if key == "space" then
		currentJoystick = currentJoystick + 1
		if currentJoystick > #joysticks then
			currentJoystick = 1
		end
	elseif key == "return" then
		if love.joystick.getJoystickCount() > 0 and joysticks[currentJoystick].obj:isVibrationSupported() then
			for i=0, 1, 0.1 do
				joysticks[currentJoystick].obj:setVibration(i, i, i/2)
				love.timer.sleep(i / 2)
			end
			joysticks[currentJoystick].obj:setVibration()
		end
	end
end
