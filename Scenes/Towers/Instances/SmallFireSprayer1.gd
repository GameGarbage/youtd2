extends Tower


func get_tier_stats() -> Dictionary:
	return {
		1: {miss_chance_add = 0.008},
		2: {miss_chance_add = 0.009},
		3: {miss_chance_add = 0.010},
		4: {miss_chance_add = 0.011},
		5: {miss_chance_add = 0.012},
		6: {miss_chance_add = 0.013},
	}


func get_ability_description() -> String:
	var miss_chance_add: String = Utils.format_percent(_stats.miss_chance_add, 2)

	var text: String = ""

	text += "[color=GOLD]Spray and Pray[/color]\n"
	text += "Each attack of this tower has a 33% chance to miss the target.\n"
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "-%s miss chance" % miss_chance_add

	return text


func get_ability_description_short() -> String:
	var text: String = ""

	text += "[color=GOLD]Spray and Pray[/color]\n"
	text += "Due to its high rate of fire, this tower often misses its target.\n"

	return text


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(on_damage)


# NOTE: this tower's tooltip in original game does NOT
# include innate stats
func load_specials(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_ATTACKSPEED, 0, 0.03)


func on_damage(event: Event):
	var tower = self

	if tower.calc_bad_chance(0.33 - _stats.miss_chance_add * tower.get_level()):
		event.damage = 0
		tower.get_player().display_floating_text_x("Miss", tower, Color8(255, 0, 0, 255), 0.05, 0.0, 2.0)
