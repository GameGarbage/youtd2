class_name Buff
extends Node2D


# Buff stores buff parameters and applies them to target
# while it is active. Subclasses should be defined in
# separate scripts because script path is used to get the
# unique identifier for buff. If you want to define a
# subclass as inner class, you must override get_id() and
# return something unique.

# TODO: what is friendly used for? It's not used as sign
# multiplier on value (confirmed by original tower scripts).
# Maybe used for stacking behavior?

# TODO: EventType.CLEANUP is currently fired when buff is
# overriden. Need to figure out how cleanup works together
# with REFRESH and UPGRADED event types. If a buff is
# refreshed, should both CLEANUP and REFRESH fire or just
# REFRESH? If so, then refresh needs to reuse current buff
# instance instead of current behavior which is replacing
# with new instance.

# TODO: implement the following event types
# SPELL_CAST
# SPELL_TARGET
# KILL
# ATTACK
# ATTACKED
# DAMAGE
# EXPIRE
# UPGRADE
# REFRESH
# PURGED
# UNIT_IN_RANGE

signal expired()

enum ModifierLevelType {
	TOWER,
	BUFF,
}

enum EventType {
	CLEANUP,
	CREATE,
	DEATH,
	LEVEL_UP,
	DAMAGED,
}

enum TargetType {
	TOWER,
	MOB,
	ALL,
}

class EventHandler:
	var handler_function: String
	var has_chance: bool
	var chance: float
	var chance_level_add: float


var _caster: Unit
var _target: Unit
var _modifier: Modifier setget set_modifier, get_modifier
var _timer: Timer
var _level: int
var _modifier_level_type: int = ModifierLevelType.TOWER
var _friendly: bool
# Map of EventType -> list of EventHandler's
var event_handler_map: Dictionary = {}


func _init(caster: Unit, time: float, time_level_add: float, level: int, friendly: bool):
	_caster = caster
	_level = level
	_friendly = friendly

#	NOTE: set a default empty modifier for convenience so that
# 	buffs that don't use modifiers don't need to set it
	var default_modifier: Modifier = Modifier.new()
	set_modifier(default_modifier)

	_timer = Timer.new()
	add_child(_timer)
# 	Set autostart so timer starts when add_child() is called
# 	on buff
	_timer.autostart = true
	var total_time: float = time + time_level_add * _level
	_timer.wait_time = total_time
	_timer.connect("timeout", self, "_on_timer_timeout")


# Called by Unit when buff is applied successfully
func applied_successfully(target: Unit):
	_target = target
	_target.connect("dead", self, "_on_target_dead")
	_target.connect("level_up", self, "_on_target_level_up")
	_target.connect("damaged", self, "_on_target_damaged")

	_call_event_handler_list(EventType.CREATE)


func set_modifier_level_type(level_type: int):
	_modifier_level_type = level_type
	
	if _modifier != null:
		_modifier.level = _get_modifier_level()


func set_modifier(modifier: Modifier):
	_modifier = modifier
	_modifier.level = _get_modifier_level()


func get_modifier() -> Modifier:
	return _modifier


func get_level() -> int:
	return _level


func get_id() -> String:
	var script: Reference = get_script()
	var id: String = script.get_path()

	return id


func get_target() -> Unit:
	return get_parent() as Unit


func stop():
	_on_timer_timeout()


func add_event_handler_periodic(handler_function: String, period: float):
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = period
	timer.one_shot = false
	timer.autostart = true
	timer.connect("timeout", self, "on_periodic_event_timer_timeout", [handler_function])


# Handler will be called with the following arguments:
# (buff: Buff, unit: Unit) unit is the unit that came in
# range and triggered the event
func add_event_handler_unit_comes_in_range(handler_function: String, radius: float, target_type: int):
	var buff_range_area_scene: PackedScene = load("res://Scenes/Buffs/BuffRangeArea.tscn")
	var buff_range_area = buff_range_area_scene.instance()
#	NOTE: use call_deferred() adding child immediately causes an error about
# 	setting shape during query flushing
	call_deferred("add_child", buff_range_area)
	buff_range_area.init(radius, target_type, handler_function)

	buff_range_area.connect("unit_came_in_range", self, "_on_unit_came_in_range")


func _on_unit_came_in_range(handler_function: String, unit: Unit):
	_caster.call(handler_function, self, unit)


func add_event_handler(event_type: int, handler_function: String):
	var handler: EventHandler = EventHandler.new()
	handler.handler_function = handler_function
	handler.has_chance = false
	handler.chance = 0.0
	handler.chance_level_add = 0.0

	_add_event_handler_internal(event_type, handler)


# NOTE: in original, only events of type
# attack/attacked/damage/damaged could have chance, but for
# convenience allow setting chance to all types of events
func add_event_handler_with_chance(event_type: int, handler_function: String, chance: float, chance_level_add: float):
	var handler: EventHandler = EventHandler.new()
	handler.handler_function = handler_function
	handler.has_chance = true
	handler.chance = chance
	handler.chance_level_add = chance_level_add

	_add_event_handler_internal(event_type, handler)


func _add_event_handler_internal(event_type: int, handler: EventHandler):
	if !event_handler_map.has(event_type):
		event_handler_map[event_type] = []

	event_handler_map[event_type].append(handler)


func _call_event_handler_list(event_type: int):
	if !event_handler_map.has(event_type):
		return

	var handler_list: Array = event_handler_map[event_type]

	for handler in handler_list:
		if handler.has_chance:
			var chance: float = min(1.0, handler.chance + handler.chance_level_add * _level)	
			var chance_success: bool = Utils.rand_chance(chance)

			if !chance_success:
				continue

		_caster.call(handler.handler_function, self)


func _get_modifier_level() -> int:
	match _modifier_level_type:
		ModifierLevelType.TOWER: return _caster.get_level()
		ModifierLevelType.BUFF: return get_level()
	return 0


func _on_timer_timeout():
	_call_event_handler_list(EventType.CLEANUP)

	emit_signal("expired")


func _on_target_dead():
	_call_event_handler_list(EventType.DEATH)
	_call_event_handler_list(EventType.CLEANUP)


func _on_target_level_up():
	_call_event_handler_list(EventType.LEVEL_UP)


func _on_target_damaged():
	_call_event_handler_list(EventType.DAMAGED)


func on_periodic_event_timer_timeout(handler_function: String):
	_caster.call(handler_function, self)
