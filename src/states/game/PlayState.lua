--[[
    GD50
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.camX = 0
    self.camY = 0
    self.level = LevelMaker.generate(100, 10)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0

    self.starTimer = 0

    self.alienCount = 0 -- keep track of the amount of aliens
    

    self.gravityOn = true
    self.gravityAmount = 6
    -- iterate to get a coordinate we can drop our player safely to land
    local brk = false
    for x = 1, self.tileMap.width, TILE_SIZE do
         for y = 1, self.tileMap.height do
            if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                self.startPoint = x -- variable to track where to start alien
                brk = true
                break
            end
        end
        if brk then
            break
        end
    end

    self.player = Player({
        x = self.startPoint, y = 0,
        width = 16, height = 20,
        texture = 'green-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level
    })

    self:spawnEnemies()

    self.player:changeState('falling')
end


function PlayState:enter(params)
    if params ~= nil then
        self.player.score = params.score 

        -- use local variable to call generate level and have a new width of level
        local wd = params.wd
        wd = wd + 50
        self.level = LevelMaker.generate(wd, 10)


        self.tileMap = self.level.tileMap
        self.player.level = self.level
        self.player.map = self.tileMap
        self.player.hasKey = false
        self.alientCount = 0 -- reset how many aliens we have spwaned
        self:spawnEnemies()

        self.player:changeState('falling')
    end
end



function PlayState:update(dt)
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()


    if self.player.starPower then
        -- if we have been in starpower enough then change back music and flag
        if self.starTimer > 6 then
            self.starTimer = 0
            self.player.starPower = false
            gSounds['starMusic']:pause()
            gSounds['music']:resume()
        else
            --increment the star timer
            self.starTimer = self.starTimer + dt
        end

    end


    -- update player and level
    self.player:update(dt)
    self.level:update(dt)
    self:updateCamera()


    --- this is commented out code
    -- mainly left to show that I had started on prijectiles but decided a different direction
    --[[ 
    for k, entity in pairs(self.level.entities) do
        if entity.type == 2 then
        
            local diffX = math.abs(self.player.x - entity.x)
            if diffX < 20 * TILE_SIZE then
                
                local projectile_direction
                if entity.direction == nil then
                    if selfplayer.x > entity.x then
                        projectile_direction = 'right'
                    else
                        projectile.direction = 'left'
                    end
                else
                    projectile_direction = entity.direction
                end
    
                if math.random(3) == 1 then
                    print("here")
                    local bomb = GameObject {
                    texture = 'coins_and_bombs',
                    x = (entity.x - 1) * TILE_SIZE,
                    y = entity.y - .5,
                    width = 16,
                    height = 16,
                    frame = 4,
                    collidable = true,
                    consumable = true,
                    solid = false,
                    projectile = true,
                    direction = projectile_direction,

                    -- gem has its own function to add to the player's score
                    onConsume = function(player, object)
                        player.health = player.health - 1
                        table.remove(self.player.level.entities, k)
                        if player.health <= 0 then
                            gSounds['death']:play()
                            gStateMachine:change('start')
                        end
                    end
                    }
                    table.insert(self.level.objects, bomb)
                end
                
            end 
        end
    end
    ]]

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
    
    -- render score
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(tostring(self.player.score), VIRTUAL_WIDTH - 40, 5)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(tostring(self.player.score), VIRTUAL_WIDTH - 41, 4)

    -- keep track of the players health and render hearts like in zelda
    local healthLeft = self.player.health
    local heartFrame = 1

    for i = 1, 3 do
        if healthLeft > 1 then
            heartFrame = 5
        elseif healthLeft == 1 then
            heartFrame = 3
        else
            heartFrame = 1
        end

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][heartFrame],
            (i - 1) * (TILE_SIZE + 1), 2)
        
        healthLeft = healthLeft - 2
    end

end

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then
                        
                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            type = 1, -- basically numerical shorthand for snail 
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 32,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            },
                            type = 1
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })
                        
                        table.insert(self.level.entities, snail)
                    elseif math.random(25) == 1 and self.alienCount < 4 then
                        -- create our dumb little friend
                        local pink_enemy
                        pink_enemy = Pink {
                            texture = 'pink-alien',
                            x = (x - 1) * TILE_SIZE,
                            y = 0,
                            width = 16,
                            height = 20,
                            -- load in all the states
                            stateMachine = StateMachine {
                                ['idle'] = function() return PinkIdleState(pink_enemy, self.player) end,
                                ['walking'] = function() return PinkWalkingState(pink_enemy, self.player) end,
                                ['jump'] = function() return PinkJumpState(pink_enemy, self.player, self.gravityAmount) end,
                                ['falling'] = function() return PinkFallingState(pink_enemy, self.player, self.gravityAmount) end
                            },
                            map = self.tileMap,
                            type = 2 -- again just a numerical identified
                        }
                        self.alienCount = self.alienCount + 1 -- increment out amount of alient trackes
                        pink_enemy.player = self.player -- pass the player to the alien
                        pink_enemy:changeState('falling') 

                        table.insert(self.level.entities, pink_enemy)
                    end
                end
            end
        end
    end
end