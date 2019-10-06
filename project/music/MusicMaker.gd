extends Node2D

const MAJOR_SCALE = [0, 2, 4, 5, 7, 9, 11, 12]
const NOTE_DISTANCE = [0, 2, 3, 5, 7, 9, 10]
const FACTOR = pow(2, 1.0/12)
const VOLUMES = [0, -1.25, -2.5]

var elapsed_time := 0.0
var play_sequence : PoolVector3Array
var last_note
var start_time : float
var song_duration : float
var key_pressed := []
var is_recording := true
var offset := 0
var current_notes := {}

func _ready():
	for i in range(get_children().size()):
		var key = get_children()[i]
		key.get_node("AudioStreamPlayer").pitch_scale *= pow(FACTOR, MAJOR_SCALE[i] + NOTE_DISTANCE[offset]) 

func _input(event):
	if event.is_action_pressed("accelerate"):
		start_recording()
	elif event.is_action_pressed("reverse"):
		stop_recording()
		
func _process(delta):
	if is_recording:
		record_song(delta)
	else:
		play_custom_song(delta)

func stop_recording():
	if not is_recording:
		return
	is_recording = false
	for key in get_children():
		key.last_note = 0
	if play_sequence.size() > 0:
		elapsed_time = play_sequence[0].y
		song_duration = play_sequence[-1].z
	else:
		elapsed_time = 0
		song_duration = 0

func start_recording():
	for key in get_children():
		key.get_node("AudioStreamPlayer").stop()
	elapsed_time = 0
	is_recording = true
	play_sequence = PoolVector3Array([])

func record_song(delta):
	elapsed_time += delta
	for i in range(get_children().size()):
		var audio_stream = get_children()[i].get_node("AudioStreamPlayer")
		if key_pressed.find(i) == -1 and Input.is_action_pressed(str("key_", i+1)) and key_pressed.size() < 3:
			current_notes[i] = Vector3(i, elapsed_time, -1)
			if not audio_stream.playing:
				audio_stream.play()
				key_pressed.append(i)
				for audio_index in key_pressed:
					var aud = get_children()[audio_index].get_node("AudioStreamPlayer")
					aud.volume_db = VOLUMES[key_pressed.size()-1]
		elif key_pressed.find(i) != -1 and not Input.is_action_pressed(str("key_", i+1)):
			current_notes[i].z = elapsed_time
			play_sequence.append(current_notes[i])
			current_notes.erase(i)
			if audio_stream.playing:
				audio_stream.stop()
				key_pressed.erase(i)
				for audio_index in key_pressed:
					var aud = get_children()[audio_index].get_node("AudioStreamPlayer")
					aud.volume_db = VOLUMES[key_pressed.size()-1]

func play_custom_song(delta):
	elapsed_time += delta
	prints(play_sequence, elapsed_time)
	for key in get_children():
		key.handle_track(elapsed_time, play_sequence)
#	for i in range(last_note, play_sequence.size()):
#		var note = play_sequence[i]
#		if note.y <= elapsed_time and note.z > elapsed_time and not get_children()[note.x].get_node("AudioStreamPlayer").playing:
#			last_note = i
#			get_children()[note.x].get_node("AudioStreamPlayer").play()
#		elif note.z < elapsed_time and get_children()[note.x].get_node("AudioStreamPlayer").playing:
#			last_note += 1
#			get_children()[note.x].get_node("AudioStreamPlayer").stop()
	if elapsed_time > song_duration:
		if play_sequence.size() > 0:
			elapsed_time = play_sequence[0].y
		else:
			elapsed_time = 0
		for key in get_children():
			key.last_note = 0
		