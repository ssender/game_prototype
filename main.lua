
Object = require "classic"
Tile = require "tile"
Player = require "player"
Ball = require "ball"

local time_accumluator = 0

local map = {}
local spr = {}
local balls = {}
local spritesheet = love.graphics.newImage("spritesheet.png")

local move_direction = 0
local input = {}
input.r = {}
input.l = {}
input.u = {}
input.d = {}
input.a = {}
input.r.click = false
input.l.click = false
input.u.click = false
input.d.click = false
input.a.click = false
input.r.down = false
input.l.down = false
input.u.down = false
input.d.down = false
input.a.click = false

love.window.setMode(768, 512)

local you = Player(3, 3)

local function update_input()
    input.r.click = (not input.r.down) and (love.keyboard.isDown("right"))
    input.r.down = love.keyboard.isDown("right")
    input.l.click = (not input.l.down) and (love.keyboard.isDown("left"))
    input.l.down = love.keyboard.isDown("left")
    input.u.click = (not input.u.down) and (love.keyboard.isDown("up"))
    input.u.down = love.keyboard.isDown("up")
    input.d.click = (not input.d.down) and (love.keyboard.isDown("down"))
    input.d.down = love.keyboard.isDown("down")
    input.a.click = (not input.a.down) and (love.keyboard.isDown("z"))
    input.a.down = love.keyboard.isDown("z")
end

local function update_direction()
    update_input()

    if input.r.click then move_direction = 1
    elseif input.l.click then move_direction = 2
    elseif input.u.click then move_direction = 3
    elseif input.d.click then move_direction = 4
    end

    if (move_direction == 1 and (not input.r.down)) 
    or (move_direction == 2 and (not input.l.down)) 
    or (move_direction == 3 and (not input.u.down)) 
    or (move_direction == 4 and (not input.d.down))
    then
        move_direction = 0
    end

    if move_direction == 0 then
        if input.r.down then move_direction = 1
        elseif input.l.down then move_direction = 2
        elseif input.u.down then move_direction = 3
        elseif input.d.down then move_direction = 4
        end
    end
end

local function push_pushable()
    local push_coords = {you.x, you.y}
    local target_coords = {you.x, you.y}
    local xo = 0
    local yo = 0
    if you.facing == 1 then
        push_coords[1] = you.x + 1
        target_coords[1] = you.x + 2
        xo = -32
    elseif you.facing == 2 then
        push_coords[1] = you.x - 1
        target_coords[1] = you.x - 2
        xo = 32
    elseif you.facing == 3 then
        push_coords[2] = you.y - 1
        target_coords[2] = you.y - 2
        yo = 32
    else
        push_coords[2] = you.y + 1
        target_coords[2] = you.y + 2
        yo = -32
    end

    if map[push_coords[1]][push_coords[2]].is_push then
        if target_coords[1] <= 0 or target_coords[1] >= 33 or target_coords[2] <= 0 or target_coords[2] >= 24 then return end
        if map[target_coords[1]][target_coords[2]].is_solid then return end

        local reveal = map[push_coords[1]][push_coords[2]].overtile
        map[push_coords[1]][push_coords[2]].overtile = map[target_coords[1]][target_coords[2]].id
        map[target_coords[1]][target_coords[2]] = map[push_coords[1]][push_coords[2]]
        map[target_coords[1]][target_coords[2]].xo = xo
        map[target_coords[1]][target_coords[2]].yo = yo
        map[push_coords[1]][push_coords[2]] = Tile(reveal)
    elseif map[push_coords[1]][push_coords[2]].id == 1 then
        balls = {}
        balls[1] = Ball(push_coords[1], push_coords[2], you.facing)
    end
end



function love.load()
    local ts = 32
    for y=1,16 do
        for x=1,24 do
            spr[(y-1)*16 + x] = love.graphics.newQuad(x*ts - ts, y*ts - ts, ts, ts, spritesheet)
        end
    end

    local tm = require "tilemap1"
    for x=1,24 do
        map[x] = {}
        for y=1,16 do
            map[x][y] = Tile(tm[x][y])
        end
    end
end

function love.update(dt)
    time_accumluator = time_accumluator + dt
    if time_accumluator < 0.01666667 then return else time_accumluator = time_accumluator - 0.01666667 end

    update_direction()
    you:update(move_direction, map)
    if (not you.moving) and input.a.click then push_pushable() end

    for y=1,16 do
        for x=1,24 do
            map[x][y]:update()
        end
    end

    for i,b in ipairs(balls) do
        if b.active then b:update(map) end
    end
end

function love.draw()
    love.graphics.setColor(0.588, 0.812, 0.486, 1.000)
    love.graphics.rectangle("fill", 0, 0, 768, 512)
    love.graphics.setColor(1.000, 1.000, 1.000, 1.000)

    local layers = {love.graphics.newCanvas(), love.graphics.newCanvas()}

    love.graphics.setCanvas(layers[1])
    for y=1,16 do
        for x=1,24 do
            local image_index = map[x][y].overtile
            if image_index ~= 0 then
                love.graphics.draw(spritesheet, spr[image_index], x*32 - 32, y*32 - 32)
            end
        end
    end

    for y=1,16 do
        for x=1,24 do
            local image_index = map[x][y].img
            love.graphics.setCanvas(layers[map[x][y].draw_layer])
            if image_index ~= 0 then
                love.graphics.draw(spritesheet, spr[image_index], x*32 - 32 + map[x][y].xo, y*32 - 32 + map[x][y].yo)
            end
        end
    end

    love.graphics.setCanvas(layers[2])
    local image_index = 124 + (you.anim_sprite) + 5*you.facing
    love.graphics.draw(spritesheet, spr[image_index], you.ax, you.ay - 2)

    for i,b in ipairs(balls) do
        if b.active then love.graphics.draw(spritesheet, spr[149], 32*b.x - 32, 32*b.y - 44) end
    end

    love.graphics.setCanvas()

    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(layers[1], 0,0)
    love.graphics.draw(layers[2], 0,0)

end