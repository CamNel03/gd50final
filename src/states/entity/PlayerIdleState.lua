--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {1},
        interval = 1
    }

    self.player.currentAnimation = self.animation
end

function PlayerIdleState:update(dt)

    if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
        self.player:changeState('walking')
    end

    if love.keyboard.wasPressed('space') then

        self.player:changeState('jump', self)
    end

    if self.player.starPower then
        -- check if we've collided with any entities and kill them if so
        for k, entity in pairs(self.player.level.entities) do
            if entity:collides(self.player) then
                if entity.type == 'snail' then
                    gSounds['kill']:play()
                    gSounds['kill2']:play()
                    self.player.score = self.player.score + 100
                    table.remove(self.player.level.entities, k)
                end
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
end
