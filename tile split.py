import pygame as pg
import math

name = './tiles/terrain-map-v7-repacked.png'
image=pg.image.load(name)
size = image.get_size()
max_tiles = 40
tile_size = 32
chunks = 4
for i in range(chunks):
    width = size[0]
    height = size[1]//4+1
    s = pg.Surface((width, height), pg.SRCALPHA)
    s.fill((0,0,0,0))
    s.blit(image, (0,0), (0, i*height, width, height ))
    pg.image.save(s, name+str(i)+'.png')