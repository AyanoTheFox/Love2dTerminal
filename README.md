# Love2dTerminal
 Love2dTerminal is a bugfix feature from love2d created by **Ayano the fox**
 to be used on love2d engine, start devlopment in _August 7th of 2023_  lest modify _August 9th of 2023_
 last version _0.0.5_

# features
 > free of external dependences  
 > simple installation  
 > costumizable  
 > multiples sessions  
 > fast and powerful  
 > resizable and auto breaking text  
 > registry command feature  
 
# How install
 to install the love2dTerminal fallow all steps
 - require the path with the libary using `terminal = require ('love2dTerminal')`
 - make a new console with `terminal:new(x, y, width, height, backgroundColor, fontgroundColor, username, fontFile, errorColor)`
 - call all functions on your specifc callBack like: `terminal.update()` or `terminal.keypressed(k)`

# installation exemple
```lua
function love.load()
    terminal = require 'love2dTerminal'
    
    exemple1 = terminal:new(0, 0, nil, nil, {0; 112 / 255; 154 / 255; 1}, nil, 'foxy')
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
    terminal.touchreleased()
end

function love.keypressed(k)
    terminal.keypressed(k)
end

function love.textinput(t)
    terminal.textinput(t)
end
```

# print example
 to print on terminal use the command `terminal:print(var or cons)`,
 assuming you installed the console and console var is `terminal1`:
```lua
function love.update(elapsed)
    terminal1:print(elapsed)
end
```

# destroy example
 yes way to destroy a terminal with `terminal:destroy()`,
 following the above exemple
```lua
function love.update(elapsed)
    terminal1:destroy()
end
```

# credits
 AyanoTheFoxy (me:3)
 [strawberryChocolate](https://github.com/Doge2Dev)
 