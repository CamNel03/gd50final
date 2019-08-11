
PinkIdleState = Class{__includes = BaseState}

function PinkIdleState:init(alien, player)
    self.alien = alien
    self.player = player

    self.animation = Animation {
        frames = {1},
        interval = 1
    }

    self.alien.currentAnimation = self.animation
end

function PinkIdleState:update(dt)
	-- after a few seconds of waiting send the alien back on its mission
	Timer.after(3, function()
		self.alien:changeState("walking")

	end)
end
