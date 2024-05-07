class_name AutocastButton extends Button


const FALLBACK_AUTOCAST_ICON: String = "res://Resources/Textures/AbilityIcons/compass.tres"


var _autocast: Autocast = null
@export var _cooldown_indicator: CooldownIndicator
@export var _auto_mode_indicator: AutoModeIndicator
@export var _indicator_container: MarginContainer


#########################
###     Built-in      ###
#########################

func _ready():
	var icon_path: String = _autocast.icon
	var icon_path_is_valid: bool = ResourceLoader.exists(icon_path)

	if !icon_path_is_valid:
		push_error("Invalid icon path for autocast: %s" % icon_path)

		icon_path = FALLBACK_AUTOCAST_ICON

	var autocast_icon: Texture2D = load(icon_path)
	set_button_icon(autocast_icon)
		
	_cooldown_indicator.set_autocast(_autocast)
	_auto_mode_indicator.set_autocast(_autocast)

	var button_stylebox: StyleBox = get_theme_stylebox("normal", "Button")

#	NOTE: need to load margins here because they are not
#	finalized while in editor
	_indicator_container.add_theme_constant_override("margin_top", int(button_stylebox.content_margin_top))
	_indicator_container.add_theme_constant_override("margin_left", int(button_stylebox.content_margin_left))
	_indicator_container.add_theme_constant_override("margin_bottom", int(button_stylebox.content_margin_bottom))
	_indicator_container.add_theme_constant_override("margin_right", int(button_stylebox.content_margin_right))


func _gui_input(event):
	var pressed_right_click: bool = event.is_action_released("right_click")

	if pressed_right_click:
		EventBus.player_right_clicked_autocast.emit(_autocast)


func _make_custom_tooltip(for_text: String) -> Object:
	var label: RichTextLabel = Utils.make_rich_text_tooltip(for_text)

	return label


#########################
###       Public      ###
#########################

func set_autocast(autocast: Autocast):
	_autocast = autocast

	var tooltip: String = RichTexts.get_autocast_tooltip(_autocast)
	set_tooltip_text(tooltip)


#########################
###     Callbacks     ###
#########################

func _on_pressed():
	EventBus.player_clicked_autocast.emit(_autocast)
