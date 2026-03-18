from map.sprites import Sprites

class Survivor(Sprites):
    def __init__(self, image, x, y, transform_scale, scale_adjust=0):
        super().__init__(image, x, y, transform_scale, scale_adjust)
        self.x = x * transform_scale[0]
        self.y = y * transform_scale[1]
    def get_xy(self):
        return self.x, self.y