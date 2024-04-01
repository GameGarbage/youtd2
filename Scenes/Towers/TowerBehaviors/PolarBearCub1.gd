extends TowerBehavior


var sir_frost_furbolg: BuffType
var sir_frost_furbolg_2: BuffType


func get_tier_stats() -> Dictionary:
	return {
		1: {dmg_increase = 200},
		2: {dmg_increase = 250},
		3: {dmg_increase = 300},
	}


func get_ability_description() -> String:
	var dmg_increase: String = Utils.format_percent(_stats.dmg_increase * 0.001, 2)

	var text: String = ""

	text += "[color=GOLD]Cold Feet[/color]\n"
	text += "On attack this tower cools down decreasing its attackspeed by 5%% and increasing the damage it deals by %s. The cold lasts for 6 seconds and stacks up to 10 times.\n" % dmg_increase
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "-1% attackspeed reduction at level 15 and 25\n"

	return text


func get_ability_description_short() -> String:
	var text: String = ""

	text += "[color=GOLD]Cold Feet[/color]\n"
	text += "On attack this tower decreases its attack speed while increasing its damage.\n"

	return text


func load_triggers(triggers: BuffType):
	triggers.add_event_on_attack(on_attack)


func load_specials(_modifier: Modifier):
	tower.set_attack_style_splash({300: 0.35})


func on_cleanup(event: Event):
	var b: Buff = event.get_buff()
	b.get_buffed_unit().user_int = 0


func tower_init():
	var m: Modifier = Modifier.new()
	var m2: Modifier = Modifier.new()

	sir_frost_furbolg = BuffType.new("sir_frost_furbolg", 0, 0, true, self)
	m.add_modification(Modification.Type.MOD_ATTACKSPEED, 0, -0.001)
	sir_frost_furbolg.set_buff_modifier(m)
	sir_frost_furbolg.set_stacking_group("sir_frost_furbolg")
	sir_frost_furbolg.set_buff_icon("foot.tres")
	sir_frost_furbolg.add_event_on_cleanup(on_cleanup)
	sir_frost_furbolg.set_buff_tooltip("Cold Feet\nDecreases attack speed.")

	sir_frost_furbolg_2 = BuffType.new("sir_frost_furbolg_2", 0, 0, true, self)
	m2.add_modification(Modification.Type.MOD_DAMAGE_ADD_PERC, 0, 0.001)
	sir_frost_furbolg_2.set_buff_modifier(m2)
	sir_frost_furbolg_2.set_buff_icon("flexing_arm.tres")
	sir_frost_furbolg_2.set_buff_tooltip("Cold Arms\nIncreases attack damage.")


func on_attack(_event: Event):
	var power: int = 30
	tower.user_int = min(tower.user_int + 1, 10)

	if tower.get_level() < 15:
		power = 50
	elif tower.get_level() < 25:
		power = 40

	sir_frost_furbolg.apply_advanced(tower, tower, tower.user_int, tower.user_int * power, 6.0)
	sir_frost_furbolg_2.apply_advanced(tower, tower, tower.user_int, tower.user_int * _stats.dmg_increase, 6.0)


func on_create(_preceding_tower: Tower):
	tower.user_int = 0
