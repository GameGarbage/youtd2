class_name AutocastButton extends Button


var _autocast: Autocast = null
@export var _cooldown_indicator: CooldownIndicator
@export var _auto_mode_indicator: AutoModeIndicator
@export var _indicator_container: MarginContainer


#########################
###     Built-in      ###
#########################

func _ready():
	_cooldown_indicator.set_autocast(_autocast)
	_auto_mode_indicator.set_autocast(_autocast)

	mouse_entered.connect(_on_mouse_entered)
	
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
		_autocast.toggle_auto_mode()


#########################
###       Public      ###
#########################

func set_autocast(autocast: Autocast):
	_autocast = autocast


#########################
###     Callbacks     ###
#########################

func _on_mouse_entered():
	var tooltip: String = RichTexts.get_autocast_tooltip(_autocast)
	ButtonTooltip.show_tooltip(self, tooltip)


func _on_pressed():
	_autocast.do_cast_manually()
