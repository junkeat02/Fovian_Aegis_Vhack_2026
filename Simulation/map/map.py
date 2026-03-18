import pygame

class Map:
    def __init__(self, width, height, grid_width=20, grid_height=20, drone_xy=[], survivor_xy=[] ):
        self.width = width
        self.height= height
        self.grid_width = grid_width
        self.grid_height = grid_height
        self.drone = [xy for xy in drone_xy if len(drone_xy) > 0 and (isinstance(drone_xy, tuple) or isinstance(drone_xy, list))]
        self.survivol = [xy for xy in survivor_xy if len(survivor_xy) > 0 and (isinstance(survivor_xy, tuple) or isinstance(survivor_xy, list))]

    def set_objects_position(self, survivor_xy, drone_xy):
        if len(self.survivor) > 0 and len(self.drone) > 0:
            return
        if len(self.survivor_xy) == 0:
            if len(survivor_xy) < 1:
                raise("survivor_xy argument is required.")
            self.survivor = [xy for xy in survivor_xy]
        if len(self.drone_xy) == 0:
            if len(drone_xy) < 1:
                raise("drone_xy argument is required.")
            self.survivor = [xy for xy in drone_xy]

    def draw_grid(self, screen):
        width_blocksize = int(self.width / self.grid_width)
        height_blocksize = int(self.height / self.grid_height)
        for y in range(0, self.height, height_blocksize):
            for x in range(0, self.width, width_blocksize):
                rect = pygame.Rect(x, y, width_blocksize, height_blocksize)
                pygame.draw.rect(screen, (250, 250, 250), rect, 1)
