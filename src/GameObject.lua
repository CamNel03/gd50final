--[[
    GD50
    -- Super Mario Bros. Remake --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def)
    self.x = def.x
    self.y = def.y
    self.texture = def.texture
    self.width = def.width
    self.height = def.height
    self.frame = def.frame
    self.solid = def.solid
    self.collidable = def.collidable
    self.consumable = def.consumable
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.hit = def.hit
    self.damage = def.damage
    self.projectile = false
    self.direction = nil
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
            target.y > self.y + self.height or self.y > target.y + target.height)
end

function GameObject:update(dt)
    if projectile then
        if self.direction == 'right' then
            self.x = self.x + 30
        else
            self.x = self.x - 30
        end

    end
end

function GameObject:render()
    -- don't attempt to render object with no texture i.e. our collision box for flag
    if self.texture ~= nil then
        -- for the flag render it reversed it should also flip on y axis but it won't
        if self.texture == 'flags' then
            love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y, 0, -1, -1)
        else
            love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
        end
    end
end