extends Tabs

onready var rootNode = $"/root/Spatial"
const LevelData = preload("res://Scripts/LevelData.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_held_block_type(type: int):
	rootNode.current_hold_block = type


func set_current_block_by_name(tilename: String):
	var tile_id = LevelData.tilename_to_meshlib_id(tilename)
	if tile_id != -1:
		print(tilename)
		set_held_block_type(tile_id)

