tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TileSetCutter","Node2D",preload("res://addons/TileSetCutter/tilesetcutter.gd"),preload("res://addons/TileSetCutter/icon.png"))

func _exit_tree():
	remove_custom_type("TileSetCutter")