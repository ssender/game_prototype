local player = Object.extend(Object)

function player.new(self, _x, _y)
    self.x = _x
    self.y = _y
    self.ax = (_x - 1)*32
    self.ay = (_y - 1)*32
    self.moving = false
    self.facing = 1
    self.anim_sprite = 0
    self.anim_frame = 0
end

function player.update(self, _dir, _map)
    if self.moving then
        local dx = (32*(self.x - 1) - self.ax)
        local dy = (32*(self.y - 1) - self.ay)
        if dx ~= 0 then self.ax = self.ax + 2*(dx/math.abs(dx)) 
        elseif dy ~= 0 then self.ay = self.ay + 2*(dy/math.abs(dy))
        else self.moving = false end

        if self.anim_frame == 0 then
            self.anim_sprite = self.anim_sprite + 1
            if self.anim_sprite == 5 then self.anim_sprite = 1 end
            self.anim_frame = 12
        end

        self.anim_frame = self.anim_frame - 1
    end

    if not self.moving then
        
        if _dir ~= 0 then self.facing = _dir end
        
        if _dir == 1 and self.x ~= 32 then
            if not _map[self.x + 1][self.y].is_solid then 
                self.x = self.x + 1
                self.moving = true
            end
        elseif _dir == 2 and self.x ~= 1 then 
            if not _map[self.x - 1][self.y].is_solid then 
                self.x = self.x - 1
                self.moving = true
            end
        elseif _dir == 3 and self.y ~= 1 then
            if not _map[self.x][self.y - 1].is_solid then 
                self.y = self.y - 1
                self.moving = true
            end
        elseif _dir == 4 and self.y ~= 24 then
            if not _map[self.x][self.y + 1].is_solid then 
                self.y = self.y + 1
                self.moving = true
            end
        end

        if not self.moving then
            self.anim_sprite = 0
            self.anim_frame = 0
        end
    end
end


return player