if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

---@type love.Image
local image = nil

---@type love.Quad
local quad_cell = nil

---@type love.Quad
local quad_frame = nil

---@type love.Canvas
local canvas_bg = nil

function love.load()
    image = love.graphics.newImage("life.png")
    local quad_bg = love.graphics.newQuad(0, 0, 24, 24, image)
    quad_cell = love.graphics.newQuad(24, 0, 24, 24, image)
    quad_frame = love.graphics.newQuad(48, 0, 24, 24, image)

    canvas_bg = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setCanvas(canvas_bg)
    for y = 0, GRID_HEIGHT - 1 do
        for x = 0, GRID_WIDTH - 1 do
            love.graphics.draw(image, quad_bg, x * CELL_SIZE, y * CELL_SIZE)
        end
    end
    love.graphics.setCanvas()
end

function love.update(dt)

end

function love.draw()
    love.graphics.draw(canvas_bg)

    love.graphics.draw(image, quad_cell, 24 * 3, 24)

    love.graphics.draw(image, quad_frame, 24 * 5, 24)
end

function love.mousepressed(x, y, button, istouch, presses)

end

function love.mousemoved(x, y, dx, dy, istouch)

end

function love.mousereleased(x, y, button, istouch, presses)

end
