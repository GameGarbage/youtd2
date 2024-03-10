extends Node


# NOTE: don't need to reset loaded sfx because they are
# Resources.
var _loaded_sfx_map: Dictionary = {}


#########################
###       Public      ###
#########################


# NOTE: this f-n is non-positional. Current viewport
# position doesn't affect the sfx.
func play_sfx(sfx_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if !Settings.get_bool_setting(Settings.ENABLE_SFX):
		return

	var audio_player_pool: AudioPlayerPool = get_tree().get_root().get_node_or_null("GameScene/AudioPlayerPool")
	if audio_player_pool == null:
		push_warning("audio_player_pool is null. You can ignore this warning during game restart.")
		return

	var sfx_player: AudioStreamPlayer = audio_player_pool.get_sfx_player()
	sfx_player.pitch_scale = pitch_scale
	sfx_player.volume_db = volume_db
	var sfx_stream: AudioStream = _get_sfx(sfx_name)

	var invalid_sfx: bool = sfx_stream == null || sfx_stream.get_length() == 0

	if invalid_sfx:
		if Config.print_sfx_errors():
			push_error("SFX [%s] doesn't exist." % sfx_name)
		return

	sfx_player.set_stream(sfx_stream)
	sfx_player.play()


func sfx_at_pos(sfx_name: String, sfx_position: Vector2, volume_db: float = 0.0):
	if !Settings.get_bool_setting(Settings.ENABLE_SFX):
		return

	var audio_player_pool: AudioPlayerPool = get_tree().get_root().get_node_or_null("GameScene/AudioPlayerPool")
	if audio_player_pool == null:
		push_warning("audio_player_pool is null. You can ignore this warning during game restart.")
		return

	var sfx_player: AudioStreamPlayer2D = audio_player_pool.get_2d_sfx_player()
	sfx_player.volume_db = volume_db
	var sfx_stream: AudioStream = _get_sfx(sfx_name)

	var invalid_sfx: bool = sfx_stream.get_length() == 0

	if invalid_sfx:
		return

	sfx_player.set_stream(sfx_stream)
	sfx_player.global_position = sfx_position
	sfx_player.play()


# NOTE: SFXAtUnit() in JASS
func sfx_at_unit(sfx_name: String, unit: Unit, volume_db: float = 0.0):
	var sfx_position: Vector2 = unit.get_visual_position()
	sfx_at_pos(sfx_name, sfx_position, volume_db)


# NOTE: SFXOnUnit() in JASS
func sfx_on_unit(sfx_name: String, unit: Unit, body_part: Unit.BodyPart, volume_db: float = 0.0):
	var sfx_position: Vector2 = unit.get_body_part_position(body_part)
	sfx_at_pos(sfx_name, sfx_position, volume_db)


func connect_sfx_to_signal_in_group(sfx_name, signal_name, group_name):
	var nodes = get_tree().get_nodes_in_group(group_name)
	for node in nodes:
		if node.has_signal(signal_name):
			node.connect(signal_name, func(): SFX.play_sfx(sfx_name))
			print_verbose("Node [%s] is in group [sfx_menu_click] and has [pressed] signal. Connect a sound to it." % node)
		else:
			print_verbose("Node [%s] is in group [sfx_menu_click] but has no [pressed] signal." % node)


#########################
###      Private      ###
#########################

func _get_sfx(sfx_name: String) -> AudioStream:
	if _loaded_sfx_map.has(sfx_name):
		return _loaded_sfx_map[sfx_name]

	if !sfx_name.ends_with(".mp3") && !sfx_name.ends_with(".wav") && !sfx_name.ends_with(".ogg"):
		if Config.print_sfx_errors():
			push_error("Sfx must be mp3, wav or ogg:", sfx_name)

		return AudioStreamMP3.new()

	var file_exists: bool = ResourceLoader.exists(sfx_name)

	if !file_exists:
		if Config.print_sfx_errors():
			push_error("Failed to find sfx at:", sfx_name)

		return AudioStreamMP3.new()

	var stream: AudioStream = load(sfx_name)

#	NOTE: turn off looping in case it was turned on in sfx's
#	.import file.
	if stream is AudioStreamMP3:
		var stream_mp3: AudioStreamMP3 = stream as AudioStreamMP3
		stream_mp3.loop = false
	elif stream is AudioStreamOggVorbis:
		var stream_ogg: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
		stream_ogg.loop = false

	_loaded_sfx_map[sfx_name] = stream

	return stream


