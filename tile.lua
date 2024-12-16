local Tile = Object.extend(Object)

function Tile.new(self, _id)
    self.id = _id
    self.img = _id
    self.draw_layer = 2
    self.xo = 0
    self.yo = 0
    self.anim_state = 0
    self.anim_time = 0
    self.anim_clock = 0
    self.overtile = 0
    self.is_solid = (self.id <= 64) and (self.id ~= 0)
    self.is_push = (self.id >= 33 and self.is_solid)
    if _id >= 65 and _id <= 96 then self.draw_layer = 1 end
end

function Tile.update(self)
    if self.xo ~= 0 then
        if self.xo > 0 then self.xo = self.xo - 1 else self.xo = self.xo + 1 end
    end
    if self.yo ~= 0 then
        if self.yo > 0 then self.yo = self.yo - 1 else self.yo = self.yo + 1 end
    end
end

return Tile