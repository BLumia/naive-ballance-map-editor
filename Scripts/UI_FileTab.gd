extends Tabs


onready var gridmap_node = $"/root/Spatial/GridMap"
onready var uiRoot = $"/root/Spatial/UI"
onready var loadDlg = FileDialog.new()
onready var saveDlg = FileDialog.new()

const LevelData = preload("res://Scripts/LevelData.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	loadDlg.resizable = true
	loadDlg.popup_exclusive = true
	loadDlg.access = FileDialog.ACCESS_FILESYSTEM
	loadDlg.mode = FileDialog.MODE_OPEN_FILE
	loadDlg.set_filters(PoolStringArray(["*.bme ; Jxpxxzj Ballance Map Editor format"]))
	uiRoot.call_deferred("add_child", loadDlg)
	loadDlg.connect("file_selected", self, "_on_LoadButton_DialogConfirmed")

	saveDlg.resizable = true
	saveDlg.popup_exclusive = true
	saveDlg.access = FileDialog.ACCESS_FILESYSTEM
	saveDlg.set_filters(PoolStringArray(["*.bme ; Jxpxxzj Ballance Map Editor format"]))
	uiRoot.call_deferred("add_child", saveDlg)
	saveDlg.connect("file_selected", self, "_on_SaveButton_DialogConfirmed")


func _on_SaveButton_pressed():
	saveDlg.popup_centered_ratio()


func _on_LoadButton_pressed():
	loadDlg.popup_centered_ratio()


func _on_SaveButton_DialogConfirmed(path: String):
	print(path)


func _on_LoadButton_DialogConfirmed(path: String):
	print(path)
	var levelData = LevelData.new()
	var succ = levelData.parse_from_bme_file(path)
	print(succ)
	levelData.set_gridmap_from_level_data(gridmap_node)
