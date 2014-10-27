local ffi = require "ffi"
local sdl = require "libs.sdl2.init"
local opengl = require "libs.opengl"

-- Make Sublime Text actually output things as they come.
io.stdout:setvbuf("no")

function main(flags)
	sdl.init(sdl.INIT_EVERYTHING)

	if flags.gl3 then
		sdl.GL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 3)
		sdl.GL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 3)
		sdl.GL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE)
	end

	local window = sdl.createWindow("Test",
		sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
		854, 480,
		bit.bor(
			tonumber(sdl.WINDOW_OPENGL),
			tonumber(sdl.WINDOW_RESIZABLE)
		)
	)
	local ctx = sdl.GL_CreateContext(window)
	sdl.GL_MakeCurrent(window, ctx)

	assert(window)
	assert(ctx)

	opengl.loader = function(fn)
		local ptr = sdl.GL_GetProcAddress(fn)
		-- GURU MEDITATION
		-- print(string.format("Loaded GL function: %s (%s)", fn, tostring(ptr)))
		return ptr
	end
	opengl:import()

	local version = ffi.string(gl.GetString(GL.VERSION))
	local renderer = ffi.string(gl.GetString(GL.RENDERER))

	print(string.format("OpenGL %s on %s", version, renderer))

	-- Useful for figuring out events and such.
	local function translate_sdl(value)
		local translated
		for k,v in pairs(sdl) do
			if value == v then
				translated = k
				break
			end
		end
		return translated or "<unknown>"
	end

	local function handle_events()
		local event = ffi.new("SDL_Event[?]", 1)
		sdl.pollEvent(event)
		event = event[0]
		-- No event, we're done here.
		if event.type == 0 then
			return true
		end

		local handlers = {
			[sdl.KEYDOWN] = function(event)
				print("key down")
				local e = event.key.keysym
				local key = e.sym
				if key == 27 then
					print("GOODBYE MY FRIEND")
					return false
				end
			end
		}

		if handlers[event.type] then
			return handlers[event.type](event)
		end

		print(string.format("Unhandled event type: %s", translate_sdl(event.type)))
		return true
	end

	local start = sdl.getTicks()
	while handle_events() do
		local now = (sdl.getTicks() - start) / 1000

		gl.ClearColor(255, 0, 255, 255)
		gl.Clear(bit.bor(tonumber(GL.COLOR_BUFFER_BIT), tonumber(GL.DEPTH_BUFFER_BIT)))

		sdl.GL_SwapWindow(window)
		sdl.delay(1)
	end

	sdl.GL_MakeCurrent(window, nil)
	sdl.GL_DeleteContext(ctx)
	sdl.destroyWindow(window)

	return 0
end

local flags = {
	gl3 = false
}

for _, v in ipairs{...} do
	for k, _ in pairs(flags) do
		if v == "--" .. k then
			flags[k] = true
		end
	end
end

return main(flags)
