import pygame
sprites = []
loaded = {}

# this is designated for updating the image on screen
class Sprites:
    def __init__(self, image, x, y, transform_scale=(1, 1), scale_adjust=0):
        self.x = x
        self.y = y

        if image in loaded:
            self.image = loaded[image]
        else:
            self.image = pygame.image.load(image)
            self.image = pygame.transform.smoothscale(self.image, (transform_scale[0] + scale_adjust, transform_scale[1] + scale_adjust))
            loaded[image] = self.image

        sprites.append(self)

    def delete(self):
        sprites.remove(self)

    def update(self, screen):
        screen.blit(self.image, (self.x, self.y))

        

