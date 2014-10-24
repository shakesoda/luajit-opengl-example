local ffi = require "ffi"
local sdl = require "libs.sdl2.init"
local opengl = require "libs/opengl"

function main()
	sdl.init(sdl.INIT_EVERYTHING)

	sdl.GL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 3)
	sdl.GL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 3)
	sdl.GL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE)

	local window = sdl.createWindow("Test",
		sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
		1280, 720,
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
	local vendor = ffi.string(gl.GetString(GL.VENDOR))
	local renderer = ffi.string(gl.GetString(GL.RENDERER))

	-- print(string.format("%s %s %s", version, vendor, renderer))

	local start = sdl.getTicks()
	while true do
		local now = (sdl.getTicks() - start) / 1000

		gl.ClearColor(255, 0, 255, 255)
		gl.Clear(bit.bor(tonumber(GL.COLOR_BUFFER_BIT), tonumber(GL.DEPTH_BUFFER_BIT)))

		sdl.GL_SwapWindow(window)

		if now > 2.5 then
			break
		end
	end

	sdl.GL_MakeCurrent(window, nil)
	sdl.GL_DeleteContext(ctx)
	sdl.destroyWindow(window)

	return 0
end

return main()
