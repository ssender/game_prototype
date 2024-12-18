local Ball = Object.extend(Object)

function Ball.new(self, _x, _y, _f)
    self.balltype = 1
    self.steptime = 30 --frames/step (30 is a quarter note at 120BPM/60FPS)
    self.t = 0
    self.facing = _f
    self.x = _x
    self.y = _y
    self.active = true

    self.floating = false
end

function Ball.update(self, _map)
    self.t = self.t + 1

    if self.t >= 0.5*self.steptime then
        self.t = self.t - 0.5*self.steptime
        self.floating = not self.floating

        if self.facing == 1 then self.x = self.x + 0.5
        elseif self.facing == 2 then self.x = self.x - 0.5
        elseif self.facing == 3 then self.y = self.y - 0.5
        elseif self.facing == 4 then self.y = self.y + 0.5
        end

        if self.x < 1 or self.x > 32 or self.y < 1 or self.y > 24 then
            self.active = false
            return
        end

        if not self.floating then
            local _tile = _map[self.x][self.y].id

            if _tile == 2 then self.active = false -- this is when ball hit wall
            elseif _tile >= 50 and _tile <= 53 then self.facing = _tile - 49 -- movable rotation blocks
            elseif _tile >= 82 and _tile <= 85 then self.facing = _tile - 81 -- non-movabe rotation blocks
            end
        end
    end
end

return Ball