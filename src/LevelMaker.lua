--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    -- bools to track whether we have already created out lock and key
    local key_generated = false
    local lock_generated = false 
    local lockKeyColor = math.random(4) -- get a random color for the key and lock

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 and x ~= width then -- make sure final spot in level has gorund for the flag
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            local keyLockHeight = 6
            -- chance to generate a pillar
            if math.random(8) == 1 and x ~= width then -- don't generate pillars where flag goes
                blockHeight = 2
                keyLockHeight = 4

                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            -- chance to generate bushes
            elseif rand1 == 1 and x ~= width then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 and x ~= width then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then
                                -- get a random number for spawning items from our block
                                local randNum = math.random(5)

                                -- chance to spawn gem, not guaranteed
                                if randNum == 1 then
                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)

                                -- chance to spawn a star only with normal heighted blocks so our star stays on screen
                                elseif randNum == 2 and blockHeight == 4 then
                                    local star = GameObject {
                                        texture = 'star',
                                        x = (x - 1.5) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 6,
                                        width = 16,
                                        height = 16,
                                        frame = 1,
                                        collidable = false,
                                        consumable = true,
                                        -- on consumptiopn of our star set star flag for player to true and alter music
                                        onConsume = function(player, object)
                                            gSounds['music']:pause()
                                            gSounds['starMusic']:play()
                                            player.starPower = true
                                        end
                                    }

                                    -- make the star move up from the block and play a sound
                                    Timer.tween(0.2, {
                                        [star] = {y = (blockHeight - 4) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()
                                    table.insert(objects, star)
                                -- chance to spawn a health mushroom
                                elseif randNum == 3 then
                                    local mushroom = GameObject {
                                        texture = 'mushrooms',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = MUSHROOMS[math.random(#MUSHROOMS)],
                                        collidable = false,
                                        consumable = true,

                                        -- pretty simple jsut increment health upon consumption
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.health = player.health + 2
                                            if player.health > 6 then
                                                player.health = 6
                                            end
                                        end
                                    }

                                    -- make the mushroom move up from the block and play a sound
                                    Timer.tween(0.2, {
                                        [mushroom] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()
                                    table.insert(objects, mushroom)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end


            -- if key has not already been generated then generate it and if at end of level then generate it
            if  not key_generated then
                if math.random(20) == 1 or x == width then
                    local key = GameObject {
                        texture = 'keys_locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (keyLockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = KEYS[lockKeyColor],
                        collidable = true,
                        consumable = true,
                        solid = false,

                        -- key function to set player has key flag to true
                        onConsume = function(player, object)
                            gSounds['pickup']:play()
                            player.hasKey = true
                        end
                    }

                    table.insert(objects, key)
                    key_generated = true
                end
            end
            -- if the lock has not already been generated create it at a random spot or if at end then create it
            if not lock_generated then
                if math.random(20) == 1 or x == width then
                    local lock = GameObject {
                        texture = 'keys_locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (keyLockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = LOCKS[lockKeyColor],
                        collidable = true,
                        consumable = false,
                        solid = true,
                        hit = false,

                        onCollide = function(player, obj)
                                -- If the player has the keh play a sound and then remove the lock object so it disappears and then add flag
                                if player.hasKey then
                                    gSounds['pickup']:play()
                                    for k, object in pairs(objects) do
                                        if object.x == (x - 1) * TILE_SIZE and object.y == (keyLockHeight - 1) * TILE_SIZE then
                                            table.remove(objects, k)
                                        end
                                    end
                                    -- flagpole object to render
                                    local flagPole = GameObject {
                                        texture = 'flagPole',
                                        x = (width - .75) * TILE_SIZE,
                                        y = 3.25 * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = FLAGPOLE[math.random(#FLAGPOLE)],
                                        collidable = false,
                                        consumable = false,
                                        solid = false,
                                    }

                                    table.insert(objects, flagPole)
                                    -- flag object for rendering
                                    local flag = GameObject {
                                        texture = 'flags',
                                        x = (width - .25) * TILE_SIZE,
                                        y = 4.35 * TILE_SIZE - 6,
                                        width = 16,
                                        height = 48,
                                        frame = FLAG[math.random(#FLAG)],
                                        collidable = false,
                                        consumable = false,
                                        solid = false,
                                    }
                                    table.insert(objects, flag)
                                    -- object wtih no image that encompasses the flag as a whole
                                    local flagBox = GameObject {
                                        texture = nil,
                                        x = (width - .5) * TILE_SIZE,
                                        y = 3.25 * TILE_SIZE - 6,
                                        width = 16,
                                        height = 50,
                                        frame = nil,
                                        collidable = false,
                                        consumable = true,
                                        solid = false,

                                        onConsume = function(player)
                                            if player.starPower then
                                                self.starTimer = 0
                                                self.player.starPower = false
                                                gSounds['starMusic']:pause()
                                                gSounds['music']:resume()
                                            end
                                            gStateMachine:change('play', {
                                                score = player.score, -- pass player score to new playstate
                                                wd = player.map.width, -- pass the current width of the level to new playstate
                                            })
                                        end
                                    }
                                    table.insert(objects, flagBox)
                                end

                        end
                    }

                    table.insert(objects, lock)
                    lock_generated = true
                end
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end