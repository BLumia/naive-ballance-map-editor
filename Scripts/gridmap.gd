extends Spatial

onready var ray = $SelectionTool/RayCast
onready var gridmap_node = $GridMap
onready var cursor_object = $SelectionTool/CursorAt
onready var lookat_point = $LookAtPoint

var ray_length = 2000
var grid_size = 2.5
export var current_hold_block = 9

func debug(meshlib: MeshLibrary):
	gridmap_node.clear()
	gridmap_node.set_cell_item(0, 0, 0, 6, 0)
	gridmap_node.set_cell_item(2, 0, 0, 7, 22)
	gridmap_node.set_cell_item(4, 0, 0, 8, 10)
	gridmap_node.set_cell_item(6, 0, 0, 9, 16)
	#gridmap_node.set_cell_item(2, 0, -2, 14, 0)
	#gridmap_node.set_cell_item(-1, 0, 1, 14, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var meshlib = gridmap_node.mesh_library
	#debug(meshlib)
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
	var tile = get_tile_at(point)
	#print(tile)
	#if tile[0] != GridMap.INVALID_CELL_ITEM:
	#	print(gridmap_node.get_cell_item_orientation(tile[1].x, tile[1].y, tile[1].z))
	
	var selection_pos = gridmap_node.map_to_world(point.x, point.y, point.z)
	cursor_object.translation = selection_pos
	
	if Input.is_action_just_pressed("LMB_click"):
		if tile[0] == GridMap.INVALID_CELL_ITEM:
			gridmap_node.set_cell_item(point.x, point.y, point.z, current_hold_block)
		else:
			current_hold_block = tile[0]
	if Input.is_action_just_pressed("RMB_click"):
		gridmap_node.set_cell_item(tile[1].x, tile[1].y, tile[1].z, GridMap.INVALID_CELL_ITEM)
		
	if Input.is_action_just_pressed("ui_left"):
		lookat_point.translate(Vector3(-grid_size, 0, 0))
	if Input.is_action_just_pressed("ui_right"):
		lookat_point.translate(Vector3(grid_size, 0, 0))
	if Input.is_action_just_pressed("ui_up"):
		lookat_point.translate(Vector3(0, 0, -grid_size))
	if Input.is_action_just_pressed("ui_down"):
		lookat_point.translate(Vector3(0, 0, grid_size))


# Return if the given grid contains (covered) the given point
func check_contain_grid(cell: Vector3, checkContains: Vector3):
	var thecell = gridmap_node.get_cell_item(cell.x, cell.y, cell.z)
	if thecell == GridMap.INVALID_CELL_ITEM:
		return GridMap.INVALID_CELL_ITEM
	var meshlib = gridmap_node.mesh_library
	var cellname = meshlib.get_item_name(thecell)
	var contained_grids = [cell]
	if cellname.begins_with("2x2_"):
		var ori = gridmap_node.get_cell_item_orientation(cell.x, cell.y, cell.z)
		match ori:
			0:
				contained_grids.append(cell + Vector3(0, 0, 1))
				contained_grids.append(cell + Vector3(1, 0, 0))
				contained_grids.append(cell + Vector3(1, 0, 1))
			22:
				contained_grids.append(cell + Vector3(0, 0, 1))
				contained_grids.append(cell + Vector3(-1, 0, 0))
				contained_grids.append(cell + Vector3(-1, 0, 1))
			10:
				contained_grids.append(cell + Vector3(0, 0, -1))
				contained_grids.append(cell + Vector3(-1, 0, 0))
				contained_grids.append(cell + Vector3(-1, 0, -1))
			16:
				contained_grids.append(cell + Vector3(0, 0, -1))
				contained_grids.append(cell + Vector3(1, 0, 0))
				contained_grids.append(cell + Vector3(1, 0, -1))
		if contained_grids.has(checkContains):
			return thecell
	return GridMap.INVALID_CELL_ITEM


# Will also check the grids around the curren grid since we got 2x2 tiles.
# Return the tile type and the real tile pos.
# If the given point doesn't have a tile, the returned pos will be the same as the given one. 
func get_tile_at(point: Vector3):
	var tile = gridmap_node.get_cell_item(point.x, point.y, point.z)
	if tile != GridMap.INVALID_CELL_ITEM:
		return [tile, point]
	var ntile = GridMap.INVALID_CELL_ITEM
	
	ntile = check_contain_grid(point + Vector3(-1, 0, -1), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(-1, 0, -1)]
	ntile = check_contain_grid(point + Vector3(-1, 0, 0), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(-1, 0, 0)]
	ntile = check_contain_grid(point + Vector3(-1, 0, 1), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(-1, 0, 1)]
	ntile = check_contain_grid(point + Vector3(0, 0, -1), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(0, 0, -1)]
	ntile = check_contain_grid(point + Vector3(0, 0, 1), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(0, 0, 1)]
	ntile = check_contain_grid(point + Vector3(1, 0, -1), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(1, 0, -1)]
	ntile = check_contain_grid(point + Vector3(1, 0, 0), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(1, 0, 0)]
	ntile = check_contain_grid(point + Vector3(1, 0, 1), point)
	if ntile != GridMap.INVALID_CELL_ITEM:
		return [ntile, point + Vector3(1, 0, 1)]
	return [GridMap.INVALID_CELL_ITEM, point]

