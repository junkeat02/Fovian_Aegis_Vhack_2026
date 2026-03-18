from map.sprites import Sprites
import pygame
import map.input as input

STATUS = [ "STAY", "MOVING", "SCANNING"]

class Drone(Sprites):
    def __init__(self, image, grid_size, id, battery_level, x, y, transform_scale, movement_speed=1):
        super().__init__(image, x, y, transform_scale)

        # Status
        self.id = id
        self.survivor_found = 0
        self.battery_level = battery_level
        self.current_status = STATUS[0]
        
        # Scaling and movement
        self.speed = movement_speed * min(transform_scale)
        self.size = grid_size * min(transform_scale) - min(transform_scale)
        self.transform_scale = transform_scale

        # Coordinates
        self.x = x * transform_scale[0]
        print(f'x = {self.x}, transform_scale = {transform_scale}')
        self.y = y * transform_scale[1]
        print(f'y = {self.y}, transform_scale = {transform_scale}')
        self.initial_x = self.x
        self.initial_y = self.y

    def get_xy(self):
        return (self.x, self.y)

    def get_battery_level(self):
        return self.battery_level
    
    def go_left(self, steps=1):
        self.current_status = STATUS[1]
        self.x -= self.speed * steps
        if self.x < 0:
            self.x = 0
    
    def go_right(self, steps=1):
        self.current_status = STATUS[1]
        self.x += self.speed * steps
        if self.x > self.size:
            self.x = self.size

    def go_up(self, steps=1):
        self.current_status = STATUS[1]
        self.y -= self.speed * steps
        if self.y < 0:
            self.y = 0

    def go_down(self, steps=1):
        self.current_status = STATUS[1]
        self.y += self.speed * steps
        if self.y > self.size:
            self.y = self.size

    def manual_move(self):
        self.current_status = STATUS[1]
        if input.is_key_pressed(pygame.K_w):
            self.go_up()
            # print("go up")
        elif input.is_key_pressed(pygame.K_s):
            self.go_down()
            # print("go down")
        elif input.is_key_pressed(pygame.K_a):
            self.go_left()
            # print("go left")
        elif input.is_key_pressed(pygame.K_d):
            self.go_right()
            # print("go right")
    
