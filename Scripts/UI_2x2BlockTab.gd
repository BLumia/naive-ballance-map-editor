extends Tabs

onready var rootNode = $"/root/Spatial"
var TileNameMap = {
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_held_block_type(type: int):
	rootNode.current_hold_block = type


func set_current_block_by_name(tilename: String):
	if TileNameMap.has(tilename):
		print(tilename)
		set_held_block_type(TileNameMap[tilename])

