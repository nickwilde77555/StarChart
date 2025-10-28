extends Node2D
var file
var song
var player
var stream
var sposition = 0
var notes = []
var notesDisplay = []
var sSize

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.size = DisplayServer.window_get_size()
	sSize = DisplayServer.window_get_size()
	#1552, 648
	print(file)
	var songPlay = FileAccess.open(song, FileAccess.READ)
	if songPlay == null:
		print("Failed to open file")
		return
	
	var data = songPlay.get_buffer(songPlay.get_length())

	# Try OGG
	stream = AudioStreamOggVorbis.load_from_buffer(data)
	if stream == null:
		# Try MP3 (Godot 4.3+)
		stream = AudioStreamMP3.load_from_buffer(data)

	if stream == null:
		print("Unsupported format")
		return

	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.volume_linear = 0.5
	player.play()
	player.stream_paused = true
	player.finished.connect(_finished)
	$Background/PlayPause.button_down.connect(_PlayPause)
	$Background/Export.button_down.connect(_Export)
	
	
	$Background/sPosition.text = str(round_place(sposition, 2)) + " / " + str(round_place(stream.get_length(), 2))
	$Background/Lanes1.size.x = 648/3.3
	$Background/Lanes2.size.x = 648/3.3
	$Background/Lanes3.size.x = 648/3.3
	
	$Background/Lanes1.size.y = sSize.y
	$Background/Lanes2.size.y = sSize.y
	$Background/Lanes3.size.y = sSize.y
	
	var leftX = sSize.x/2.0 - 324
	var margin = 648/3.0 - 648/3.3
	
	$Background/Lanes1.position.x = leftX
	$Background/Lanes2.position.x = leftX + $Background/Lanes1.size.x + margin/3.0
	$Background/Lanes3.position.x = leftX + $Background/Lanes1.size.x*2 + margin/1.5
	
	$Background/LaneDisplay.size.x = sSize.x
	$Background/LaneDisplay.size.y = sSize.y/200
	$Background/LaneDisplay.position.x = 0
	$Background/LaneDisplay.position.y = sSize.y/2.0 - sSize.y/400
	
	for i in notes:
		var newRect = ColorRect.new()
		newRect.size.x = 648/3.3
		newRect.size.y = 1152/10.0
		newRect.position.x = leftX + $Background/Lanes1.size.x*int(i["Lane"]) + (margin/3.0)*int(i["Lane"])
		newRect.position.y = sSize.y/2.0 - int(i["Time"])
		newRect.z_index = 2
		notesDisplay.append(newRect)
		$Background.add_child(newRect)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if !player.stream_paused:
		sposition = player.get_playback_position() + AudioServer.get_time_since_last_mix()
		$Background/sPosition.text = str(round_place(sposition, 2)) + " / " + str(round_place(stream.get_length(), 2))
	for i in range(0, len(notes)):
		#notesDisplay[i].position.y = (sSize.y/2.0 - int(notes[i]["Time"])) + sposition*10
		notesDisplay[i].position.y = time_to_y(notes[i]["Time"]-sposition, sSize.y)
		
	
func _Export():
	var files = FileAccess.open(file, FileAccess.WRITE)
	var data = {"Song":song, "Notes":notes}
	print(data)
	files.store_string(JSON.stringify(data))
	files.close()
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "File successfully saved to " + file
	dialog.title = "File saved"
	add_child(dialog) # Add to current scene
	dialog.popup_centered()
	dialog.connect("modal_closed", Callable(dialog, "queue_free")) # Clean up after closing
	
	
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Key.KEY_S:
			player.pitch_scale = player.pitch_scale - 0.1
			print(player.pitch_scale)
		if event.keycode == Key.KEY_W:
			player.pitch_scale = player.pitch_scale + 0.1
			print(player.pitch_scale)
		
		if event.keycode == Key.KEY_SPACE:
			_PlayPause()
		
		if event.keycode == Key.KEY_Z:
			notes.pop_back()
			notesDisplay.pop_back()
			print("popped")
		
		if event.keycode == Key.KEY_1:
			notes.append({"Lane":0, "Time":y_to_time(sSize.y/2.0, sSize.y) + sposition})
			var newRect = ColorRect.new()
			newRect.size.x = 648/3.3
			newRect.size.y = 1152/10.0
			newRect.position.x = 0
			newRect.position.y = sSize.y/2.0 - ((0 - sSize.y/2.0) + sposition)
			newRect.z_index = 2
			notesDisplay.append(newRect)
			$Background/Lanes1.add_child(newRect)
		if event.keycode == Key.KEY_2:
			notes.append({"Lane":1, "Time":y_to_time(sSize.y/2.0, sSize.y) + sposition})
			var newRect = ColorRect.new()
			newRect.size.x = 648/3.3
			newRect.size.y = 1152/10.0
			newRect.position.x = 0
			newRect.position.y = sSize.y/2.0 - ((0 - sSize.y/2.0) + sposition)
			newRect.z_index = 2
			notesDisplay.append(newRect)
			$Background/Lanes2.add_child(newRect)
		if event.keycode == Key.KEY_3:
			notes.append({"Lane":2, "Time":y_to_time(sSize.y/2.0, sSize.y) + sposition})
			var newRect = ColorRect.new()
			newRect.size.x = 648/3.3
			newRect.size.y = 1152/10.0
			newRect.position.x = 0
			newRect.position.y = sSize.y/2.0 - ((0 - sSize.y/2.0) + sposition)
			newRect.z_index = 2
			notesDisplay.append(newRect)
			$Background/Lanes3.add_child(newRect)
		
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			player.stream_paused = false
			player.play(sposition-0.25)
			player.stream_paused = true
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			player.stream_paused = false
			player.play(sposition+0.25)
			player.stream_paused = true
		
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if $Background/Lanes1.get_global_rect().has_point(event.position):
				notes.append({"Lane":0, "Time":y_to_time(event.position.y, sSize.y) + sposition})
				print((event.position.y - sSize.y/2.0)/(sSize.y/2.0) + sposition)
				var newRect = ColorRect.new()
				newRect.size.x = 648/3.3
				newRect.size.y = 1152/10.0
				newRect.position.x = 0
				
				newRect.position.y = sSize.y/2.0 - ((event.position.y - sSize.y/2.0) + sposition)
				newRect.z_index = 2
				notesDisplay.append(newRect)
				$Background/Lanes1.add_child(newRect)
			if $Background/Lanes2.get_global_rect().has_point(event.position):
				notes.append({"Lane":1, "Time":y_to_time(event.position.y, sSize.y) + sposition})
				print((event.position.y - sSize.y/2.0)/(sSize.y/2.0) + sposition)
				var newRect = ColorRect.new()
				newRect.size.x = 648/3.3
				newRect.size.y = 1152/10.0
				newRect.position.x = 0
				
				newRect.position.y = sSize.y/2.0 - ((event.position.y - sSize.y/2.0) + sposition)
				newRect.z_index = 2
				notesDisplay.append(newRect)
				$Background/Lanes2.add_child(newRect)
			if $Background/Lanes3.get_global_rect().has_point(event.position):
				notes.append({"Lane":2, "Time":y_to_time(event.position.y, sSize.y) + sposition})
				print((event.position.y - sSize.y/2.0)/(sSize.y/2.0) + sposition)
				var newRect = ColorRect.new()
				newRect.size.x = 648/3.3
				newRect.size.y = 1152/10.0
				newRect.position.x = 0
				
				newRect.position.y = sSize.y/2.0 - ((event.position.y - sSize.y/2.0) + sposition)
				newRect.z_index = 2
				notesDisplay.append(newRect)
				$Background/Lanes3.add_child(newRect)

func y_to_time(y: float, height: float) -> float:
	return 1.0 - (2.0 * (y / height))

func time_to_y(time_value: float, height: float) -> float:
	return ((1.0 - time_value) / 2.0) * height


func _finished():
	player.play()

func _PlayPause():
	player.stream_paused = !bool(player.stream_paused)
	if player.stream_paused:
		$Background/PlayPause.text = "Paused"
	else:
		$Background/PlayPause.text = "Playing"
		
#credit to happycamper https://forum.godotengine.org/t/how-to-round-to-a-specific-decimal-place/27552
func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))
