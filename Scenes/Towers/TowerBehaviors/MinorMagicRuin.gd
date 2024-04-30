extends TowerBehavior


var illuminate_bt: BuffType


func get_tier_stats() -> Dictionary:
	return {
		1: {exp_bonus = 0.05, exp_bonus_add = 0.002},
		2: {exp_bonus = 0.10, exp_bonus_add = 0.004},
		3: {exp_bonus = 0.15, exp_bonus_add = 0.006},
		4: {exp_bonus = 0.20, exp_bonus_add = 0.008},
		5: {exp_bonus = 0.25, exp_bonus_add = 0.010},
		6: {exp_bonus = 0.30, exp_bonus_add = 0.012},
	}


func get_ability_description() -> String:
	var exp_bonus: String = Utils.format_percent(_stats.exp_bonus, 2)
	var exp_bonus_add: String = Utils.format_percent(_stats.exp_bonus_add, 2)

	var text: String = ""

	text += "[color=GOLD]Illuminate[/color]\n"
	text += "Attacks debuff the target, making it grant %s more experience once killed. This effect last 5 seconds.\n" % exp_bonus
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "+%s experience\n" % exp_bonus_add
	text += "+0.2 seconds"

	return text


func get_ability_description_short() -> String:
	var text: String = ""

	text += "[color=GOLD]Illuminate[/color]\n"
	text += "Attacks make the target grant more experience once killed."

	return text


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(on_damage)


func tower_init():
	var astral_mod: Modifier = Modifier.new()
	illuminate_bt = BuffType.new("illuminate_bt", 5, 0, false, self)
	astral_mod.add_modification(Modification.Type.MOD_EXP_GRANTED, _stats.exp_bonus, _stats.exp_bonus_add)
	illuminate_bt.set_buff_modifier(astral_mod)
	illuminate_bt.set_buff_icon("res://Resources/Textures/GenericIcons/polar_star.tres")
	
	illuminate_bt.set_buff_tooltip("Illuminate\nIncreases experience granted.")


func on_damage(event: Event):
	illuminate_bt.apply_custom_timed(tower, event.get_target(), tower.get_level(), 5 + tower.get_level() * 0.2)