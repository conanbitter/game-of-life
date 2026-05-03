if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

---@class Cell
---@field occupied boolean
---@field age number
---@field next boolean

---@type love.Image
local image = nil

---@type love.Quad
local quad_cell = nil

---@type love.Quad
local quad_frame = nil

---@type love.Canvas
local canvas_bg = nil

---@type Cell[][]
local grid = {}

local COLOR_NEW = { 229.0 / 255.0, 57.0 / 255.0, 53.0 / 255.0 }
local COLOR_OLD = { 30.0 / 255.0, 136.0 / 255.0, 229.0 / 255.0 }

local STEP_LENGTH = 0.1
local MAX_LIFE = 20

local pointer_x = -1
local pointer_y = -1
local pointer_button = 0
local pointer_visible = false

local current_time = 0
local playing = false

local offset_x = 0
local offset_y = 0
local old_offset_x = 0
local old_offset_y = 0
local old_x = 0
local old_y = 0

local function lerp_color(color1, color2, k)
    return {
        color1[1] * (1.0 - k) + color2[1] * k,
        color1[2] * (1.0 - k) + color2[2] * k,
        color1[3] * (1.0 - k) + color2[3] * k
    }
end

local function update_pointer(x, y)
    pointer_x = math.floor((x - offset_x) / CELL_SIZE)
    pointer_y = math.floor((y - offset_y) / CELL_SIZE)
    if pointer_x < 0 then pointer_x = pointer_x + GRID_COLS end
    if pointer_y < 0 then pointer_y = pointer_y + GRID_ROWS end
end

local function grid_set(x, y, button)
    if button == 1 and grid[y][x].occupied == false then
        grid[y][x].occupied = true
        grid[y][x].age = 1
    end
    if button == 2 then
        grid[y][x].occupied = false
    end
end

local function grid_get(x, y)
    if x == -1 then
        x = GRID_COLS - 1
    end
    if x == GRID_COLS then
        x = 0
    end
    if y == -1 then
        y = GRID_ROWS - 1
    end
    if y == GRID_ROWS then
        y = 0
    end
    return grid[y][x]
end

local function grid_count_neighbors(x, y)
    local count = 0
    if grid_get(x - 1, y - 1).occupied then count = count + 1 end
    if grid_get(x, y - 1).occupied then count = count + 1 end
    if grid_get(x + 1, y - 1).occupied then count = count + 1 end
    if grid_get(x - 1, y).occupied then count = count + 1 end
    if grid_get(x + 1, y).occupied then count = count + 1 end
    if grid_get(x - 1, y + 1).occupied then count = count + 1 end
    if grid_get(x, y + 1).occupied then count = count + 1 end
    if grid_get(x + 1, y + 1).occupied then count = count + 1 end
    return count
end

local function step()
    for y = 0, GRID_ROWS - 1 do
        for x = 0, GRID_COLS - 1 do
            local cell = grid[y][x]
            local neighbors = grid_count_neighbors(x, y)
            if cell.occupied then
                cell.next = neighbors == 2 or neighbors == 3
            else
                cell.next = neighbors == 3
            end
        end
    end

    for y = 0, GRID_ROWS - 1 do
        for x = 0, GRID_COLS - 1 do
            local cell = grid[y][x]
            if cell.occupied and cell.next and cell.age < MAX_LIFE - 1 then
                cell.age = cell.age + 1
            end
            if cell.next and not cell.occupied then
                cell.age = 1
            end
            cell.occupied = cell.next
        end
    end
end

function love.load()
    image = love.graphics.newImage("life.png")
    local quad_bg = love.graphics.newQuad(0, 0, 24, 24, image)
    quad_cell = love.graphics.newQuad(24, 0, 24, 24, image)
    quad_frame = love.graphics.newQuad(48, 0, 24, 24, image)

    canvas_bg = love.graphics.newCanvas(SCREEN_WIDTH + CELL_SIZE * 2, SCREEN_HEIGHT + CELL_SIZE * 2)
    love.graphics.setCanvas(canvas_bg)
    for y = 0, GRID_ROWS + 1 do
        for x = 0, GRID_COLS + 1 do
            love.graphics.draw(image, quad_bg, x * CELL_SIZE, y * CELL_SIZE)
        end
    end
    love.graphics.setCanvas()

    -- init grid
    for y = 0, GRID_ROWS - 1 do
        grid[y] = {}
        for x = 0, GRID_COLS - 1 do
            grid[y][x] = {
                occupied = false,
                age = 1,
                next = false
            }
        end
    end
end

function love.update(dt)
    if playing then
        current_time = current_time + dt
        while current_time > STEP_LENGTH do
            step()
            current_time = current_time - STEP_LENGTH
        end
    end
end

local function draw_ywrap(x, y, quad)
    if y < SCREEN_HEIGHT then
        love.graphics.draw(image, quad, x, y)
    end
    if y - GRID_HEIGHT + CELL_SIZE > 0 then
        love.graphics.draw(image, quad, x, y - GRID_HEIGHT)
    end
    if y + GRID_HEIGHT < SCREEN_HEIGHT then
        love.graphics.draw(image, quad, x, y + GRID_HEIGHT)
    end
end

local function draw_wrap(x, y, quad)
    if x < SCREEN_WIDTH then
        draw_ywrap(x, y, quad)
    end
    if x - GRID_WIDTH + CELL_SIZE > 0 then
        draw_ywrap(x - GRID_WIDTH, y, quad)
    end
    if x + GRID_WIDTH < SCREEN_WIDTH then
        draw_ywrap(x + GRID_WIDTH, y, quad)
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas_bg, offset_x % CELL_SIZE - CELL_SIZE, offset_y % CELL_SIZE - CELL_SIZE)


    for y = 0, GRID_ROWS - 1 do
        for x = 0, GRID_COLS - 1 do
            local cell = grid[y][x]
            if cell.occupied then
                local k = (cell.age - 1) / (MAX_LIFE - 1)
                local cx = x * CELL_SIZE + offset_x
                local cy = y * CELL_SIZE + offset_y
                love.graphics.setColor(unpack(lerp_color(COLOR_NEW, COLOR_OLD, k)))
                draw_wrap(cx, cy, quad_cell)
            end
        end
    end

    if pointer_visible and not playing then
        love.graphics.setColor(1, 1, 1)
        draw_wrap(CELL_SIZE * pointer_x + offset_x, CELL_SIZE * pointer_y + offset_y, quad_frame)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    update_pointer(x, y)
    if pointer_button ~= 0 then return end

    if button == 3 then
        pointer_button = button
        old_x = x
        old_y = y
        old_offset_x = offset_x
        old_offset_y = offset_y
        pointer_visible = false
    end

    if pointer_visible and not playing then
        grid_set(pointer_x, pointer_y, button)
        if button == 1 or button == 2 then
            pointer_button = button
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    update_pointer(x, y)
    if pointer_visible and not playing then
        if pointer_button == 1 or pointer_button == 2 then
            grid_set(pointer_x, pointer_y, pointer_button)
        end
    end
    if pointer_button == 3 then
        offset_x = (old_offset_x + x - old_x) % GRID_WIDTH
        offset_y = (old_offset_y + y - old_y) % GRID_HEIGHT
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    pointer_button = 0
    pointer_visible = true
end

function love.mousefocus(f)
    pointer_visible = f
end

function love.keypressed(key, scancode, isrepeat)
    if isrepeat then
        return
    end
    --print(key)
    if key == "space" and not playing then
        step()
    elseif key == "return" then
        playing = not playing
        if playing then
            current_time = STEP_LENGTH / 2
            love.window.setTitle("[Playing] Life")
        else
            love.window.setTitle("Life")
        end
    elseif key == "escape" then
        love.event.quit()
    end
end
