

PinkWalkingState = Class{__includes = BaseState}

function PinkWalkingState:init(alien, player)
    self.alien = alien
    self.player = player
    self.animation = Animation {
        frames = {10, 11},
        interval = 0.1
    }
    self.alien.currentAnimation = self.animation
end

function PinkWalkingState:update(dt)
    self.alien.currentAnimation:update(dt)

    
    if self.alien.direction == 'left' then
        -- stop the alien if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.player.map:pointToTile(self.alien.x, self.alien.y)
        local tileBottomLeft = self.player.map:pointToTile(self.alien.x, self.alien.y + self.alien.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
        	-- if there is something in the way jump in the pursuit of blood
            self.alien:changeState("jump")
        end
        -- increment the alients X position based on their speed
        self.alien.x = self.alien.x - ALIEN_WALK_SPEED * dt
    else
        self.alien.x = self.alien.x + ALIEN_WALK_SPEED * dt
        -- stop the snail if there's a missing tile on the floor to the left or a solid tile directly left
        local tileRight = self.player.map:pointToTile(self.alien.x, self.alien.y)
        local tileBottomRight = self.player.map:pointToTile(self.alien.x + self.alien.width, self.alien.y + self.alien.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.alien:changeState('jump')
        end
      
    end

    -- change the direction of alien to chase the player
    if self.alien.x > self.player.x then
    	self.alien.direction = 'left'
    else
    	self.alien.direction = 'right'
    end

    -- collision checking variables
    local tileLeft = self.alien.map:pointToTile(self.alien.x - 1, self.alien.y)
    local tileBelowLeft = self.alien.map:pointToTile(self.alien.x + 1, self.alien.y + self.alien.height)
    local tileRight = self.alien.map:pointToTile(self.alien.x + 1, self.alien.y)
    local tileBelowRight = self.alien.map:pointToTile(self.alien.x + self.alien.width - 1, self.alien.y + self.alien.height)
    

    -- temporarily shift alien down a pixel to test for game objects beneath
    self.alien.y = self.alien.y + 1

    local collidedObjects = self.alien:checkObjectCollisions()

    self.alien.y = self.alien.y - 1

    -- check to see whether there are any tiles beneath alien
    if #collidedObjects == 0 and (tileBelowLeft and tileBelowRight) and (not tileBelowLeft:collidable() and not tileBelowRight:collidable()) then
        self.alien.dy = 0
        self.alien:changeState('falling')
    end
    -- if we get a collision up top, go into the falling state immediately
    if (tileLeft and tileRight) and (tileLeft:collidable() or tileRight:collidable()) then
        self.alien:changeState('falling')
    end

 
    -- Keep Alien within bounds of map
    if self.alien.x < 1 then
    	self.alien.direction = 'right'
    elseif self.alien.x > self.alien.map.width then
    	self.alien.direction = 'left'
    end
end