extends Spatial

onready var ray = $SelectionTool/RayCast
onready var gridmap_node = $GridMap
onready var cursor_object = $SelectionTool/CursorAt
onready var virtual_object = $SelectionTool/VirtualBlock
onready var lookat_point = $LookAtPoint
onready var cursor_label = $UI/VBoxContainer/CursorDebugLabel

const LevelData = preload("res://Scripts/LevelData.gd")

var ray_length = 2000
var grid_size = 2.5
export var current_hold_block = 9
export var current_block_rotation = 0
var disable_non_ui_stuff = true

func debug(meshlib: MeshLibrary):
	gridmap_node.clear()
	gridmap_node.set_cell_item(0, 0, 0, 1, 0)
	gridmap_node.set_cell_item(2, 0, 0, 1, 22)
	gridmap_node.set_cell_item(4, 0, 0, 1, 10)
	gridmap_node.set_cell_item(6, 0, 0, 1, 16)
	#gridmap_node.set_cell_item(2, 0, -2, 14, 0)
	#gridmap_node.set_cell_item(-1, 0, 1, 14, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var meshlib = gridmap_node.mesh_library
	#debug(meshlib)
	var used_cells = gridmap_node.get_used_cells()
	for cell in used_cells:
		var name = meshlib.get_item_name(gridmap_node.get_cell_item(cell.x, cell.y, cell.z))
		var rot = gridmap_node.get_cell_item_orientation(cell.x, cell.y, cell.z)
		print(String(cell) + ": " + name + ", " + String(rot))
	
	virtual_object.mesh = meshlib.get_item_mesh(current_hold_block)


func gridpos_with_rot_offset(pos: Vector3, type: int, rot: int):
	var grid_x = pos.x
	var grid_y = pos.z
	var name = gridmap_node.mesh_library.get_item_name(type)
	if name.begins_with("2x2_"):
		match rot:
			22:
				grid_x += 1
			10:
				grid_x += 1
				grid_y += 1
			16:
				grid_y += 1
	return Vector3(grid_x, pos.y, grid_y)


func vectorpos_with_rot_offset(pos: Vector3, type: int, rot: int):
	var grid_x = pos.x
	var grid_y = pos.z
	var name = gridmap_node.mesh_library.get_item_name(type)
	if name.begins_with("2x2_"):
		match rot:
			22:
				grid_x += 2.5
			10:
				grid_x += 2.5
				grid_y += 2.5
			16:
				grid_y += 2.5
	return Vector3(grid_x, pos.y, grid_y)


func set_cell_block(pos: Vector3, type: int, rot: int):
	var new_pos = gridpos_with_rot_offset(pos, type, rot)
	gridmap_node.set_cell_item(new_pos.x, new_pos.y, new_pos.z, type, rot)


# tile: [type, pos]
func set_current_hold_by_arr(tile: Array):
	set_current_hold(tile[0], gridmap_node.get_cell_item_orientation(tile[1].x, tile[1].y, tile[1].z))


func set_current_hold(type: int, rot: int):
	current_hold_block = type
	current_block_rotation = rot
	virtual_object.mesh = gridmap_node.mesh_library.get_item_mesh(type)
	virtual_object.rotation = LevelData.gridmap_rotation_to_vector3(rot)


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				var rot = LevelData.gridmap_rotation_to_bme_rotation(current_block_rotation)
				rot += 270
				rot %= 360
				current_block_rotation = LevelData.bme_rotation_to_gridmap_rotation(rot)
				set_current_hold(current_hold_block, current_block_rotation)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				var rot = LevelData.gridmap_rotation_to_bme_rotation(current_block_rotation)
				rot += 90
				rot %= 360
				current_block_rotation = LevelData.bme_rotation_to_gridmap_rotation(rot)
				set_current_hold(current_hold_block, current_block_rotation)
		#get_tree().set_input_as_handled()
	# ------------------------------------------------------------
	if Input.is_action_pressed("ui_left"):
		lookat_point.translate(Vector3(-grid_size, 0, 0))
	if Input.is_action_pressed("ui_right"):
		lookat_point.translate(Vector3(grid_size, 0, 0))
	if Input.is_action_pressed("ui_up"):
		lookat_point.translate(Vector3(0, 0, -grid_size))
	if Input.is_action_pressed("ui_down"):
		lookat_point.translate(Vector3(0, 0, grid_size))
	if Input.is_action_just_pressed("lift_up"):
		lookat_point.translate(Vector3(0, grid_size * 2, 0))
	if Input.is_action_just_pressed("lift_down"):
		lookat_point.translate(Vector3(0, -grid_size * 2, 0))
	if Input.is_action_just_pressed("editor_pause"):
		disable_non_ui_stuff = !disable_non_ui_stuff


func _physics_process(_delta):
	# workaround for the ui event process stuff..
	# too lazy to find out the right way to deal with event process..
	if disable_non_ui_stuff:
		cursor_label.text = "Press Z to toggle editing mode    = =||"
		virtual_object.visible = false
		cursor_object.visible = false
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = get_viewport().get_camera().project_ray_origin(mouse_pos)
	var to = get_viewport().get_camera().project_ray_normal(mouse_pos) * ray_length
	
	ray.transform.origin = from
	ray.cast_to = to
	ray.force_raycast_update()
	
	var point = gridmap_node.world_to_map(ray.get_collision_point())
	var cursor_pos = gridmap_node.map_to_world(point.x, point.y, point.z)
	var tile = get_tile_at(point)
	#print(tile)
	if tile[0] != GridMap.INVALID_CELL_ITEM:
		virtual_object.visible = false
		cursor_object.visible = true
		cursor_object.translation = cursor_pos
		cursor_label.text = String(tile[1]) + " tile:" + String(tile[0]) + \
							" rot:" + String(gridmap_node.get_cell_item_orientation(tile[1].x, tile[1].y, tile[1].z))
	else:
		virtual_object.visible = true
		cursor_object.visible = false
		virtual_object.translation = vectorpos_with_rot_offset(cursor_pos, current_hold_block, current_block_rotation)
		cursor_label.text = String(tile[1])
	
	
	if Input.is_action_just_pressed("LMB_click"):
		if tile[0] == GridMap.INVALID_CELL_ITEM:
			set_cell_block(point, current_hold_block, current_block_rotation)
		else:
			set_current_hold_by_arr(tile)
	if Input.is_action_just_pressed("RMB_click"):
		gridmap_node.set_cell_item(tile[1].x, tile[1].y, tile[1].z, GridMap.INVALID_CELL_ITEM)


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

