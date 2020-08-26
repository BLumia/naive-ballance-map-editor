extends Node

class_name LevelData

var meta_title : String
var meta_creator : String

var layer_blocks = {} # layer : [ block data]
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
}

const typename_meshlib_map = {
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


func parse_from_bme_file(filepath: String):
	var current_region = "__magic_header"
	var error_encountered = false
	
	var file = File.new()
	var err = file.open(filepath, File.READ)
	if err != OK:
		print(err)
		return false

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


func export_to_bme_file(filepath: String):
	pass


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


func set_gridmap_from_level_data(gridmap: GridMap):
	gridmap.clear()
	
	var canvas_offset = 25
	# we actually don't care about layer_props...
	for layer in layer_blocks:
		for block in layer_blocks[layer]:
			var blk = bme_grid_to_gridmap_grid(layer, block)
			print(blk)
			gridmap.set_cell_item(blk.x - canvas_offset, blk.layer, blk.y - canvas_offset, blk.type, blk.rotation)


func set_level_data_from_gridmap():
	pass
