extends Spatial

onready var ray = $SelectionTool/RayCast
onready var gridmap_node = $GridMap
onready var cursor_object = $SelectionTool/CursorAt

var ray_length = 2000
var current_hold_block = 9

# Called when the node enters the scene tree for the first time.
func _ready():
	var meshlib = gridmap_node.mesh_library
	var used_cells = gridmap_node.get_used_cells()
	for cell in used_cells:
		var name = meshlib.get_item_name(gridmap_node.get_cell_item(cell.x, cell.y, cell.z))
		var ori = gridmap_node.get_cell_item_orientation(cell.x, cell.y, cell.z)
		print(String(cell) + ": " + name + ", " + String(ori))


func _physics_process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var from = get_viewport().get_camera().project_ray_origin(mouse_pos)
	var to = get_viewport().get_camera().project_ray_normal(mouse_pos) * ray_length
	
	ray.transform.origin = from
	ray.cast_to = to
	ray.force_raycast_update()
	
	var point = gridmap_node.world_to_map(ray.get_collision_point())
	var tile = gridmap_node.get_cell_item(point.x, point.y, point.z)
	
	var selection_pos = gridmap_node.map_to_world(point.x, point.y, point.z)
	cursor_object.translation = selection_pos
	
	if Input.is_action_just_pressed("LMB_click"):
		if tile == GridMap.INVALID_CELL_ITEM:
			gridmap_node.set_cell_item(point.x, point.y, point.z, current_hold_block)
		else:
			current_hold_block = tile
	if Input.is_action_just_pressed("RMB_click"):
		gridmap_node.set_cell_item(point.x, point.y, point.z, GridMap.INVALID_CELL_ITEM)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
