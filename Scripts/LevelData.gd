extends Node

class_name LevelData

var meta_title : String
var meta_creator : String

var level_blocks = {} # layer : [ block data]
var valid_regions = ["[Metadata]", "[Sign]", "[Layer]", "[Block]"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
					print("bad [Metadata] block")
					error_encountered = true
					break
			"[Sign]":
				pass
			"[Layer]":
				pass
			"[Block]":
				pass
			_:
				print("bad line: " + line)
				error_encountered = true
				break
	
	file.close()
	return !error_encountered


func export_to_bme_file(filepath: String):
	pass


func set_gridmap_from_level_data():
	pass


func set_level_data_from_gridmap():
	pass
