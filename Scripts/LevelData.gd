extends Node

class_name LevelData

var meta_title : String = "Sophie Twilight"
var meta_creator : String = "Chris"

var layer_blocks = {} # {layer : [{bme block data 1}, {bme block data 2}, ...]}
var layer_props = {}
var valid_regions = ["[Metadata]", "[Sign]", "[Layer]", "[Block]"]
var bme_typename_map = {
	1: "2x2_PaperTrafo",
	2: "2x2_StoneTrafo",
	3: "2x2_WoodTrafo",
	
	4: "2x2_Floor_Top_Borderless",
	5: "2x2_Floor_Top_Flat",
	6: "2x2_Floor_Top_Profil",
	7: "2x2_Floor_Top_ProfilFlat",
	8: "2x2_NormalFlatTurn",
	9: "2x2_NormalBorderTurn",
	10: "2x2_NormalSunkenTurn",
	11: "2x2_Floor_Top_Border",
	
	12: "1x1_SmallBorderTurn",
	13: "1x1_SmallFlatBorder",
	14: "1x1_SmallFlatBorderless",
	15: "1x1_SmallFlatTurnIn",
	16: "1x1_SmallSunkenFloor",
	17: "1x1_SmallSunkenTurnIn",
	18: "1x1_SmallSunkenTurnOut",
	
	"2x2_PaperTrafo": 1,
	"2x2_StoneTrafo": 2,
	"2x2_WoodTrafo": 3,
	
	"2x2_Floor_Top_Borderless": 4,
	"2x2_Floor_Top_Flat": 5,
	"2x2_Floor_Top_Profil": 6,
	"2x2_Floor_Top_ProfilFlat": 7,
	"2x2_NormalFlatTurn": 8,
	"2x2_NormalBorderTurn": 9,
	"2x2_NormalSunkenTurn": 10,
	"2x2_Floor_Top_Border": 11,
	
	"1x1_SmallBorderTurn": 12,
	"1x1_SmallFlatBorder": 13,
	"1x1_SmallFlatBorderless": 14,
	"1x1_SmallFlatTurnIn": 15,
	"1x1_SmallSunkenFloor": 16,
	"1x1_SmallSunkenTurnIn": 17,
	"1x1_SmallSunkenTurnOut": 18,
}

const typename_meshlib_map = {
	0: "2x2_Floor_Top_Borderless",
	1: "2x2_NormalFlatTurn",
	2: "2x2_Floor_Top_Flat",
	3: "2x2_Floor_Top_ProfilFlat",
	4: "2x2_NormalBorderTurn",
	5: "2x2_Floor_Top_Border",
	6: "2x2_PaperTrafo",
	7: "2x2_NormalSunkenTurn",
	8: "2x2_Floor_Top_Profil",
	9: "2x2_StoneTrafo",
	10: "2x2_WoodTrafo",
	11: "1x1_SmallFlatTurnIn",
	12: "1x1_SmallFlatBorder",
	13: "1x1_SmallBorderTurn",
	14: "1x1_SmallFlatBorderless",
	15: "1x1_SmallSunkenTurnIn",
	16: "1x1_SmallSunkenFloor",
	17: "1x1_SmallSunkenTurnOut",
	
	"2x2_WoodTrafo": 10,
	"2x2_StoneTrafo": 9,
	"2x2_PaperTrafo": 6,
	"2x2_Floor_Top_Flat": 2,
	"2x2_Floor_Top_ProfilFlat": 3,
	"2x2_Floor_Top_Profil": 8,
	"2x2_NormalFlatTurn": 1,
	"2x2_NormalSunkenTurn": 7,
	"2x2_Floor_Top_Border": 5,
	"2x2_Floor_Top_Borderless": 0,
	"2x2_NormalBorderTurn": 4,
	"1x1_SmallBorderTurn": 13,
	"1x1_SmallFlatBorder": 12,
	"1x1_SmallFlatTurnIn": 11,
	"1x1_SmallSunkenTurnOut": 17,
	"1x1_SmallSunkenFloor": 16,
	"1x1_SmallSunkenTurnIn": 15,
	"1x1_SmallFlatBorderless": 14,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


static func tilename_to_meshlib_id(name: String):
	if typename_meshlib_map.has(name):
		return typename_meshlib_map[name]
	else:
		return -1


# https://www.reddit.com/r/godot/comments/6y5gwa/gridmap_rotations_chart/
static func bme_rotation_to_gridmap_rotation(rot: int):
	match rot:
		0:
			return 0
		90:
			return 22
		180:
			return 10
		270:
			return 16


static func gridmap_rotation_to_bme_rotation(rot: int):
	match rot:
		0:
			return 0
		22:
			return 90
		10:
			return 180
		16:
			return 270


# https://godotengine.org/qa/42431/how-to-get-rotation-item-of-gridmap
static func gridmap_rotation_to_vector3(rot: int):
	match rot:
		0:
			return Vector3(0, 0, 0)
		22:
			return Vector3(0, -PI/2, 0)
		10:
			return Vector3(0, PI, 0)
		16:
			return Vector3(0, PI/2, 0)


func parse_from_bme_file(filepath: String):
	var current_region = "__magic_header"
	var error_encountered = false
	
	var file = File.new()
	var err = file.open(filepath, File.READ)
	if err != OK:
		print(err)
		return false
	
	layer_props.clear()
	layer_blocks.clear()

	while not file.eof_reached():
		var line = file.get_line()
		if line.empty():
			continue
		if line.begins_with('[') and line.ends_with(']') and valid_regions.has(line):
			current_region = line
			continue
		
		match current_region:
			"__magic_header":
				if not line.begins_with("ballance map format"):
					print("bad header")
					error_encountered = true
					break
			"[Metadata]":
				if line.begins_with("Title: "):
					meta_title = line.right("Title: ".length())
					print(meta_title)
				elif line.begins_with("Creator: "):
					meta_creator = line.right("Creator: ".length())
					print(meta_creator)
				else:
					print("bad [Metadata] block with line: " + line)
					error_encountered = true
					break
			"[Sign]":
				print("TODO: unparsed line from Sign region: " + line)
			"[Layer]":
				var split = line.split(',', true, 3)
				if split.size() != 3:
					print("bad [Layer] block with line: " + line)
					error_encountered = true
					break
				layer_props[split[1].to_int()] = {
					"name": split[0],
					"visible": split[2] # TODO: string to bool
				}
			"[Block]":
				var split = line.split(',', true, 6)
				if split.size() != 6:
					print("bad [Block] block with line: " + line)
					error_encountered = true
					break
				var layer_at = split[5].to_int()
				if !layer_blocks.has(layer_at):
					layer_blocks[layer_at] = []
				var layer_arr = layer_blocks[layer_at]
				layer_arr.append({
					"type": split[0].to_int(),
					"x": split[1].to_int(),
					"y": split[2].to_int(),
					"size": split[3].to_int(),
					"rotation": split[4].to_int()
				})
			_:
				print("bad line: " + line)
				error_encountered = true
				break
	
	file.close()
	
	return !error_encountered


func export_to_bme_file(filepath: String, offset: Vector2):
	var file = File.new()
	var err = file.open(filepath, File.WRITE)
	if err != OK:
		print(err)
		return false
	
	var offset_x = (abs(offset.x) + 1) * 20
	var offset_y = (abs(offset.y) + 1) * 20
	
	file.store_line("ballance map format v2")
	file.store_line("")
	
	for region in valid_regions:
		file.store_line(region)
		match region:
			"[Metadata]":
				file.store_line("Title: %s" % meta_title)
				file.store_line("Creator: %s" % meta_creator)
			"[Sign]":
				pass
			"[Layer]":
				for layer in layer_props:
					var prop = layer_props[layer]
					file.store_line("%s,%d,%s" % [prop.name, layer, "True"]) # TODO: visible state
			"[Block]":
				for layer in layer_blocks:
					for blk in layer_blocks[layer]:
						file.store_line("%d,%d,%d,%d,%d,%d" % [blk.type, blk.x + offset_x, blk.y + offset_y, blk.size, blk.rotation, blk.layer])
		
		file.store_line("")
	file.close()


func bme_grid_to_gridmap_grid(layer: int, block: Dictionary):
	var grid_x = (block.x - 1) / 20
	var grid_layer = layer
	var grid_y = (block.y - 1) / 20
	var rotation = bme_rotation_to_gridmap_rotation(block.rotation)
	var block_name = bme_typename_map[block.type]
	if block_name.begins_with("2x2"):
		match block.rotation:
			90:
				grid_x += 1
			180:
				grid_x += 1
				grid_y += 1
			270:
				grid_y += 1
	var block_id = tilename_to_meshlib_id(block_name)
	return {
		"layer": layer,
		"type": block_id,
		"x": grid_x,
		"y": grid_y,
		"rotation": rotation
	}


# WARNING! This function doesn't care about offset!
func gridmap_grid_to_bme_grid(block: Dictionary):
	var block_name = typename_meshlib_map[block.type]
	var bme_blk_type = bme_typename_map[block_name]
	var grid_x = int(block.x)
	var grid_y = int(block.y)
	var rotation = gridmap_rotation_to_bme_rotation(block.rotation)
	if block_name.begins_with("2x2_"):
		match rotation:
			90:
				grid_x -= 1
			180:
				grid_x -= 1
				grid_y -= 1
			270:
				grid_y -= 1

	grid_x = grid_x * 20 + 1
	grid_y = grid_y * 20 + 1

	var grid_layer = int(block.layer)

	return {
		"layer": grid_layer,
		"type": bme_blk_type,
		"x": grid_x,
		"y": grid_y,
		"size": 0 if block_name.begins_with("2x2_") else 1,
		"rotation": rotation
	}


func set_gridmap_from_level_data(gridmap: GridMap):
	gridmap.clear()
	
	var canvas_offset = 25
	# we actually don't care about layer_props...
	for layer in layer_blocks:
		for block in layer_blocks[layer]:
			var blk = bme_grid_to_gridmap_grid(layer, block)
			#print(blk)
			gridmap.set_cell_item(blk.x - canvas_offset, blk.layer, blk.y - canvas_offset, blk.type, blk.rotation)


# return the top-left corner so we can apply offset when exporting to bme.
func set_level_data_from_gridmap(gridmap: GridMap):
	var cells = gridmap.get_used_cells()
	var min_x = 0
	var min_y = 0
	for block in cells:
		min_x = min_x if min_x < block.x else block.x
		min_y = min_y if min_y < block.z else block.z
		var blk = gridmap_grid_to_bme_grid({
			"x": block.x,
			"y": block.z,
			"layer": block.y,
			"rotation": gridmap.get_cell_item_orientation(block.x, block.y, block.z),
			"type": gridmap.get_cell_item(block.x, block.y, block.z)
		})
		if !layer_blocks.has(blk.layer):
			layer_blocks[blk.layer] = []
		var layer_arr = layer_blocks[blk.layer]
		layer_arr.append(blk)

	for key in layer_blocks.keys():
		layer_props[key] = {
			"name": "Layer " + String(key),
			"visible": "True", # TODO: string to bool
		}
	
	return Vector2(min_x, min_y)
