class_name ItemDrop
extends Unit

# ItemDrop is the visual for the item when it is dropped on
# the ground. Contains item instance inside it.


var _item: Item = null
@export var _selection_area: Area2D

# NOTE: note calling Unit._set_unit_dimensions() because no
# sprite on base class and dimensions are not important for
# ItemDrop's.
func _ready():
	super()

	SelectUnit.connect_unit(self, _selection_area)
	_set_visual_node(self)

	selected.connect(_on_selected)
	
# 	TODO: calculate correct z index so that item drop is
# 	drawn behind creeps/towers when it should.
	z_index = 100


# NOTE: this must be called once after the itemdrop is created
# but before it's added to game scene.
func set_item(item: Item):
	_item = item


func get_id() -> int:
	return _item.get_id()

# NOTE: don't allow picking up invisible items
func _on_selected():
	var can_pickup: bool = _item._visible

	if can_pickup:
		_item.fly_to_stash(0.0)
