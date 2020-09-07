extends Tabs


onready var gridmap_node = $"/root/Spatial/GridMap"
onready var uiRoot = $"/root/Spatial/UI"
onready var loadDlg = FileDialog.new()
onready var saveDlg = FileDialog.new()
onready var confirmDlg = ConfirmationDialog.new()

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

	confirmDlg.popup_exclusive = true
	confirmDlg.dialog_text = "Any unsaved changes will lost, continue?"
	uiRoot.call_deferred("add_child", confirmDlg)
	confirmDlg.connect("confirmed", self, "_on_NewButton_DialogConfirmed")


func _on_SaveButton_pressed():
	saveDlg.popup_centered_ratio()


func _on_LoadButton_pressed():
	loadDlg.popup_centered_ratio()


func _on_NewButton_pressed():
	confirmDlg.popup_centered()


func _on_SaveButton_DialogConfirmed(path: String):
	print(path)
	var levelData = LevelData.new()
	var top_left = levelData.set_level_data_from_gridmap(gridmap_node)
	levelData.export_to_bme_file(path, top_left)


func _on_LoadButton_DialogConfirmed(path: String):
	print(path)
	var levelData = LevelData.new()
	var succ = levelData.parse_from_bme_file(path)
	print(succ)
	levelData.set_gridmap_from_level_data(gridmap_node)


func _on_NewButton_DialogConfirmed():
	gridmap_node.clear()
