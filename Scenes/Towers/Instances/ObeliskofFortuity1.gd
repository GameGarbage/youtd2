extends Tower


func _get_tier_stats() -> Dictionary:
	return {
		1: {miss_chance_base = 0.3},
		2: {miss_chance_base = 0.4},
		3: {miss_chance_base = 0.5},
		4: {miss_chance_base = 0.6},
		5: {miss_chance_base = 0.7},
	}


func get_extra_tooltip_text() -> String:
	var miss_chance_base: String = String.num(_stats.miss_chance_base * 100, 2)

	return "[color=gold]Warming Up[/color]\nEach attack of this tower has a %s%% chance to miss the target.\n[color=orange]Level Bonus:[/color]\n-0.6%% miss chance" % [miss_chance_base]


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(self, "on_damage", 1.0, 0.0)


func on_damage(event: Event):
	var tower = self

	if tower.calc_bad_chance(_stats.miss_chance_base - tower.get_level() * 0.006):
		event.damage = 0
		Utils.display_floating_text_x("Miss", tower, 255, 0, 0, 255, 0.05, 0.0, 2.0)