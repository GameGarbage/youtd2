class_name ItemType extends Node

enum enm {
	REGULAR,
	OIL,
	CONSUMABLE,
}

const LIST: Array[ItemType.enm] = [
		ItemType.enm.REGULAR,
		ItemType.enm.OIL,
		ItemType.enm.CONSUMABLE,
	]

static var _string_map: Dictionary = {
	ItemType.enm.REGULAR: "regular",
	ItemType.enm.OIL: "oil",
	ItemType.enm.CONSUMABLE: "consumable",
}


static func get_list() -> Array[ItemType.enm]:
	return LIST.duplicate()


static func convert_to_string(type: ItemType.enm) -> String:
	return _string_map[type]


static func from_string(string: String) -> ItemType.enm:
	var key = _string_map.find_key(string)
	
	if key != null:
		return key
	else:
		push_error("Invalid item type string: \"%s\"" % string)

		return ItemType.enm.REGULAR
