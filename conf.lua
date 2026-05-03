_G.CELL_SIZE = 24
_G.GRID_COLS = 50
_G.GRID_ROWS = 30
--_G.GRID_WIDTH = 80
--_G.GRID_HEIGHT = 45
_G.GRID_WIDTH = GRID_COLS * CELL_SIZE
_G.GRID_HEIGHT = GRID_ROWS * CELL_SIZE
_G.SCREEN_WIDTH = GRID_COLS * CELL_SIZE + 10
_G.SCREEN_HEIGHT = GRID_ROWS * CELL_SIZE + 10

function love.conf(t)
    t.window.title = "Life"
    t.window.width = SCREEN_WIDTH
    t.window.height = SCREEN_HEIGHT
    t.window.resizable = false
    t.window.minwidth = SCREEN_WIDTH
    t.window.minheight = SCREEN_HEIGHT
    t.window.vsync = 1
    t.identity = "GameOfLife"
    --    t.window.fullscreen = true
end
