extends Control


# Displays next wave level how much time is left before it
# starts.

# TODO: special column
# TODO: color everything, races, armor, etc

@onready var _label: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var _wave_spawner: WaveSpawner = get_tree().get_root().get_node("GameScene/Map/WaveSpawner")


func _ready():
	WaveLevel.changed.connect(_update_text)

	_update_text()


func _process(_delta: float):
	_update_text()


func _update_text():
	_label.clear()
	
	var text: String = ""

	var current_wave_level: int = WaveLevel.get_current()

	if _wave_spawner.wave_is_in_progress():
		text += "Wave %d in progress\n" % [current_wave_level]
	else:
		var next_wave_level: int = current_wave_level + 1
		var wave_time: int = floor(_wave_spawner.get_time_left())
		var wave_time_minutes: int = floor(wave_time / 60.0)
		var wave_time_seconds: int = wave_time - wave_time_minutes * 60

		text += "Wave %d in %02d:%02d\n" % [next_wave_level, wave_time_minutes, wave_time_seconds]

	text += "[table=5]"

	text += "[cell]Level[/cell][cell]Size[/cell][cell]Race[/cell][cell]Armor[/cell][cell]Special[/cell]"

	for level in range(current_wave_level, current_wave_level + 5):
		var wave: Wave = _wave_spawner.get_wave(level)

		if wave == null:
			break

		var race_String: String = CreepCategory.convert_to_string(wave.get_race())
		var size_string: String = _get_size_combination_string(wave)
		var armor_string: String = ArmorType.convert_to_string(wave.get_armor_type())
		var special_string: String = ""

		text += "[cell]%d[/cell][cell]%s[/cell][cell]%s[/cell][cell]%s[/cell][cell]%s[/cell]" % [level, size_string, race_String, armor_string, special_string]
	
	text += "[/table]"

	_label.append_text(text)


func _on_start_next_wave_button_pressed():
	if _wave_spawner.wave_is_in_progress():
		Globals.error_message_label.add("Can't start next wave, wave is still in progress.")

		return

	_wave_spawner.force_start_next_wave()


# [MASS, MASS, MASS, CHAMPION]
# =>
# "3 Mass, 1 Champion"
func _get_size_combination_string(wave: Wave) -> String:
	var size_list: Array = wave.get_creeps_combination()

	var size_count_map: Dictionary = {}

	for creep_size in size_list:
		if !size_count_map.has(creep_size):
			size_count_map[creep_size] = 0

		size_count_map[creep_size] += 1

	var string_split: Array[String] = []

	var size_list_ordered: Array = size_count_map.keys()
	size_list_ordered.sort()

	for creep_size in size_list_ordered:
		if !size_count_map.has(creep_size):
			continue

		var count: int = size_count_map[creep_size]
		var size_string: String = CreepSize.convert_to_string(creep_size)

		string_split.append("%d %s" % [count, size_string])

	var string: String = ", ".join(string_split)

	return string
