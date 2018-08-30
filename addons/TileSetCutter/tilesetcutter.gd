tool
extends Node2D

export(bool) var force_update setget force_update  #Forces an update_change()
export(bool) var PadZeroes
export(bool) var GenerateAllPalettes
export(bool) var GenerateCollision = false setget enable_collision

enum TilingType {SQUARE, ISOMETRIC, CUSTOM}
export (TilingType) var TileType = TilingType.SQUARE

export(Vector2) var TileSize = Vector2(16,16) setget change_tile_size
export(Vector2) var Separation = Vector2(0,0) setget change_separation
export(Vector3) var CollisionSize = Vector3(0,0,0) setget change_collision_size
export(Vector2) var TextureOffset = Vector2(0,0)
export(Texture) var TextureToCut = null setget change_texture


func force_update(value):
	update_change()

func change_tile_size(value):
	TileSize = value
	
func change_separation(value):
	Separation = value
	
func change_texture(value):
	TextureToCut = value
	
	if TextureToCut:
		update_change()
	else:
		for i in range(0, get_child_count()):
			get_child(i).queue_free()
			
func enable_collision(value):
	GenerateCollision = value
	update_change()
	
func change_collision_size(value):
	CollisionSize = value
	update_change()
	
func update_change():
	
	if TextureToCut == null:
		return
		
	if TileSize.x > 0 and TileSize.y > 0:
		
		var w  = TextureToCut.get_width()
		var h  = TextureToCut.get_height()
		var tx = w / TileSize.x
		var ty = h / TileSize.y
		
		var zeroes = len(str(int(tx*ty)))
		
		for i in range(0, get_child_count()):
			get_child(i).queue_free()

		var index = 0
		for y in range(ty):
			for x in range(tx):
				if !is_empty(TextureToCut, x * TileSize.x, y * TileSize.y, TileSize.x, TileSize.y):
					index += 1
					var sprite = Sprite.new()

					if PadZeroes:
						sprite.set_name(("%0" + str(zeroes) + "d") % index)
					else:
						sprite.set_name(str(index))
					
					sprite.texture = TextureToCut
					sprite.region_enabled = true
					sprite.region_rect = Rect2(x*TileSize.x,y*TileSize.y,TileSize.x, TileSize.y)
					sprite.position.x = (x * TileSize.x) + (x*Separation.x)
					sprite.position.y = (y * TileSize.y) + (y*Separation.y)
					sprite.offset = TextureOffset
					
					add_child(sprite)
					sprite.set_owner(get_tree().get_edited_scene_root())
					
					if GenerateCollision:
						create_collision_node(sprite)

func create_collision_node(sprite):
	if CollisionSize.x > 0 and CollisionSize.y > 0:
		var staticBody2d = StaticBody2D.new()
		var colPoly2d = CollisionPolygon2D.new()
		
		# Add the static body to the sprite and add it to the current scene
		sprite.add_child(staticBody2d)
		staticBody2d.set_owner(get_tree().get_edited_scene_root())
		
		# Create the polygon that will be used as collision
		if TileType == TilingType.SQUARE:
			colPoly2d.polygon = [
						Vector2(-CollisionSize.x/2, -CollisionSize.y/2), 
						Vector2(CollisionSize.x/2, -CollisionSize.y/2),
						Vector2(CollisionSize.x/2, CollisionSize.y/2), 
						Vector2(-CollisionSize.x/2, CollisionSize.y/2)]
		elif TileType == TilingType.ISOMETRIC:
			# var actualColSize = Vector3(CollisionSize.x - TextureOffset.x, CollisionSize.y - TextureOffset.y, CollisionSize.z - TextureOffset.y)
			colPoly2d.polygon = [
						Vector2(-CollisionSize.x + TextureOffset.x, CollisionSize.y + TextureOffset.y), 
						Vector2(TextureOffset.x, CollisionSize.z + TextureOffset.y),
						Vector2(CollisionSize.x + TextureOffset.x, CollisionSize.y + TextureOffset.y), 
						Vector2(TextureOffset.x, TextureOffset.y)]

		# Add the collision polygon to the static body and add it to the current scene
		staticBody2d.add_child(colPoly2d)
		colPoly2d.set_owner(get_tree().get_edited_scene_root())
	
func is_empty(texture,x,y,w,h):
	var result = true
	var image  = texture.get_data()
	image.lock()
	for xx in range(x,x+w):
		for yy in range(y,y+h):
			
			var pixel = image.get_pixel(xx,yy)
			if pixel.a != 0:
				return false 
	
	image.unlock()
	
	return result
	
func _draw():
	pass
