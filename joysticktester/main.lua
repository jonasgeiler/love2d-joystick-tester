---Resets the color to the default color.
local reset = { 1, 1, 1, 1 }

---Background color.
local bg = { love.math.colorFromBytes(28, 27, 34) }

---Primary foreground color to use for values.
local fgPrimary = { love.math.colorFromBytes(251, 251, 254) }

---Secondary foreground color to use for labels.
local fgSecondary = { love.math.colorFromBytes(142, 209, 219) }

---Decoration color to use for lines and boxes.
local deco = { love.math.colorFromBytes(58, 57, 69) }

---Line height to use for text.
local lineHeight = 1.286

---Font to use for text.
local font = love.graphics.newFont('fonts/martian-mono-1.0.0/stdlt.ttf', 12.5)
font:setFallbacks(love.graphics.newFont(15))
font:setLineHeight(lineHeight)

---Height of the font.
local fontHeight = font:getHeight()

---Real height of the font, including line height.
local fontHeightReal = fontHeight * lineHeight

---Padding around each text column.
local columnPadding = 6

---Text to display when no joysticks are connected.
local noJoysticksText = 'No joysticks connected'

---Colored version of the text when no joysticks are connected.
local noJoysticksTextColored = { fgPrimary, noJoysticksText }

---Width of the text displayed when no joysticks are connected.
local noJoysticksTextWidth = font:getWidth(noJoysticksText)

---Width of the rectangle around the text displayed when no joysticks are connected.
local noJoysticksRectWidth = noJoysticksTextWidth + columnPadding * 2

---Height of the rectangle around the text displayed when no joysticks are connected.
local noJoysticksRectHeight = fontHeight + columnPadding * 2


---Current window dimensions.
local windowWidth, windowHeight = love.graphics.getDimensions()

---Current X position of the text when no joysticks are connected.
local noJoysticksTextX = math.floor((windowWidth - noJoysticksTextWidth) / 2)

---Current Y position of the text when no joysticks are connected.
local noJoysticksTextY = math.floor((windowHeight - fontHeight) / 2)

---Current X position of the rectangle around the text when no joysticks are connected.
local noJoysticksRectX = noJoysticksTextX - columnPadding

---Current Y position of the rectangle around the text when no joysticks are connected.
local noJoysticksRectY = noJoysticksTextY - columnPadding

---Current number of connected joysticks.
local joystickCount = 0

---Current width of each text column.
local columnWidth = windowWidth

---Current width limit for each text column.
local textWidthLimit = columnWidth - columnPadding * 2

---Current Y offset for text columns.
local textOffsetY = columnPadding

---Current Y offset for text columns, floored.
---The `textOffsetY` variable needs to be accurate for recalculation, so we need a seperate floored variable.
local textOffsetYFloored = textOffsetY --no need to floor initially

---Information about a connected Joystick.
---@class (exact) Joystick
---@field id number Unique identifier.
---@field instanceId number Unique instance identifier.
---@field name string Name of the joystick.
---@field guid string Stable GUID unique to the type of the physical joystick.
---@field vendorId number USB vendor ID of the joystick.
---@field productId number USB product ID of the joystick.
---@field productVersion number Product version of the joystick.
---@field isGamepad boolean Whether the Joystick is recognized as a gamepad.
---@field isVibrationSupported boolean Whether the Joystick supports vibration
---@field axisCount number Number of axes on the joystick.
---@field buttonCount number Number of buttons on the joystick.
---@field hatCount number Number of hats on the joystick.
---@field axes table<string, number> Current values of each axis on the joystick.
---@field buttons table<string, boolean> Whether each button on the joystick is currently pressed.
---@field hats table<number, string> Current values of each hat on the joystick.

---Information about all currently connected joysticks.
---@type table<number, Joystick>
local joysticks = {}

---Text to display for each currently connected joystick.
---@type table<number, ([number, number, number, number?] | string)[]>
local joystickTexts = {}

---Number of lines of text in each joystick text.
---@type table<number, number>
local joystickTextsLines = {}

---Current most lines of text in any joystick text. Used for scroll limit.
local joystickTextsLinesMost = 0


---Turns a hat direction into a human-readable description.
---@param direction string Hat direction.
---@return string directionDescription Human-readable hat direction description.
local function getJoystickHatDescription(direction)
	if direction == 'c' then
		return 'Centered'
	elseif direction == 'd' then
		return 'Down'
	elseif direction == 'l' then
		return 'Left'
	elseif direction == 'ld' then
		return 'Left+Down'
	elseif direction == 'lu' then
		return 'Left+Up'
	elseif direction == 'r' then
		return 'Right'
	elseif direction == 'rd' then
		return 'Right+Down'
	elseif direction == 'ru' then
		return 'Right+Up'
	elseif direction == 'u' then
		return 'Up'
	end
	return 'Unknown'
end

---Gets the text to display for a joystick.
---@param joystick Joystick Joystick to get text for.
local function getJoystickText(joystick)
	---@type ([number, number, number, number?] | string)[]
	local text = {
		--Adjust minLines if you add or remove lines here.
		fgSecondary, 'ID: ', fgPrimary, joystick.id .. '\n',
		fgSecondary, 'Instance ID: ', fgPrimary, joystick.instanceId .. '\n',
		fgSecondary, 'Name: ', fgPrimary, joystick.name .. '\n',
		fgSecondary, 'GUID: ', fgPrimary, joystick.guid .. '\n',
		fgSecondary, 'Vendor ID: ', fgPrimary, joystick.vendorId .. '\n',
		fgSecondary, 'Product ID: ', fgPrimary, joystick.productId .. '\n',
		fgSecondary, 'Product Version: ', fgPrimary, joystick.productVersion .. '\n',
		fgSecondary, 'Gamepad: ', fgPrimary, (joystick.isGamepad and 'Yes' or 'No') .. '\n',
		fgSecondary, 'Vibration Supported: ', fgPrimary, (joystick.isVibrationSupported and 'Yes' or 'No') .. '\n',
		fgSecondary, 'Axis Count: ', fgPrimary, joystick.axisCount .. '\n',
		fgSecondary, 'Button Count: ', fgPrimary, joystick.buttonCount .. '\n',
		fgSecondary, 'Hat Count: ', fgPrimary, joystick.hatCount .. '\n',
		fgSecondary, 'Inputs:\n',
	}
	for axis, value in pairs(joystick.axes) do
		local textI = #text + 1
		text[textI] = fgSecondary
		text[textI + 1] = '  Axis "' .. axis .. '": '
		text[textI + 2] = fgPrimary
		text[textI + 3] = value .. '\n'
	end
	for button, isDown in pairs(joystick.buttons) do
		local textI = #text + 1
		text[textI] = fgSecondary
		text[textI + 1] = '  Button "' .. button .. '": '
		text[textI + 2] = fgPrimary
		text[textI + 3] = (isDown and 'Down' or 'Up') .. '\n'
	end
	for hat, direction in pairs(joystick.hats) do
		local textI = #text + 1
		text[textI] = fgSecondary
		text[textI + 1] = '  Hat "' .. hat .. '": '
		text[textI + 2] = fgPrimary
		text[textI + 3] = getJoystickHatDescription(direction) .. '\n'
	end

	return text
end

---Updates the `textOffsetY`, and `textOffsetYFloored` variables.
---Should be called when `joystickTextsLinesMost` changes, or mouse wheel is moved.
---@param changeY? number Amount to change the Y offset by.
local function updateTextOffsetYVars(changeY)
	changeY = changeY or 0

	textOffsetY = math.max(
		math.min(
			(textOffsetY - columnPadding) / fontHeightReal + changeY,
			0
		),
		2 - joystickTextsLinesMost
	) * fontHeightReal + columnPadding

	textOffsetYFloored = math.floor(textOffsetY)
end

---Updates the `joystickTextsLines`, and `joystickTextsLinesMost` variables.
---Should be called when `joystickTexts` or `textWidthLimit` changes.
---@param id? number ID of the joystick to update the lines for.
local function updateJoystickTextsLinesVars(id)
	if id then
		--only update line count for one joystick
		---@diagnostic disable-next-line: param-type-mismatch
		local _, linesTbl = font:getWrap(joystickTexts[id], textWidthLimit)
		local lines = #linesTbl
		joystickTextsLines[id] = lines

		--when lines equal most lines we don't need to do anything
		if lines > joystickTextsLinesMost then
			--lines will always be the new most lines, so just update most lines
			joystickTextsLinesMost = lines
			updateTextOffsetYVars()
		elseif lines < joystickTextsLinesMost then
			--joystick might have had the most lines and now has fewer, so we have to check all texts and update most lines if needed
			local linesMost = 0
			for _, ls in pairs(joystickTextsLines) do
				if ls > linesMost then
					linesMost = ls
				end
			end
			if linesMost ~= joystickTextsLinesMost then
				joystickTextsLinesMost = linesMost
				updateTextOffsetYVars()
			end
		end
	else
		--just update all line counts and update most lines if needed
		local linesMost = 0
		for id2, text in pairs(joystickTexts) do
			---@diagnostic disable-next-line: param-type-mismatch
			local _, linesTbl = font:getWrap(text, textWidthLimit)
			local lines = #linesTbl
			joystickTextsLines[id2] = lines

			if lines > linesMost then
				linesMost = lines
			end
		end
		if linesMost ~= joystickTextsLinesMost then
			joystickTextsLinesMost = linesMost
			updateTextOffsetYVars()
		end
	end
end

---Updates the `joystickTexts` variable.
---Should be called when `joysticks` changes.
---@param id number ID of the joystick to update the text for.
local function updateJoystickTexts(id)
	joystickTexts[id] = getJoystickText(joysticks[id])
	updateJoystickTextsLinesVars(id)
end

---Updates the `columnWidth` and `textWidthLimit` variables.
---Should be called when `windowWidth` or `joystickCount` changes.
local function updateColumnWidthAndTextWidthLimit()
	if joystickCount == 0 then
		columnWidth = windowWidth
	else
		columnWidth = math.floor(windowWidth / joystickCount)
	end

	textWidthLimit = columnWidth - columnPadding * 2
	updateJoystickTextsLinesVars()
end

---Updates the `joystickCount` variable.
---Should be called when joysticks are connected or disconnected.
local function updateJoystickCount()
	joystickCount = love.joystick.getJoystickCount()
	updateColumnWidthAndTextWidthLimit()
end

---Updates the `noJoysticksTextX`, `noJoysticksTextY`, `noJoysticksRectX`, and `noJoysticksRectY` variables.
---Should be called when `windowWidth` changes.
local function updateNoJoysticksVars()
	noJoysticksTextX = math.floor((windowWidth - noJoysticksTextWidth) / 2)
	noJoysticksTextY = math.floor((windowHeight - fontHeight) / 2)
	noJoysticksRectX = noJoysticksTextX - columnPadding
	noJoysticksRectY = noJoysticksTextY - columnPadding
end

---Set vibration of all connected joysticks.
---@param left? number Left motor strength.
---@param right? number Right motor strength.
local function setAllJoysticksVibration(left, right)
	local rawJoysticks = love.joystick.getJoysticks() ---@type table<number, love.Joystick>
	for _, rawJoystick in pairs(rawJoysticks) do
		if rawJoystick:isVibrationSupported() then
			---@diagnostic disable-next-line: param-type-mismatch
			rawJoystick:setVibration(left, right)
		end
	end
end


---Called once at the beginning of the game.
function love.load()
	love.graphics.setBackgroundColor(bg)
	love.graphics.setFont(font)
end

---Called to draw on screen every frame.
function love.draw()
	if joystickCount == 0 then
		love.graphics.setColor(deco)
		love.graphics.rectangle('line', noJoysticksRectX, noJoysticksRectY, noJoysticksRectWidth, noJoysticksRectHeight)
		love.graphics.setColor(reset)
		love.graphics.print(noJoysticksTextColored, noJoysticksTextX, noJoysticksTextY)
		return
	end

	local i = 0
	for _, joystickText in pairs(joystickTexts) do
		if i ~= 0 then
			love.graphics.setColor(deco)
			love.graphics.line(columnWidth * i, 0, columnWidth * i, windowHeight)
			love.graphics.setColor(reset)
		end
		love.graphics.printf(joystickText, columnWidth * i + columnPadding, textOffsetYFloored, textWidthLimit)

		i = i + 1
	end
end

---Called when the window is resized.
---@param w number New window width.
---@param h number New window height.
function love.resize(w, h)
	windowWidth, windowHeight = w, h
	updateNoJoysticksVars()
	updateColumnWidthAndTextWidthLimit()
end

---Called when a key is pressed.
---@param key love.KeyConstant Key that was pressed.
function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'return' or key == '0' or key == 'kp0' then
		setAllJoysticksVibration(1, 1)
	elseif key == '1' or key == 'kp1' then
		setAllJoysticksVibration(0.1, 0.1)
	elseif key == '2' or key == 'kp2' then
		setAllJoysticksVibration(0.2, 0.2)
	elseif key == '3' or key == 'kp3' then
		setAllJoysticksVibration(0.3, 0.3)
	elseif key == '4' or key == 'kp4' then
		setAllJoysticksVibration(0.4, 0.4)
	elseif key == '5' or key == 'kp5' then
		setAllJoysticksVibration(0.5, 0.5)
	elseif key == '6' or key == 'kp6' then
		setAllJoysticksVibration(0.6, 0.6)
	elseif key == '7' or key == 'kp7' then
		setAllJoysticksVibration(0.7, 0.7)
	elseif key == '8' or key == 'kp8' then
		setAllJoysticksVibration(0.8, 0.8)
	elseif key == '9' or key == 'kp9' then
		setAllJoysticksVibration(0.9, 0.9)
	end
end

---Called when a key is released.
---@param key love.KeyConstant Key that was released.
function love.keyreleased(key)
	if
		key == 'return' or
		key == '0' or key == 'kp0' or
		key == '1' or key == 'kp1' or
		key == '2' or key == 'kp2' or
		key == '3' or key == 'kp3' or
		key == '4' or key == 'kp4' or
		key == '5' or key == 'kp5' or
		key == '6' or key == 'kp6' or
		key == '7' or key == 'kp7' or
		key == '8' or key == 'kp8' or
		key == '9' or key == 'kp9'
	then
		setAllJoysticksVibration()
	end
end

---Called when the mouse wheel is moved.
---@param y number Amount of vertical mouse wheel movement.
function love.wheelmoved(_, y)
	updateTextOffsetYVars(y)
end

---Called when a Joystick is connected.
---@param joystick love.Joystick Newly connected Joystick object.
function love.joystickadded(joystick)
	local id, instanceId = joystick:getID()
	local name = joystick:getName()
	local guid = joystick:getGUID()
	local vendorId, productId, productVersion = joystick:getDeviceInfo()
	local isGamepad = joystick:isGamepad()
	local isVibrationSupported = joystick:isVibrationSupported()
	local axisCount = joystick:getAxisCount()
	local buttonCount = joystick:getButtonCount()
	local hatCount = joystick:getHatCount()
	local axes = {} ---@type table<string, number>
	local buttons = {} ---@type table<string, boolean>
	local hats = {} ---@type table<number, string>
	if isGamepad then
		axes['leftx'] = joystick:getGamepadAxis('leftx')
		axes['lefty'] = joystick:getGamepadAxis('lefty')
		axes['rightx'] = joystick:getGamepadAxis('rightx')
		axes['righty'] = joystick:getGamepadAxis('righty')
		axes['triggerleft'] = joystick:getGamepadAxis('triggerleft')
		axes['triggerright'] = joystick:getGamepadAxis('triggerright')
		buttons['a'] = joystick:isGamepadDown('a')
		buttons['b'] = joystick:isGamepadDown('b')
		buttons['x'] = joystick:isGamepadDown('x')
		buttons['y'] = joystick:isGamepadDown('y')
		buttons['back'] = joystick:isGamepadDown('back')
		buttons['guide'] = joystick:isGamepadDown('guide')
		buttons['start'] = joystick:isGamepadDown('start')
		buttons['leftstick'] = joystick:isGamepadDown('leftstick')
		buttons['rightstick'] = joystick:isGamepadDown('rightstick')
		buttons['leftshoulder'] = joystick:isGamepadDown('leftshoulder')
		buttons['rightshoulder'] = joystick:isGamepadDown('rightshoulder')
		buttons['dpup'] = joystick:isGamepadDown('dpup')
		buttons['dpdown'] = joystick:isGamepadDown('dpdown')
		buttons['dpleft'] = joystick:isGamepadDown('dpleft')
		buttons['dpright'] = joystick:isGamepadDown('dpright')
		--TODO: Uncomment after LÖVE 12.0
		--buttons['misc1'] = joystick:isGamepadDown('misc1')
		--buttons['paddle1'] = joystick:isGamepadDown('paddle1')
		--buttons['paddle2'] = joystick:isGamepadDown('paddle2')
		--buttons['paddle3'] = joystick:isGamepadDown('paddle3')
		--buttons['paddle4'] = joystick:isGamepadDown('paddle4')
		--buttons['touchpad'] = joystick:isGamepadDown('touchpad')
	else
		for i = 1, axisCount do
			axes[tostring(i)] = joystick:getAxis(i)
		end
		for i = 1, buttonCount do
			buttons[tostring(i)] = joystick:isDown(i)
		end
		for i = 1, hatCount do
			hats[i] = joystick:getHat(i)
		end
	end

	joysticks[id] = {
		id = id,
		instanceId = instanceId,
		name = name,
		guid = guid,
		vendorId = vendorId,
		productId = productId,
		productVersion = productVersion,
		isGamepad = isGamepad,
		isVibrationSupported = isVibrationSupported,
		axisCount = axisCount,
		buttonCount = buttonCount,
		hatCount = hatCount,
		axes = axes,
		buttons = buttons,
		hats = hats,
	}
	updateJoystickTexts(id)
	updateJoystickCount() --unfortunately this will also call updateJoystickTextsLinesVars()
end

---Called when a Joystick is disconnected.
---@param joystick love.Joystick Now-disconnected Joystick object.
function love.joystickremoved(joystick)
	local id = joystick:getID()

	if joysticks[id] then
		joysticks[id] = nil
	end
	if joystickTexts[id] then
		joystickTexts[id] = nil
	end
	if joystickTextsLines[id] then
		joystickTextsLines[id] = nil
	end
	updateJoystickCount()
	--updateJoystickTextsLinesVars() --not needed because updateJoystickCount() calls it
end

---Called when a joystick axis moves.
---@param joystick love.Joystick Joystick object.
---@param axis number Axis number.
---@param value number New axis value.
function love.joystickaxis(joystick, axis, value)
	local id = joystick:getID()
	if not joysticks[id] or joysticks[id].isGamepad then return end

	joysticks[id].axes[tostring(axis)] = value
	updateJoystickTexts(id)
end

---Called when a Joystick's virtual gamepad axis is moved.
---@param joystick love.Joystick Joystick object.
---@param axis string Virtual gamepad axis.
---@param value number New axis value.
function love.gamepadaxis(joystick, axis, value)
	local id = joystick:getID()
	if not joysticks[id] or not joysticks[id].isGamepad then return end

	joysticks[id].axes[axis] = value
	updateJoystickTexts(id)
end

---Called when a joystick button is pressed.
---@param joystick love.Joystick Joystick object.
---@param button number Button number.
function love.joystickpressed(joystick, button)
	local id = joystick:getID()
	if not joysticks[id] or joysticks[id].isGamepad then return end

	joysticks[id].buttons[tostring(button)] = true
	updateJoystickTexts(id)
end

---Called when a Joystick's virtual gamepad button is pressed.
---@param joystick love.Joystick Joystick object.
---@param button string Virtual gamepad button.
function love.gamepadpressed(joystick, button)
	local id = joystick:getID()
	if not joysticks[id] or not joysticks[id].isGamepad then return end

	joysticks[id].buttons[button] = true
	updateJoystickTexts(id)
end

---Called when a joystick button is released.
---@param joystick love.Joystick Joystick object.
---@param button number Button number.
function love.joystickreleased(joystick, button)
	local id = joystick:getID()
	if not joysticks[id] or joysticks[id].isGamepad then return end

	joysticks[id].buttons[tostring(button)] = false
	updateJoystickTexts(id)
end

---Called when a Joystick's virtual gamepad button is released.
---@param joystick love.Joystick Joystick object.
---@param button string Virtual gamepad button.
function love.gamepadreleased(joystick, button)
	local id = joystick:getID()
	if not joysticks[id] or not joysticks[id].isGamepad then return end

	joysticks[id].buttons[button] = false
	updateJoystickTexts(id)
end

---Called when a joystick hat direction changes.
---@param joystick love.Joystick Joystick object.
---@param hat number Hat number.
---@param direction string New hat direction.
function love.joystickhat(joystick, hat, direction)
	local id = joystick:getID()
	if not joysticks[id] or joysticks[id].isGamepad then return end

	joysticks[id].hats[hat] = direction
	updateJoystickTexts(id)
end
