local Ball = Object.extend(Object)

function Ball.new(self, _x, _y, _f)
    self.mark_for_cleanup = false
    self.balltype = 1
    self.sourceblockx = _x
    self.sourceblocky = _y
    self.steptime = 15 --frames/step (30 is a quarter note at 120BPM/60FPS)
    self.t = 0
    self.facing = _f
    self.x = _x 
    self.y = _y
    self.active = true
    self.release_time = 2 --in frames
    self.max_duration = 2 --in seconds

    self.sounds = {}
    self.floating = false
    self.refs = {"001", "002", "003", "004", "005", "006", "007", "008", "009", "010", "011", "012", "013", "014", "015"}
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
            elseif _tile >= 34 and _tile <= 48 then 
                _map[self.x][self.y].img = 33
                _map[self.x][self.y].anim_t = math.floor(0.5*self.steptime)

                local sn = "sounds/note-" .. self.refs[_tile-33] .. ".wav"
                table.insert(self.sounds, 1, love.audio.newSource(sn, "static"))
                self.sounds[1]:play()
            elseif _tile >= 66 and _tile <= 80 then 
                _map[self.x][self.y].img = 65
                _map[self.x][self.y].anim_t = math.floor(0.5*self.steptime)

                local sn = "sounds/note-" .. self.refs[_tile-65] .. ".wav"
                table.insert(self.sounds, 1, love.audio.newSource(sn, "static"))
                self.sounds[1]:play()
            elseif _tile >= 50 and _tile <= 53 then 
                self.facing = _tile - 49 -- movable rotation blocks
                _map[self.x][self.y].img = 49
                _map[self.x][self.y].anim_t = math.floor(0.5*self.steptime)
            elseif _tile >= 82 and _tile <= 85 then 
                self.facing = _tile - 81 -- non-movabe rotation blocks
                _map[self.x][self.y].img = 81
                _map[self.x][self.y].anim_t = math.floor(0.5*self.steptime)
            end
        end

        for i=#self.sounds,1,-1 do
            local _s = self.sounds[i]
            
            if i >= 2 or _s:tell("seconds") >= self.max_duration or (not self.active)then
                _s:setVolume(_s:getVolume() - (1/self.release_time))

                if _s:getVolume() <= 0 then
                    table.remove(self.sounds, i)
                    _s:release()
                end
            end
        end
    end
end

return Ball