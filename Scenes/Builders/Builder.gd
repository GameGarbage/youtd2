class_name Builder extends Node


# Base class for builder instances. Defines functions which
# should be overriden in subclasses. Some of these functions
# will be called once after builder is selected. Other
# functions will be called multiple times during gameplay,
# as callbacks.


var _id: int
var _tower_buff: BuffType
var _creep_buff: BuffType
var _tower_modifier: Modifier
var _creep_modifier: Modifier


#########################
###     Built-in      ###
#########################

func _ready():
	_tower_buff = _get_tower_buff()
	_creep_buff = _get_creep_buff()
	_tower_modifier = _get_tower_modifier()
	_creep_modifier = _get_creep_modifier()
	
	var builder_name: String = BuilderProperties.get_display_name(_id)

	if _tower_buff != null:
		_tower_buff.set_buff_tooltip("Buff from builder %s" % builder_name)
		_tower_buff.set_hidden()
	
	if _creep_buff != null:
		_creep_buff.set_buff_tooltip("Buff from builder %s" % builder_name)
		_creep_buff.set_hidden()


#########################
###       Public      ###
#########################

func apply_effects(unit: Unit):
	var buff: BuffType
	var modifier: Modifier

	if unit is Tower:
		buff = _tower_buff
		modifier = _tower_modifier
	elif unit is Creep:
		buff = _creep_buff
		modifier = _creep_modifier
	else:
		buff = null
		modifier = null

	if buff != null:
		buff.apply(unit, unit, unit.get_level())

	if modifier != null:
		unit.add_modifier(modifier)


#########################
###  Override methods ###
#########################

func _get_tower_buff() -> BuffType:
	return null


func _get_creep_buff() -> BuffType:
	return null


# NOTE: if your builder needs to modify unit stats, use
# modifiers instead of buffs. This way, modifiers will be
# affected by unit leveling up. Modifiers applied via buffs
# will NOT be affected by level ups.
func _get_tower_modifier() -> Modifier:
	return null


func _get_creep_modifier() -> Modifier:
	return null


#########################
###       Static      ###
#########################


static func create_instance(id: int) -> Builder:
	var script_name: String = BuilderProperties.get_script_name(id)
	var script_path: String = "res://Scenes/Builders/Instances/%s.gd" % script_name
	var builder_script = load(script_path)
	var builder_instance: Builder = builder_script.new()
	builder_instance._id = id

	return builder_instance