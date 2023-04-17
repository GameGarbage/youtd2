extends Tower


var cassim_slow: BuffType


func _get_tier_stats() -> Dictionary:
	return {
		1: {slow_base = 0.075, slow_add = 0.003, duration_base = 3, duration_add = 0.1},
		2: {slow_base = 0.100, slow_add = 0.004, duration_base = 4, duration_add = 0.2},
		3: {slow_base = 0.125, slow_add = 0.005, duration_base = 5, duration_add = 0.3},
		4: {slow_base = 0.150, slow_add = 0.006, duration_base = 6, duration_add = 0.4},
	}


func get_extra_tooltip_text() -> String:
	var slow_base: String = String.num(_stats.slow_base * 100, 2)
	var duration_base: String = String.num(_stats.duration_base, 2)
	var duration_add: String = String.num(_stats.duration_add, 2)
	var slow_add: String = String.num(_stats.slow_add * 100, 2)

	return "[color=gold]Icy Touch[/color]\nSlows attacked units by %s%% for %s seconds.\n[color=orange]Level Bonus:[/color]\n+%s seconds duration\n+%s%% slow" % [slow_base, duration_base, duration_add, slow_add]


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(self, "_on_damage", 1.0, 0.0)


func tower_init():
	cassim_slow = BuffType.new("cassim_slow", 0, 0, false)
	var slow_mod: Modifier = Modifier.new()
	slow_mod.add_modification(Modification.Type.MOD_MOVESPEED, 0, -0.001)
	cassim_slow.set_buff_icon("@@0@@")
	cassim_slow.set_buff_modifier(slow_mod)


func _on_damage(event: Event):
	var tower = self

	var lvl: int = tower.get_level()
	var slow: int = int((_stats.slow_base + lvl * _stats.slow_add) * 1000)
	var dur: int = int(_stats.duration_base + lvl * _stats.duration_add)

	cassim_slow.apply_custom_timed(tower, event.get_target(), slow, dur)