-- The snake's segments
local segments = {} -- First element is the head, and the last is the tail

local dimension = 40 -- 20 squares of movement
local px = 16 -- This can be changed, but this is just to start

local stopped = false

local start_fps = 1/15 -- The base fps
local fps = start_fps -- The game updates once every "fps" of a second
local time_til_next_move = fps;

-- A vector2 just holds two numbers
-- This is useful for a lot of parts in a 2d game
function new_vector2(X, Y)
    return {
        x = X,
        y = Y
    }
end

-- This is EVERY direciton (only 4 lol)
local directions =
{
    up = new_vector2(0, -1),
    down = new_vector2(0, 1),
    left = new_vector2(-1, 0),
    right = new_vector2(1, 0)
}

local padding = px / 8 -- Smqall padding to the snake

local movement = {} -- Where you are going to go
-- Basically a queue for movement
-- First index is the current direction


-- Update game (every frame)
-- dt is the amount of time since last call of love.update
function love.update(dt)
    -- Wait until it is time to move
    time_til_next_move = time_til_next_move - dt
    local continue = false
    if time_til_next_move <= 0 then
        continue = true
        time_til_next_move = fps
    end
    -- Long ahh condition
    if continue and #segments > 0 and movement[1] and not stopped then
        -- Find where the player is going to move
        local current_direction
        if #movement > 1 then
            table.remove(movement, 1)
        end
        current_direction = movement[1]
        local head = segments[1]
        local new_head = new_vector2(head.x + current_direction.x, head.y + current_direction.y)

        -- Check for intersection
        if #segments > 1 and does_overlaps_segment(new_head, #segments-1) or is_off_screen(new_head) then
            stopped = true
            movement = {}
            return -- Stop execution early
        end
        -- Put the head where it should be
        table.insert(segments, 1, new_vector2(new_head.x, new_head.y))
    end
end

-- Draw the game each frame
function love.draw()
    love.graphics.setLineStyle("rough")
    local temp_pad = padding
    -- PULSE with the music!!!
    -- Draw the shadows
    for i = 1, #segments do
        -- Find the segments that we will use to draw
        local seg = segments[i]
        local next_seg = segments[i]
        if i < #segments then
            next_seg = segments[i+1]
        end
        -- Coordinates of pieces
        local x = seg.x * px
        local y = seg.y * px
        local next_x = next_seg.x * px
        local next_y = next_seg.y * px
        local padded_x = x + padding
        local padded_y = y + padding
        local reverse_pad = px - 2 * padding
        -- Draw the rectangle for the segment
        love.graphics.setColor(0.2,0.2,0.2) -- Gray background
        love.graphics.rectangle("fill", padded_x + px/4, padded_y + px/4, reverse_pad, reverse_pad)
        -- Draw the connecting line
        love.graphics.setLineWidth(px - 3 * padding)
        --love.graphics.line(x + 3*px/4, y + 3*px/4, next_x + 3*px/4, next_y + 3*px/4)
        love.graphics.setColor(0.6,0.6,0.6) -- Full white
        if i == 1 then
            love.graphics.setColor(1,1,1) -- Full white
        end
        love.graphics.rectangle("fill", padded_x, padded_y, reverse_pad, reverse_pad)
        -- Draw the connecting line
        love.graphics.setLineWidth(px - 3 * padding)
    end
    -- Draw the food
    -- Display the score
    -- Score also bounces
    love.graphics.setColor(0,1,0) -- Green
    --love.graphics.print("Score: "..#segments, 2 * temp_pad - padding, 2 * temp_pad - padding)
    padding = temp_pad
end

-- Called on execution
function love.load()
    math.randomseed(os.time()) -- Set this to a random seed
    love.window.setTitle("SNAKE")
    -- Load a font for the game to use
    local font = love.graphics.newFont("Omnisweeper.otf", px)
    love.window.setMode(dimension*px, dimension*px, {resizable = false}) -- Window properties
    love.graphics.setFont(font) -- Set the font
    new_game() -- Finally a new game
end

-- Make a new game when the player loses
function new_game()
    fps = start_fps
    movement = {} -- No movement to start
    segments = {} -- clear the segments table
    table.insert(segments, new_vector2(math.floor(dimension / 2), math.floor(dimension / 2))) -- Head
end

-- Helper method for the table
-- Make sure segments don't overlap
function does_overlaps_segment(pos, upto)
    -- Check for the argument, and if it doesnt exist, then upto is #segments
    if upto == nil then upto = #segments end
    for i = 1, upto do
        local seg = segments[i]
        if (seg.x == pos.x and seg.y == pos.y) then
            return true
        end
    end
    return false
end

-- Check if a place is offscreen
function is_off_screen(pos)
    return (pos.x < 0 or pos.y < 0 or pos.y >= dimension or pos.x >= dimension)
end

-- Detect player input
function love.keypressed(key)
    -- Start the game if it is stopped
    if stopped then
        stopped = false
        movement = {}
        new_game()
        return
    end
    local short = #movement <= 2 -- The player DOESN'T know best
    -- Only a few inputs can be queued at a time
    -- Use the direction that the player inputs
    if short then
        -- Add inputs to the queue
        if (key == "right" or key == "d") and (movement[#movement] ~= directions.left and movement[#movement] ~= directions.right) then
            table.insert(movement, directions.right)
        end
        if (key == "left" or key == "a") and (movement[#movement] ~= directions.right and movement[#movement] ~= directions.left) then
            table.insert(movement, directions.left)
        end
        if (key == "up" or key == "w") and (movement[#movement] ~= directions.down and movement[#movement] ~= directions.up) then
            table.insert(movement, directions.up)
        end
        if (key == "down" or key == "s") and (movement[#movement] ~= directions.up and  movement[#movement] ~= directions.down) then
            table.insert(movement, directions.down)
        end
    end
end
