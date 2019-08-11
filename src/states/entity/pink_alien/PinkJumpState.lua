PinkJumpState = Class{__includes = BaseState}

function PinkJumpState:init(alien, player, gravity)
    self.alien = alien
    self.player = player
    self.gravity = gravity
    self.walkSpeed = ALIEN_WALK_SPEED
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.alien.currentAnimation = self.animation
end

function PinkJumpState:enter(params)
    self.alien.dy = ALIEN_JUMP_VELOCITY
end

function PinkJumpState:update(dt)
    self.alien.currentAnimation:update(dt)

    -- set the speed for x axis travel for alien to clear obstacles
    if self.alien.direction == 'left' then
        self.alien.x = self.alien.x - ALIEN_JUMP_COVER * dt
    else
        self.alien.x = self.alien.x + ALIEN_JUMP_COVER * dt
    end

    -- alter dy and alient y position
    self.alien.dy = self.alien.dy + self.gravity
    self.alien.y = self.alien.y + (self.alien.dy * dt)

    -- go into the falling state when y velocity is positive
    if self.alien.dy >= 0 then
        self.alien:changeState('falling')
    end


    -- look at two tiles above our head and check for collisions; 3 pixels of leeway for getting through gaps
    local tileLeft = self.alien.map:pointToTile(self.alien.x + 3, self.alien.y)
    local tileRight = self.alien.map:pointToTile(self.alien.x + self.alien.width - 3, self.alien.y)


    -- if we get a collision up top, go into the falling state immediately
    if (tileLeft and tileRight) and (tileLeft:collidable() or tileRight:collidable()) then
        self.alien.dy = 0
        self.alien:changeState('falling')
    end


    -- check if we've collided with any collidable game objects
    for k, object in pairs(self.alien.player.level.objects) do
        if object:collides(self.alien) then
            if object.solid then
                self.alien.y = object.y + object.height
                self.alien.dy = 0
                self.alien:changeState('falling')
            end
        end
    end
   
end