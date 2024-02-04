import xml.etree.ElementTree as ET

# 0:0/next_alternative_id = 2
# 0:0/0 = 0
# 0:0/0/terrain_set = 0
# 0:0/0/terrain = 0
# 0:0/1 = 1
# 0:0/1/terrain_set = 0
# 0:0/1/terrain = 0
# 0:0/1/terrains_peering_bit/right_side = 0
# 0:0/1/terrains_peering_bit/bottom_side = 0
# 1:0/next_alternative_id = 2
# 1:0/0 = 0
# 1:0/0/terrain_set = 0
# 1:0/0/terrain = 0
# 1:0/0/terrains_peering_bit/top_side = 0
# 1:0/1 = 1
# 2:0/0 = 0
# 2:0/0/terrain_set = 0
# 2:0/0/terrain = 0
# 3:0/0 = 0
# 4:0/0 = 0
# 5:0/0 = 0
# 6:0/0 = 0
# 7:0/0 = 0
# 8:0/0 = 0
# 9:0/0 = 0
def to_tres_tile(tiles, data, columns, old_to_new, image):
    rows = []
    id = int(child.attrib['id'])
    terrains = child.attrib['terrain'].split(',')
    x = id%columns
    y = id//columns
    
    unique_terrains = []
    for terrain in terrains:
        if terrain not in old_to_new:
            return []
        if terrain not in unique_terrains:
            unique_terrains.append(terrain)
    if len(unique_terrains)>1:
        rows.append(f'{x}:{y}/next_alternative_id = {len(unique_terrains)}')
    for i in range(len(unique_terrains)):
        prefix = f'{x}:{y}/{i}'
        rows.append(prefix+f'/terrain_set = 0')
        rows.append(prefix+f'/terrain = {old_to_new[unique_terrains[i]]}')
        rows.append(prefix+f' = {old_to_new[unique_terrains[i]]}')
        if terrains[0] != '':
            rows.append(prefix+f'/terrains_peering_bit/bottom_right_corner = {old_to_new[terrains[3]]}') 
        if terrains[1] != '':    
            rows.append(prefix+f'/terrains_peering_bit/bottom_left_corner = {old_to_new[terrains[2]]}') 
        if terrains[2] != '':
            rows.append(prefix+f'/terrains_peering_bit/top_left_corner = {old_to_new[terrains[0]]}') 
        if terrains[3] != '':
            rows.append(prefix+f'/terrains_peering_bit/top_right_corner = {old_to_new[terrains[1]]}')    
    return rows
# [resource]
# tile_size = Vector2i(32, 32)
# terrain_set_0/mode = 1
# terrain_set_0/terrain_0/name = "water"
# terrain_set_0/terrain_0/color = Color(0.298039, 0.301961, 1, 1)
# terrain_set_0/terrain_1/name = "sand"
# terrain_set_0/terrain_1/color = Color(0.835294, 0.623529, 0, 1)
# terrain_set_0/terrain_2/name = "dirt"
# terrain_set_0/terrain_2/color = Color(0.5, 0.34375, 0.25, 1)
# terrain_set_0/terrain_3/name = "grass"
# terrain_set_0/terrain_3/color = Color(0.321569, 0.803922, 0, 1)
# terrain_set_0/terrain_4/name = "rock"
# terrain_set_0/terrain_4/color = Color(0.67451, 0.670588, 0.662745, 1)
# terrain_set_0/terrain_5/name = "snow"
# terrain_set_0/terrain_5/color = Color(1, 1, 1, 1)
# terrain_set_0/terrain_6/name = "grassdirt"
# terrain_set_0/terrain_6/color = Color(0.34902, 0.372549, 0.156863, 1)
# sources/83 = SubResource("TileSetAtlasSource_m1gfi")
def to_tres_terrain(terraintypes, tile_mappings, old_to_new):
    row = ['[resource]']
    row.append('tile_size = Vector2i(32,32)')
    row.append('terrain_set_0/mode = 1')
    i = 0
    for child in terraintypes:
        terrain_name = child.attrib['name']
        if terrain_name in tile_mappings:
            tile_index = child.attrib["tile"]
            tile_mappings[terrain_name]= tile_index
            tile_mappings[tile_index]= terrain_name
            old_to_new[tile_index] = i

            row.append(f'terrain_set_0/terrain_{i}/name = "{terrain_name}"')
            row.append(f'terrain_set_0/terrain_{i}/color = Color(0.298039, 0.301961, 1, 1)')
            i+=1
    return row

import pygame as pg
import math
class Tile():
    def __init__(self, w,h):
        self.surface = pg.Surface((w,h))

class Tile():
    def __init__(self):
        self.coordinate = (0,0)
        self.image = None
        
class TileGenerator():
    def __init__(self, image, input_tsx, output_tres, keep_tiles):
        self.image = image
        self.keep_tiles = keep_tiles
        self.tile_mappings = {}
        self.tile_remappings = {}
        for tile_names in keep_tiles:
            self.tile_remappings[tile_names] = -1
        tree = ET.parse(input_tsx)
        self.output_path = output_tres
        self.root = tree.getroot()
        self.tile_count = self.root.attrib['tilecount']
        self.columns = int(self.root.attrib['columns'])
        self.tile_size = int(self.root.attrib['tilewidth']), int(self.root.attrib['tileheight'])
        self.terraintypes = self.root.find('.//terraintypes')
        self.tiles = []
        self.generate_terrains()
        self.parse_tile()
        self.save_tiles()


    def save_tiles(self):
        num_columns = math.ceil(math.sqrt(len(self.tiles)))
        num_rows = math.ceil(math.sqrt(len(self.tiles)))
        size = num_columns*self.tile_size[0], num_rows*self.tile_size[1]
        surface = pg.Surface(size)
        count = 0
        for y in range(num_rows):
            for x in range(num_columns):
                if count < len(self.tiles):
                    surface.blit(self.tiles[count], (x*self.tile_size[0], y*self.tile_size[1]))
                    screen.blit(self.tiles[count], (x*self.tile_size[0], y*self.tile_size[1]))
                    pg.display.flip()
                    count+=1
        pg.image.save(surface, 'output.png')

    def parse_tile(self):
        print(len(self.root))
        for child in self.root:
            if child.tag == 'tile':
                id = int(child.attrib['id'])
                terrains = child.attrib['terrain'].split(',')
                process = True
                for terrain in terrains:
                    if terrain not in self.tile_remappings:
                        process = False
                        print('skipping', terrains)
                        break
                if process:
                    print('processing', terrains)
                    x = id%self.columns
                    y = id//self.columns
                    tile_rect = x*self.tile_size[0], y*self.tile_size[1], self.tile_size[0], self.tile_size[1]
                    tile_surface = pg.Surface(self.tile_size)
                    tile_surface.blit(self.image, (0,0), tile_rect)
                    screen.blit(self.image, (0,0), tile_rect)
                    self.tiles.append(tile_surface)
    
    
    def to_tres_tile(self, tiles, data, columns, old_to_new, image):
        rows = []
        id = int(child.attrib['id'])
        terrains = child.attrib['terrain'].split(',')
        x = id%columns
        y = id//columns

        self.tiles.append()
        unique_terrains = []
        for terrain in terrains:
            if terrain not in self.tile_remappings:
                return []
            if terrain not in unique_terrains:
                unique_terrains.append(terrain)
        if len(unique_terrains)>1:
            rows.append(f'{x}:{y}/next_alternative_id = {len(unique_terrains)}')
            
        for i in range(len(unique_terrains)):
            prefix = f'{x}:{y}/{i}'
            rows.append(prefix+f'/terrain_set = 0')
            rows.append(prefix+f'/terrain = {old_to_new[unique_terrains[i]]}')
            rows.append(prefix+f' = {old_to_new[unique_terrains[i]]}')
            if terrains[0] != '':
                rows.append(prefix+f'/terrains_peering_bit/bottom_right_corner = {old_to_new[terrains[3]]}') 
            if terrains[1] != '':    
                rows.append(prefix+f'/terrains_peering_bit/bottom_left_corner = {old_to_new[terrains[2]]}') 
            if terrains[2] != '':
                rows.append(prefix+f'/terrains_peering_bit/top_left_corner = {old_to_new[terrains[0]]}') 
            if terrains[3] != '':
                rows.append(prefix+f'/terrains_peering_bit/top_right_corner = {old_to_new[terrains[1]]}')    
        return rows 
    
    def generate_terrains(self):
        self.terrain_data = ['[resource]']
        
        self.terrain_data.append(f'tile_size = Vector2i({self.tile_size[0]},{self.tile_size[1]})')
        self.terrain_data.append('terrain_set_0/mode = 1')
        i = 0
        for child in self.terraintypes:
            terrain_name = child.attrib['name']
            if terrain_name in self.keep_tiles:
                tile_index = child.attrib["tile"]
                self.tile_remappings[tile_index] = i
                self.terrain_data.append(f'terrain_set_0/terrain_{i}/name = "{terrain_name}"')
                self.terrain_data.append(f'terrain_set_0/terrain_{i}/color = Color(0.298039, 0.301961, 1, 1)')
                i+=1
        return self.terrain_data
screen = None
    
if __name__ == '__main__':
    screen = pg.display.set_mode((1280, 720), pg.SRCALPHA)
    image = pg.image.load('./terrain-map-v7-repacked.png')
    # 'Mudstone_Gray', 'Dirt_Brown',
    keep_tiles = ['Water', 'Grass']
    TileGenerator(image, 'terrain-map-v7-repacked.tsx', 'output.tres', keep_tiles)
    tile_mappings = {'Dirt_Brown':-1, 'Water':-1, 'Grass':-1, 'Mudstone_Gray':-1}
    tree = ET.parse('terrain-map-v7-repacked.tsx')
    root = tree.getroot()
    name = root.attrib['name']
    tile_count = root.attrib['tilecount']
    columns = int(root.attrib['columns'])
    terraintypes = root.find('.//terraintypes')
    tiles_params = {}
    tiles = []
    terrains = []
    old_to_new = {}
    tg = TileGenerator(image, )
    terrains+=to_tres_terrain(terraintypes, tile_mappings, old_to_new)

    j = 0
    for child in root:
        if child.tag == 'tile':
            print(j)
            j+=1
            tiles+=to_tres_tile(tiles, child.attrib, columns, old_to_new, image)
    output = ''
    for tile in tiles:
        output+=tile+'\n'
    for terrain in terrains:
        output+=terrain+'\n'
    print(output)
    with open('./output.txt', 'w') as f:

        f.write(output)

        
