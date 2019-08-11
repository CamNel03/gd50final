--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerWalkingState = Class{__includes = BaseState}

function PlayerWalkingState:init(player)
    self.player = player
    self.animation = Animation {
        frames = {10, 11},
        interval = 0.1
    }
    self.player.currentAnimation = self.animation
end

function PlayerWalkingState:update(dt)
    self.player.currentAnimation:update(dt)

    if self.player.starPower then
        self.walkSpeed = PLAYER_STARWALK_SPEED
        self.animation.interval = .05
    else
        self.animation.interval = .1
    end
    

    -- idle if we're not pressing anything at all
    if not love.keyboard.isDown('left') and not love.keyboard.isDown('right') then
        self.player:changeState('idle')
    else
        local tileBottomLeft = self.player.map:pointToTile(self.player.x + 1, self.player.y + self.player.height)
        local tileBottomRight = self.player.map:pointToTile(self.player.x + self.player.width - 1, self.player.y + self.player.height)

        -- temporarily shift player down a pixel to test for game objects beneath
        self.player.y = self.player.y + 1

        local collidedObjects = self.player:checkObjectCollisions()

        self.player.y = self.player.y - 1

        -- check to see whether there are any tiles beneath us
        if #collidedObjects == 0 and (tileBottomLeft and tileBottomRight) and (not tileBottomLeft:collidable() and not tileBottomRight:collidable()) then
            self.player.dy = 0
            self.player:changeState('falling')
        elseif love.keyboard.isDown('left') then
            if self.player.starPower then
                self.player.x = self.player.x - PLAYER_STARWALK_SPEED * dt
            else
                self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
            end
            self.player.direction = 'left'
            self.player:checkLeftCollisions(dt)
        elseif love.keyboard.isDown('right') then
            if self.player.starPower then
                self.player.x = self.player.x + PLAYER_STARWALK_SPEED * dt
            else
                self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
            end
            self.player.direction = 'right'
            self.player:checkRightCollisions(dt)
        end
    end

    
    if self.player.starPower then
        -- check if we've collided with any entities and kill them if so
        for k, entity in pairs(self.player.level.entities) do
            if entity:collides(self.player) then
                gSounds['kill']:play()
                gSounds['kill2']:play()
                self.player.score = self.player.score + 100
                table.remove(self.player.level.entities, k)
            end
        end
    else
        -- check if we've collided with any entities and die if so
        for k, entity in pairs(self.player.level.entities) do
            if entity:collides(self.player) then
                print(entity.type)
                if entity.type == 1 then
                    self.player.health = self.player.health - 2
                    table.remove(self.player.level.entities, k)
                    if self.player.health <= 0 then
                        gSounds['death']:play()
                        gStateMachine:change('start')
                    end
                elseif entity.type == 2 then
                    gSounds['death']:play()
                    gStateMachine:change('start')
                end
            end
        end
    end

    if love.keyboard.wasPressed('space') then
        self.player:changeState('jump')
    end
end