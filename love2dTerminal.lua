utf8 = require 'utf8'

--#special vars--
local Terminal = {}--module
Terminal.acessed = nil--terminal acessed
Terminal.terminals = {}--list of terminals
--#default terminal settings--
Terminal.defaultSettings = {}
Terminal.defaultSettings.user = 'guest'--default username
Terminal.defaultSettings.keys = {}
Terminal.defaultSettings.keys.submit = 'return'
Terminal.defaultSettings.keys.deleteChar = 'backspace'
Terminal.defaultSettings.keys.open = 'f1'

--[[         private          ]]--
--&_tx is number
--&_ty is number
--&_obj is table
local function _isTouchOn(_tx, _ty, _obj)
    if _tx and _ty then
        if _tx > _obj.x and _ty > _obj.y and _tx < _obj.x + _obj.w and _ty < _obj.y + _obj.h then return true
        else return false end
    end
end

--&_str is string
--&_split is string
local function _tokenzin(_str, _split)
    local _t = {}
    
    for _ in string.gmatch(_str, '([^' .. (_split or '%s') .. ']+)') do table.insert(_t, _) end
    
    return _t
end

--[[        public       ]]--
function Terminal:new(_x, _y, _w, _h, _bg, _fg, _userName, _keyOpen, _font, _errorColor)
    --?error tratament
    if _bg then assert(#_bg >= 4, "bad argument #5 in function 'terminal.new' (invalid color)") end
    
    if _fg then assert(#_fg >= 4, "bad argument #6 in function 'terminal.new' (invalid color)") end
    --?func
    local _terminal = setmetatable({}, self)
    --#terminal posit--
    _terminal.x, _terminal.y, _terminal.w, _terminal.h, _terminal.offsetX, _terminal.offsetY = _x or 0, _y or 0, _w or 512, _h or 312, 0, 0
    _terminal.textY, _terminal.textOffsetY = _terminal.y + 36, 0
    --#terminal colors--
    _terminal.bg, _terminal.fg, _terminal.errorColor = _bg or {.5; .5; .5; 1}, _fg or {0; 0; 0; 1}, _errorColor or {1; 0; 0; 1}
    _terminal.userName = _userName or Terminal.defaultSettings.user
    _terminal.keys = {}
    _terminal.keys.submit = Terminal.defaultSettings.keys.submit
    _terminal.keys.deleteChar = Terminal.defaultSettings.keys.deleteChar
    _terminal.keys.open = _keyOpen or Terminal.defaultSettings.keys.open
    _terminal.objects = {}
    _terminal.objects.font = love.graphics.setNewFont(_font or 12)
    _terminal.meta = {}
    _terminal.meta.cmd = ''
    _terminal.meta.terminal = {}
    _terminal.meta.enable = true
    _terminal.meta.draging = false
    _terminal.meta.cmds = {
        {
            name = 'help';
            description = 'show alls avaliables commands';
            func = function()
                _terminal:print("welcome to the love2d terminal, here a menu of commands")
                
                for _, _cmd in ipairs(_terminal.meta.cmds) do
                    _terminal:print(_cmd.name .. "* " .. _cmd.description)
                    _terminal:print("")
                end
            end
        };
        {
            name = 'clear';
            description = 'clean the terminal';
            func = function()
                _terminal.meta.terminal = {}
                _terminal.textY = _terminal.y + 36
                _terminal.textOffsetY = 0
            end 
        };
        {
            name = 'terminal-authdestroy';
            description = 'destroy the terminal';
            func = function() _terminal:destroy() end
        };
        {
            name = 'terminal-settings';
            description = 'terminal width and height and etc';
            func = function(_pack)
                if _pack[1] == 'size' then
                    if _pack[2] then
                        if type(tonumber(_pack[2])) == 'number' then
                            if _pack[3] then
                                if type(tonumber(_pack[3])) == 'number' then
                                    _terminal.w = tonumber(_pack[2])
                                    _terminal.h = tonumber(_pack[3])
                                else _terminal:trace("bad argument #3 (number expected got a invalid value) ") end
                            else _terminal:trace("bad argument #3 (number expected got nil)")  end
                        else _terminal:trace("bad argument #2 (number expected got a invalid value) ") end
                    else _terminal:trace("bad argument #2 (number expected got nil)") end
                elseif _pack[1] == 'color' then
                    if _pack[3] and _pack[4] and _pack[5] then
                        if type(tonumber(_pack[3])) == 'number' then
                            if type(tonumber(_pack[4])) == 'number' then
                                if type(tonumber(_pack[5])) == 'number' then
                                    if _pack[2] == 'bg' then _terminal.bg = {tonumber(_pack[3]) / 255; tonumber(_pack[4]) / 255; tonumber(_pack[5]) / 255; tonumber(_pack[6] or 100) / 100}
                                    elseif _pack[2] == 'fg' then _terminal.fg = {tonumber(_pack[3]) / 255; tonumber(_pack[4]) / 255; tonumber(_pack[5]) / 255; tonumber(_pack[6] or 100) / 100}
                                    else _terminal:trace("bad argument #2 attempt index a color a invalid part") end
                                else _terminal:trace('bad argument to #3 (number expected got invalid value)') end
                            else _terminal:trace('bad argument to #3 (number expected got invalid value)') end
                        else _terminal:trace('bad argument to #3 (number expected got invalid value)') end
                    else _terminal:trace("invalid color") end
                elseif _pack[1] == 'userName' then
                    if _pack[2] then
                        if not string.match(_pack[2], '^%s*$') then _terminal.userName = _pack[2]
                        else _terminal:trace("bad argument #2 userName can't be only spaces") end
                    else _terminal:trace("bad argument #2 (string expected got nil)") end
                else _terminal:trace("bad argument #1 Invalid mode") end
            end
        };
        {
            name = 'terminal-new';
            description = "create a new terminal (but it is temporary)";
            func = function(_pack) Terminal:new() end
        };
        {
            name = 'terminal-new-command';
            description = "registry a costumizable command";
            func = function(_pack)
                if _pack[1] then
                    if string.gmatch(_pack[1], '^%s*$') then
                        if _pack[2] then 
                            if type(_G[_pack[2]]) == 'function' then table.insert(_terminal.meta.cmds, {name = _pack[1]; description = _pack[3] or ""; func = _G[_pack[2]]})
                            else _terminal:trace("bad argument #2 (function expected got a invalid value)") end
                        else _terminal:trace("you need registry a command") end
                    else _terminal:trace("command name can't be only spaces") end
                else _terminal:trace("command name expected got nil") end
            end
        }
    }
    _terminal.registry = {}
    _terminal.registry.traceback = true
    getmetatable(_terminal).__index = self
    table.insert(Terminal.terminals, _terminal)
    _terminal:print("welcome to the love2d terminal, here a menu of commands")
    
    for _, _cmd in ipairs(_terminal.meta.cmds) do 
        _terminal:print(_cmd.name .. "* " .. _cmd.description)
        _terminal:print("")
    end
    
    return _terminal
end

function Terminal.render()
    assert(#Terminal.terminals > 0, "nil terminal initialized")
    
    for _, _terminal in ipairs(Terminal.terminals) do
        if _terminal.meta.enable then
            --#back of window--
            love.graphics.setColor(_terminal.bg)
            love.graphics.rectangle('fill', _terminal.x - _terminal.offsetX, _terminal.y - _terminal.offsetY, _terminal.w, _terminal.h)
            --#window hole--
            love.graphics.setColor(1, 1, 1, _terminal.bg[4] / 2)
            love.graphics.rectangle('fill', _terminal.x + 16 - _terminal.offsetX, _terminal.y + 32 - _terminal.offsetY, _terminal.w - 32, _terminal.h - 112)
            love.graphics.rectangle('fill', _terminal.x + 16 - _terminal.offsetX, _terminal.y - _terminal.offsetY + _terminal.h - 74, _terminal.w - 32, 58)
            love.graphics.rectangle('fill', _terminal.x - _terminal.offsetX, _terminal.y - _terminal.offsetY, _terminal.w, 16)
            love.graphics.setColor(_terminal.fg)
            --#render text--
            love.graphics.print("Terminal", _terminal.x + 16 - _terminal.offsetX, _terminal.y + 4 - _terminal.offsetY)
            
            if #_terminal.meta.terminal > 0 then love.graphics.print(">", _terminal.x + 20 - _terminal.offsetX, _terminal.y - _terminal.offsetY + (_terminal.textY - _terminal.textOffsetY) - _terminal.objects.font:getHeight()) end
            
            love.graphics.printf(_terminal.userName .. "$- " .. _terminal.meta.cmd, _terminal.x + 20 - _terminal.offsetX, _terminal.y + _terminal.h - _terminal.offsetY, _terminal.w - 40, 'left', nil, nil, nil, nil, 70)
            
            for _, _text in ipairs(_terminal.meta.terminal) do
                if not _terminal.stop then
                    love.graphics.setColor(_text.color)
                    love.graphics.printf(_text.msg, _terminal.x + 20 + _terminal.objects.font:getWidth(">") - _terminal.offsetX, _text.y - (_terminal.offsetY + _terminal.textOffsetY), _terminal.w - 40, 'left')
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Terminal.touchpressed(_x, _y)
    assert(#Terminal.terminals > 0, "nil terminal initialized")
    
    for _, _terminal in ipairs(Terminal.terminals) do
        if _isTouchOn(_x, _y, {x = _terminal.x + 16 - _terminal.offsetX; y = _terminal.y - _terminal.offsetX + _terminal.h - 74; w = _terminal.w - 32; h = 58}) then
            love.keyboard.setTextInput(true)
            Terminal.acessed = _terminal.userName
        elseif _isTouchOn(_x, _y, {x = _terminal.x - _terminal.offsetX; y = _terminal.y - _terminal.offsetY; w = _terminal.w; h = 16}) then _terminal.meta.draging = true end
    end
end

function Terminal.touchmoved(_dx, _dy)
    assert(#Terminal.terminals > 0, "nil terminal initialized")
    
    for _, _terminal in ipairs(Terminal.terminals) do
        if _terminal.meta.draging then
            _terminal.offsetX = _terminal.offsetX - _dx
            _terminal.offsetY = _terminal.offsetY - _dy
        end
    end
end

function Terminal.touchreleased()
    assert(#Terminal.terminals > 0, "nil terminal initialized")
    
    for _, _terminal in ipairs(Terminal.terminals) do _terminal.meta.draging = false end
end

function Terminal.textinput(_t)
    assert(#Terminal.terminals > 0, "nil terminal initialized")
    
    for _, _terminal in ipairs(Terminal.terminals) do if _terminal.meta.enable == true and Terminal.acessed == _terminal.userName then _terminal.meta.cmd = _terminal.meta.cmd .. _t end end
end

function Terminal.keypressed(_k)
    assert(#Terminal.terminals > 0, "nil terminal initialized")
    
    for _, _terminal in ipairs(Terminal.terminals) do
        if _terminal.userName == Terminal.acessed then
            if _k == _terminal.keys.deleteChar then
                local _byteOffset = utf8.offset(_terminal.meta.cmd, -1)
                
                if _byteOffset then _terminal.meta.cmd = string.sub(_terminal.meta.cmd ,1, _byteOffset - 1) end
            elseif _k == _terminal.keys.submit then
                _terminal:submit()
            end
        end
        
        if _k == _terminal.keys.open then
            if _terminal.enable then _terminal:enable(false)
            else _terminal:enable(true) end
        end
    end
end

--[[        special functions       ]]--
--&_text is string
--&_color is table
function Terminal:print(_text, _color)
    --?error tratament
    assert(self, "Terminal not initialized")
    if _color then assert(#_color >= 4, "bad argument #2 in function 'terminal.print' (invalid color)") end
    --?func
    local _ftext = {}
    _ftext.y = self.textY
    _ftext.msg = tostring(_text)
    _ftext.color = _color or self.fg
    
    if self.textY >= self.h - 96 and #self.meta.terminal > 0 then 
        local _width, _wrapText = self.objects.font:getWrap(self.meta.terminal[1].msg, self.w - 32)
        self.textOffsetY = self.textOffsetY + self.objects.font:getHeight() * #_wrapText
        table.remove(self.meta.terminal, 1)
    end
    
    table.insert(self.meta.terminal, _ftext)
    
    local _width, _wrapText = self.objects.font:getWrap(self.meta.terminal[1].msg, self.w - 32)
    self.textY = self.textY + self.objects.font:getHeight() * #_wrapText
end

--#enable or desable a console--
--&_bool is a boolean
function Terminal:enable(_bool)
    --?error tratament
    assert(self, "Terminal not initialized")
    assert(type(_bool) == 'boolean', "bad argument in function 'termibal.enable' (boolean expected got " .. type(_bool) .. ")")
    --?func
    self.meta.enable = _bool
end

--#print a error on terminal--
--&_error is string
--%_color is table
function Terminal:trace(_error, _color)
    --?error tratament
    assert(self, "Terminal not initialized")
    if _color then assert(_color >= 4, "bad argument #2 in function 'terminal.trace' (invalid color)") end
    --?func
    self:print(_error, _color or self.errorColor)
end

--#set terminal settings--
--&_userName is string
--&_keys is table
function Terminal:setSettings(_userName, _keys)
    self.userName = _userName or self.userName
    self.keys.submit = _keys.submit or self.keys.submit
    self.keys.deleteChar = _keys.deleteChar or self.keys.deleteChar
    self.keys.open = _keys.open or self.keys.open
end

function Terminal:destroy()
    assert(self, "terminal not initialized")
    
    for _, _terminal in ipairs(Terminal.terminals) do if _terminal == self then table.remove(Terminal.terminals, _) end end
end

--#set de default settings of a console--
--&_userName is string
--&_colors is table
--&_keys is table
function Terminal.setDefaultSettings(_userName, _keys)
    Terminal.defaultSettings.user = _userName
    Terminal.defaultSettings.keys.submit = _keys.submit or Terminal.defaultSettings.keys.submit
    Terminal.defaultSettings.keys.deleteChar = _keys.deleteChar or Terminal.defaultSettings.keys.deleteChar
    Terminal.defaultSettings.keys.open = _keys.open or Terminal.defaultSettings.keys.open
end

--#run a terminal cmd--
--&_cmd is string
function Terminal:run(_cmd)
    --?error tratament
    assert(self, "Terminal not initialized")
    assert(type(_cmd) == 'string', "bad argument in function 'terminal.run' (string expected got " .. type(_cmd) .. ")")
    --?func
    local _tkn = _tokenzin(_cmd, ' ')
    
    for _, _command in ipairs(self.meta.cmds) do
        if _tkn[1] == _command.name then
            table.remove(_tkn, 1)
            local _sucess, _error = pcall(_command.func, _tkn)
            
            if self.registry.traceback and _error then self:trace(_error) end
            
            break
        elseif _ == #self.meta.cmds then
            self:trace("The command not exist")
        end
    end
end

--#submit a command--
function Terminal:submit()
    assert(self, "Terminal not initialized")
    
    if self.meta.enable and not string.match(self.meta.cmd, '^%s*$') then
        self:print(self.meta.cmd)
        self:run(self.meta.cmd)
        self.meta.cmd = ''
    end
end

return Terminal
