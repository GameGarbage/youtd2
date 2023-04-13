extends Control


var _tower: Tower = null

@onready var _button_container: HBoxContainer = $PanelContainer/VBoxContainer/HBoxContainer


func set_tower(tower: Tower):
	var prev_tower: Tower = _tower
	var new_tower: Tower = tower
	_tower = new_tower

	if prev_tower != null:
		prev_tower.items_changed.disconnect(on_tower_items_changed)

	if new_tower != null:
		new_tower.items_changed.connect(on_tower_items_changed)
		on_tower_items_changed()


func on_tower_items_changed():
	for button in _button_container.get_children():
		button.queue_free()

	var items: Array[Item] = _tower.get_items()

	for item in items:
		var item_id: int = item.get_id()
		var item_button: ItemButton = _create_item_button(item_id)
		_button_container.add_child(item_button)


func _create_item_button(item_id: int) -> ItemButton:
	var item_button = ItemButton.new()
	item_button.set_item(item_id)
	item_button.button_down.connect(_on_item_button_pressed.bind(item_button))

	return item_button


func _on_item_button_pressed(item_button: ItemButton):
	var item_id: int = item_button.get_item()
	ItemMovement.start_move_from_tower(item_id, _tower)

#	Disable button to gray it out to indicate that it's
#	getting moved
# 	NOTE: don't need to re-enable because inventory buttons
# 	will be reloaded when move is complete, for all cases
	item_button.set_disabled(true)