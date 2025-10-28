extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size = DisplayServer.window_get_size()
	$Control/Background.size = size
	var new = $Control/New
	var open = $Control/Open
	new.size.x = size.x/2
	new.size.y = size.y/4
	new.pivot_offset = new.size/2
	open.size.x = size.x/2
	open.size.y = size.y/4
	open.pivot_offset = new.size/2
	new.position.x = size.x/2 - new.size.x/2
	open.position.x = size.x/2 - new.size.x/2
	new.position.y = size.y/3 - new.size.y/2
	open.position.y = size.y*(2.0/3.0) - open.size.y/2
	new.pressed.connect(_create)
	open.pressed.connect(_open)
	
func _create():
	var file = FileDialog.new()
	file.use_native_dialog = true
	file.add_filter("*.json", "JSON files")
	file.file_mode = 4
	file.access = 2
	file.dialog_hide_on_ok = true
	file.file_selected.connect(Callable(self, "_on_save"))
	file.popup()

func _open():
	var file = FileDialog.new()
	file.use_native_dialog = true
	file.add_filter("*.json", "JSON files")
	file.file_mode = 0
	file.access = 2
	file.dialog_hide_on_ok = true
	file.file_selected.connect(Callable(self, "_on_open"))
	file.popup()
	
func _on_open(file):
	print(file)
	var files = FileAccess.open(file, FileAccess.READ)
	var song = JSON.parse_string(files.get_as_text())["Song"]
	var notes = JSON.parse_string(files.get_as_text())["Notes"]
	var instance = load("res://main.tscn").instantiate()
	# Pass your file path to the new scene (assuming it has a variable for it)
	instance.file = file
	instance.song = song
	instance.notes = notes
	# Replace the current scene
	var tree = get_tree()
	var current = tree.current_scene
	tree.root.add_child(instance)
	tree.current_scene = instance

	if current:
		current.queue_free()
	
func _on_save(filePath):
	print(filePath)
	var file = FileDialog.new()
	file.use_native_dialog = true
	file.add_filter("*.ogg,*.mp3", "Music files")
	file.file_mode = 0
	file.access = 2
	file.dialog_hide_on_ok = true
	file.file_selected.connect(Callable(_on_music_select.bind(filePath)))
	file.popup()
	
	
func _on_music_select(song, file):
	var files = FileAccess.open(file, FileAccess.WRITE)
	files.store_string(JSON.stringify({"Song":song,"Notes":[]}))
	files.close()
	var instance = load("res://main.tscn").instantiate()
	# Pass your file path to the new scene (assuming it has a variable for it)
	instance.file = file
	instance.song = song
	instance.notes = []
	# Replace the current scene
	var tree = get_tree()
	var current = tree.current_scene
	tree.root.add_child(instance)
	tree.current_scene = instance
	if current:
		current.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
