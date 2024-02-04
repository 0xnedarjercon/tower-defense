extends Sprite2D



func set_sprite(tiles, pixels):
	# Create an Image object
	var current_texture = texture
	var image = current_texture.get_image()
	image.resize(tiles.size()*pixels, tiles.size()*pixels)
	var size = tiles.size()
	# Generate terrain using the Diamond-Square algorithm
	for y in range(size):
		for x in range(size):
			# Calculate height based on a gradient
			var height = float(tiles[x][y])
			# Set the pixel color in the image
			var color = Color(height / 255.0, height / 255.0, height / 255.0)
			var black = Color(0,0,0,1)
			for i in range(pixels):
				for j in range(pixels):
					image.set_pixel(x*pixels+i, y*pixels+j, color)
			for i in range(pixels*size):
				image.set_pixel(i, 0, black)
				image.set_pixel(0, i, black)
				image.set_pixel(i, pixels*size-1, black)
				image.set_pixel(pixels*size-1, i, black)
	texture = ImageTexture.create_from_image(image)
