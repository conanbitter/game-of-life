_G.CELL_SIZE = 24
_G.GRID_WIDTH = 50
_G.GRID_HEIGHT = 30
_G.SCREEN_WIDTH = GRID_WIDTH * CELL_SIZE
_G.SCREEN_HEIGHT = GRID_HEIGHT * CELL_SIZE

function love.conf(t)
    t.window.title = "Life"
    t.window.width = SCREEN_WIDTH
    t.window.height = SCREEN_HEIGHT
    t.window.resizable = false
    t.window.minwidth = SCREEN_WIDTH
    t.window.minheight = SCREEN_HEIGHT
    t.window.vsync = 1
    t.identity = "GameOfLife"
end
