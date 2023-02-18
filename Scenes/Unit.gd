class_name Unit
extends KinematicBody2D

# Unit is a base class for Towers and Mobs. Keeps track of
# buffs and modifications. Emits signals for events which are used by buffs.

# NOTE: can't use static typing for Buff because of cyclic
# dependency

signal level_up
signal attack(event)
signal attacked(event)
signal damage(event)
signal damaged(event)
signal kill(event)
signal death(event)

enum UnitProperty {
	TRIGGER_CHANCES,
	MOVE_SPEED,

#	Modifies buff durations for buffs cast by this unit
#	Applies to both friendly and unfriendly buffs
#	0.01 = +1% duration
	BUFF_DURATION,

#	Modifies buff durations for debuffs cast ONTO this unit
#	Debuffs are those with "friednly" set to false
#	0.01 = -1% duration
	DEBUFF_DURATION,
}


const MOVE_SPEED_MIN: float = 100.0
const MOVE_SPEED_MAX: float = 500.0

var _level: int = 1 setget set_level, get_level
var _buff_map: Dictionary
var _direct_modifier_list: Array
var _health: float = 100.0
var _unit_properties: Dictionary = {
	UnitProperty.TRIGGER_CHANCES: 0.0,
	UnitProperty.MOVE_SPEED: MOVE_SPEED_MAX,
	UnitProperty.BUFF_DURATION: 0.0,
	UnitProperty.DEBUFF_DURATION: 0.0,
}

const _unit_mod_to_property_map: Dictionary = {
	Modification.Type.MOD_TRIGGER_CHANCES: UnitProperty.TRIGGER_CHANCES,
	Modification.Type.MOD_MOVE_SPEED_ABSOLUTE: UnitProperty.MOVE_SPEED,
	Modification.Type.MOD_BUFF_DURATION: UnitProperty.BUFF_DURATION,
	Modification.Type.MOD_DEBUFF_DURATION: UnitProperty.DEBUFF_DURATION,
	Modification.Type.MOD_MOVE_SPEED: UnitProperty.MOVE_SPEED,
}

func _ready():
	pass


# TODO: implement
func is_immune() -> bool:
	return false


func calc_chance(chance_base: float) -> bool:
	var chance_mod: float = _unit_properties[UnitProperty.TRIGGER_CHANCES]
	var chance: float = chance_base + chance_mod
	var success: bool = Utils.rand_chance(chance)

	return success


# "Bad" chance is for events that decrease tower's
# perfomance, for example missing attack. In such cases the
# "trigger chances" property decreases the chance of the
# event occuring.
func calc_bad_chance(chance_base: float) -> bool:
	var chance_mod: float = _unit_properties[UnitProperty.TRIGGER_CHANCES]
	var chance: float = chance_base - chance_mod
	var success: bool = Utils.rand_chance(chance)

	return success


# TODO: implement, probably calculates total modifier from
# crit without multi-crit?
func calc_spell_crit_no_bonus() -> float:
	return 0.0


# TODO: implement _crit_mod.
# 
# TODO: is it safe to call _receive_damage()? That f-n
# triggers DAMAGED event. If there's a tower which somehow
# debuffs a unit so that everytime it's DAMAGED, the tower
# damages it again, then there will be infinite recursion.
# So far only saw that towers deal additional damaged in
# event handlers for DAMAGE.
func do_spell_damage(target: Unit, damage: float, _crit_mod: float, is_main_target: bool):
	# NOTE: do not call _do_damage(), that can cause infinite recursion
	target._receive_damage(self, damage, is_main_target)


# Adds modifier directly to unit. Modifier will
# automatically scale with this unit's level. If you need to
# make a modifier that scales with another unit's level, use
# buffs.
func add_modifier(modifier: Modifier):
	_apply_modifier(modifier, _level, 1)
	_direct_modifier_list.append(modifier)


func remove_modifier(modifier: Modifier):
	if _direct_modifier_list.has(modifier):
		_apply_modifier(modifier, _level, -1)
		_direct_modifier_list.append(modifier)


func set_level(new_level: int):
	var old_level: int = _level
	_level = new_level

#	NOTE: apply level change to modifiers
	for modifier in _direct_modifier_list:
		_apply_modifier(modifier, old_level, -1)
		_apply_modifier(modifier, new_level, 1)

	emit_signal("level_up")


func get_buff_duration_mod() -> float:
	return _unit_properties[UnitProperty.BUFF_DURATION]


func get_debuff_duration_mod() -> float:
	return _unit_properties[UnitProperty.DEBUFF_DURATION]


func get_level() -> int:
	return _level


func kill_instantly(target: Unit):
	target._killed_by_unit(self, true)


func modify_property(modification_type: int, modification_value: float, modify_direction: int):
	_modify_property_general(_unit_properties, _unit_mod_to_property_map, modification_type, modification_value, modify_direction)

#	Call subclass version
	_modify_property_subclass(modification_type, modification_value, modify_direction)


# NOTE: important to store move speed without clamping and
# clamp only the value that is returned by getter to avoid
# overflow issues.
func get_move_speed() -> float:
	var unclamped_value: float = _unit_properties[UnitProperty.MOVE_SPEED]
	var move_speed: float = min(MOVE_SPEED_MAX, max(MOVE_SPEED_MIN, unclamped_value))

	return move_speed


# TODO: implement
func is_invisible() -> bool:
	return false


func get_buff_of_type(type: String):
	var buff = _buff_map.get(type, null)

	return buff


func _do_attack(target: Unit):
	var attack_event: Event = Event.new(target, 0, true)
	emit_signal("attack", attack_event)

	target._receive_attack()


func _receive_attack():
	var attacked_event: Event = Event.new(self, 0, true)
	emit_signal("attacked", attacked_event)


# NOTE: this function should not be called in any event
# handlers or public Unit functions that can be called from
# event handlers because that can cause an infinite
# recursion of DAMAGE events causing infinite DAMAGE events.
func _do_damage(target: Unit, damage: float, is_main_target: bool):
	var damage_event: Event = Event.new(target, damage, is_main_target)
	emit_signal("damage", damage_event)

	target._receive_damage(self, damage_event.damage, is_main_target)


func _receive_damage(caster: Unit, damage: float, is_main_target: bool):
	_health -= damage

	var damaged_event: Event = Event.new(caster, damage, is_main_target)
	emit_signal("damaged", damaged_event)

	Utils.display_floating_text_x(String(int(damage)), self, Color.red, 0.0, 0.0, 1.0)

	if _health <= 0:
		_killed_by_unit(caster, is_main_target)

		return


func _killed_by_unit(caster: Unit, is_main_target: bool):
	var death_event: Event = Event.new(caster, 0, is_main_target)
	emit_signal("death", death_event)

	caster._accept_kill(self, is_main_target)

	queue_free()


# Called when unit kills another unit
func _accept_kill(target: Unit, is_main_target: bool):
	var kill_event: Event = Event.new(target, 0, is_main_target)
	emit_signal("kill", kill_event)


# This is for internal use in Buff.gd only. For external
# use, call Buff.apply_to_unit().
func _add_buff_internal(buff):
	var buff_type: String = buff.get_type()
	_buff_map[buff_type] = buff
	buff.connect("removed", self, "_on_buff_removed", [buff])
	var buff_modifier: Modifier = buff.get_modifier()
	_apply_modifier(buff_modifier, buff.get_level(), 1)
	add_child(buff)


func _on_buff_removed(buff):
	var buff_modifier: Modifier = buff.get_modifier()
	_apply_modifier(buff_modifier, buff.get_level(), -1)

	var buff_type: String = buff.get_type()
	_buff_map.erase(buff_type)
	buff.queue_free()


func _modify_property_subclass(_modification_type: int, _modification_value: float, _modify_direction: int):
	pass


# This f-n is used by Unit and Unit subclasses, because they
# have separate property maps and mod_to_property maps.
static func _modify_property_general(property_map: Dictionary, mod_to_property_map: Dictionary, modification_type: int, modification_value: float, modify_direction: int):
	var can_process_modification: bool = mod_to_property_map.has(modification_type)

	if !can_process_modification:
		return

	var property: int = mod_to_property_map[modification_type]
	var current_value: float = property_map[property]
	var new_value: float = 0.0

	var math_type: int = Modification.get_math_type(modification_type)

	match math_type:
		Modification.MathType.ADD:
			new_value = current_value + modify_direction * modification_value
		Modification.MathType.MULTIPLY:
			if modify_direction == 1:
				new_value = current_value * (1.0 + modification_value)
			elif modify_direction == -1:
				new_value = current_value / (1.0 + modification_value)
			else:
				new_value = current_value

	property_map[property] = new_value


func _apply_modifier(modifier: Modifier, level: int, modify_direction: int):
	var modification_list: Array = modifier.get_modification_list()

	for modification in modification_list:
		var level_bonus: float = modification.level_add * (level - 1)
		var value: float = modification.value_base + level_bonus

		modify_property(modification.type, value, modify_direction)
