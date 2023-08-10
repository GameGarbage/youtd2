class_name BottomMenuBar extends Control


signal research_element()
signal test_signal()

@export var _item_bar: GridContainer
@export var _build_bar: GridContainer
@export var _item_menu_button: Button
@export var _building_menu_button: Button
@export var _research_panel: Control
@export var _research_button: Button
@export var _elements_container: HBoxContainer
@export var _tomes_status: ResourceStatusPanel
@export var _gold_status: ResourceStatusPanel


func _ready():
	for element_button in get_element_buttons():
		element_button.pressed.connect(_on_ElementButton_pressed.bind(element_button))

	set_element(Element.enm.ICE)


func _process(_delta):
	var item_button_count: int = _item_bar.get_item_count()
	_item_menu_button.text = str(item_button_count)
	
	_building_menu_button.text = str(_build_bar.get_child_count())


# NOTE: below are getters for elements inside bottom menu
# bar which are used as targets by TutorialMenu. This is to
# avoid hardcoding paths to these elements in TutorialMenu.
func get_research_button() -> Control:
	return _research_button


func get_elements_container() -> Control:
	return _elements_container


func get_tomes_status() -> Control:
	return _tomes_status


func get_gold_status() -> Control:
	return _gold_status


func get_item_menu_button() -> Button:
	return _item_menu_button


func set_element(element: Element.enm):
#	Dim the color of unselected element buttons
	var buttons: Array = get_element_buttons()

	for button in buttons:
		var button_is_selected: bool = button.element == element

		if button_is_selected:
			button.modulate = Color.WHITE
		else:
			button.modulate = Color.WHITE.darkened(0.4)

	if element == Element.enm.NONE:
		_item_bar.show()
		_build_bar.hide()
	else:
		_item_bar.hide()
		_build_bar.show()
		_build_bar.set_element(element)


# NOTE: have to manually call this because ItemMovement
# can't detect clicks on right menu bar.
func _gui_input(event):
	if event.is_action_released("left_click"):
		ItemMovement.on_clicked_on_right_menu_bar()

func get_element_buttons() -> Array:
	return get_tree().get_nodes_in_group("element_button")


func _on_ItemMenuButton_pressed():
	set_element(Element.enm.NONE)


func _on_ElementButton_pressed(element_button):
	set_element(element_button.element)


func _on_BuildMenuButton_pressed():
	set_element(_build_bar.get_element())


func _on_research_button_pressed():
	_research_panel.visible = !_research_panel.visible