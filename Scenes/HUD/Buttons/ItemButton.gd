class_name ItemButton
extends UnitButton


const ICON_SIZE_M = 128

var _item: Item : set = set_item, get = get_item

@export var _cooldown_indicator: CooldownIndicator
@export var _auto_mode_indicator: AutoModeIndicator
@export var _charges_label: Label

var _show_cooldown_indicator: bool = false
var _show_auto_mode_indicator: bool = false
var _show_charges: bool = false


#########################
###     Built-in      ###
#########################

func _ready():
	super._ready()
	set_rarity(ItemProperties.get_rarity(_item.get_id()))
	set_icon(ItemProperties.get_icon(_item.get_id()))
	
	var autocast: Autocast = _item.get_autocast()

	if autocast != null:
		_cooldown_indicator.set_autocast(autocast)
		_auto_mode_indicator.set_autocast(autocast)
	
	mouse_entered.connect(_on_mouse_entered)

	_cooldown_indicator.set_visible(_show_cooldown_indicator)
	_auto_mode_indicator.set_visible(_show_auto_mode_indicator)

	_on_item_charges_changed()


func _gui_input(event):
	var pressed_right_click: bool = event.is_action_released("right_click")
	var pressed_shift: bool = Input.is_action_pressed("shift")
	var shift_right_click: bool = pressed_shift && pressed_right_click

	if shift_right_click:
		var autocast: Autocast = _item.get_autocast()
		if autocast != null:
			autocast.toggle_auto_mode()
	elif pressed_right_click:
		var autocast: Autocast = _item.get_autocast()
		if autocast != null:
			autocast.do_cast_manually()

		if _item.is_consumable():
			_item.consume()


#########################
###       Public      ###
#########################

func show_cooldown_indicator():
	_show_cooldown_indicator = true


func show_auto_mode_indicator():
	_show_auto_mode_indicator = true


func show_charges():
	_show_charges = true


func get_item() -> Item:
	return _item


func set_item(value: Item):
	_item = value
	_item.charges_changed.connect(_on_item_charges_changed)


#########################
###     Callbacks     ###
#########################

func _on_mouse_entered():
	var tooltip: String = RichTexts.get_item_text(_item)
	ButtonTooltip.show_tooltip(self, tooltip)


func _on_item_charges_changed():
	var charges_count: int = _item.get_charges()
	var charges_text: String = str(charges_count)
	_charges_label.set_text(charges_text)

	var charges_should_be_visible: bool = _item.uses_charges() && _show_charges
	_charges_label.set_visible(charges_should_be_visible)


#########################
###       Static      ###
#########################

static func make(item: Item) -> ItemButton:
	var item_button: ItemButton = preload("res://Scenes/HUD/Buttons/ItemButton.tscn").instantiate()
	item_button.set_item(item)
	return item_button
