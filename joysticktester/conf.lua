function love.conf(t)
	t.identity = nil
	t.appendidentity = false
	t.version = '11.5'
	t.console = false
	t.accelerometerjoystick = true
	t.externalstorage = false
	t.gammacorrect = false

	t.audio.mic = false
	t.audio.mixwithsystem = true

	t.window.title = 'Joystick Tester (Press 0-9 to vibrate all; Use mouse wheel to scroll)'
	t.window.icon = 'graphics/icon/512.png'
	t.window.width = 1600
	t.window.height = 800
	t.window.borderless = false
	t.window.resizable = true
	t.window.minwidth = 400
	t.window.minheight = 200
	t.window.fullscreen = false
	t.window.fullscreentype = 'desktop'
	t.window.vsync = 1
	t.window.msaa = 0
	t.window.depth = nil
	t.window.stencil = nil
	t.window.display = 1
	t.window.highdpi = true
	t.window.usedpiscale = true
	t.window.x = nil
	t.window.y = nil

	t.modules.audio = false
	t.modules.data = false
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = false
	t.modules.system = false
	t.modules.thread = false
	t.modules.timer = true
	t.modules.touch = false
	t.modules.video = false
	t.modules.window = true
end
