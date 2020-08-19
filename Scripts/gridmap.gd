extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var gridmap_node = get_node("GridMap")

# Called when the node enters the scene tree for the first time.
func _ready():
	var meshlib = gridmap_node.mesh_library
	var used_cells = gridmap_node.get_used_cells()
	for cell in used_cells:
		var name = meshlib.get_item_name(gridmap_node.get_cell_item(cell.x, cell.y, cell.z))
		var ori = gridmap_node.get_cell_item_orientation(cell.x, cell.y, cell.z)
		print(String(cell) + ": " + name + ", " + String(ori))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
