
PinkFallingState = Class{__includes = BaseState}

function PinkFallingState:init(alien, player, gravity)
    self.alien = alien
    self.player = player
    self.gravity = gravity
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.alien.currentAnimation = self.animation
end

function PinkFallingState:update(dt)
    self.alien.currentAnimation:update(dt)

    self.alien.dy = self.alien.dy + self.gravity
    self.alien.y = self.alien.y + (self.alien.dy * dt)

    -- look at two tiles below our feet and check for collisions
    local tileBottomLeft = self.alien.map:pointToTile(self.alien.x + 1, self.alien.y + self.alien.height)
    local tileBottomRight = self.alien.map:pointToTile(self.alien.x + self.alien.width - 1, self.alien.y + self.alien.height)

    -- if we get a collision beneath us, go into either walking or idle
    if (tileBottomLeft and tileBottomRight) and (tileBottomLeft:collidable() or tileBottomRight:collidable()) then
        self.alien.dy = 0
        self.alien.y = (tileBottomLeft.y - 1) * TILE_SIZE - self.alien.height
        self.alien:changeState('walking')
    end


    -- check if we've collided with any collidable game objects
    for k, object in pairs(self.player.level.objects) do
        if object:collides(self.alien) then
            if object.solid then
                self.alien.dy = 0
                self.alien.y = object.y - self.alien.height
                self.direction = 'left'
                self.alien:changeState('walking')
            end
        end
    end
   
    -- go back to start if we fall below the map boundary
    if self.alien.y > VIRTUAL_HEIGHT then
    	self.alien:Killed()
    end

end