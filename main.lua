function love.load(argc, argv)
--#libaries--
    terminal = require 'love2dTerminal'
    
--#cmds--
    test1 = terminal:new(0, 0, nil, nil, {0; 112 / 255; 154 / 255; 1}, nil, 'foxy')
    test2 = terminal:new(128, 0, nil, nil, {0; 112 / 255; 154 / 255; 1}, nil, 'choco')
end

function love.draw()
    terminal.render()
end

function love.update(elapsed)
    
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    terminal.touchpressed(x, y)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    terminal.touchmoved(dx, dy)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    terminal.touchreleased(x, y)
end

function love.keypressed(k)
    terminal.keypressed(k)
end

function love.textinput(t)
    terminal.textinput(t)
end

function dice() test1:print(math.random(1, 6)) end
