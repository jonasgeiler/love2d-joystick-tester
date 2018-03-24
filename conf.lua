function love.conf(t)
	t.window.title = "LÖVE - Joystick Tester"
	t.window.width = 400
	t.window.height = 800
	t.window.resizable = true
	
	-- Disable some modules not needed (Probably there are more that I can disable but meh)
	t.modules.audio = false
	t.modules.physics = false
	t.modules.sound = false
	t.modules.touch = false
end
