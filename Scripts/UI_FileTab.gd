extends Tabs


onready var gridmap_node = $"/root/Spatial/GridMap"
onready var uiRoot = $"/root/Spatial/UI"
onready var loadDlg = FileDialog.new()
onready var saveDlg = FileDialog.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	loadDlg.resizable = true
	loadDlg.popup_exclusive = true
	loadDlg.access = FileDialog.ACCESS_FILESYSTEM
	loadDlg.mode = FileDialog.MODE_OPEN_FILE
	uiRoot.call_deferred("add_child", loadDlg)
	loadDlg.connect("file_selected", self, "_on_LoadButton_DialogConfirmed")

	saveDlg.resizable = true
	saveDlg.popup_exclusive = true
	saveDlg.access = FileDialog.ACCESS_FILESYSTEM
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