tool
extends Node2D

var index = 0
export(bool) var ForceUpdate setget forceUpdate  #Forces an update_change()
export(bool) var PadZeroes
export(bool) var GenerateAllPalettes
export(Vector2) var TileSize = Vector2(16,16) setget changeTileSize
export(Vector2) var Separation = Vector2(0,0) setget changeSeparation
export(Texture) var TextureToCut = null setget changeTexture


func forceUpdate(value):
	update_change()

func changeTileSize(value):
	TileSize = value
	
func changeSeparation(value):
	Separation = value
	
func changeTexture(value):
	TextureToCut = value
	index = 0
	if TextureToCut:
		update_change()
	else:
		for i in range(0, get_child_count()):
			get_child(i).queue_free()
	
func update_change():
	
	if TextureToCut != null:
		if TileSize.x > 0 and TileSize.y > 0:
			
			var w  = TextureToCut.get_width()
			var h  = TextureToCut.get_height()
			var tx = w / TileSize.x
			var ty = h / TileSize.y
			
			var zeroes = len(str(tx*ty))
			print(zeroes)
			
			for i in range(0, get_child_count()):
				get_child(i).queue_free()
							
			
			
			for y in range(ty):
				for x in range(tx):
					if !is_empty(TextureToCut,x*TileSize.x,y*TileSize.y,TileSize.x, TileSize.y):
						index = (x + tx) * y
						var sprite = Sprite.new()
#						
						if PadZeroes:
							sprite.set_name(("%0" + str(zeroes) + "d") % index)
						else:
							sprite.set_name(str(index))
						
						sprite.texture = TextureToCut
						sprite.region_enabled = true
						sprite.region_rect = Rect2(x*TileSize.x,y*TileSize.y,TileSize.x, TileSize.y)
						sprite.position.x = (x * TileSize.x) + (x*Separation.x)
						sprite.position.y = (y * TileSize.y) + (y*Separation.y)
						
						
						add_child(sprite)
						sprite.set_owner(get_tree().get_edited_scene_root())
						

	pass
	
func _draw():
	pass
	
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
	
	
	
	
	