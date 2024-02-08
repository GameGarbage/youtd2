extends Tower

var cb_stun: BuffType


func get_tier_stats() -> Dictionary:
	return {
		1: {on_damage_chance = 0.10, damage_add = 0.01},
		2: {on_damage_chance = 0.11, damage_add = 0.02},
		3: {on_damage_chance = 0.12, damage_add = 0.03},
		4: {on_damage_chance = 0.13, damage_add = 0.04},
		5: {on_damage_chance = 0.14, damage_add = 0.05},
}


func get_ability_description() -> String:
	var on_damage_chance: String = Utils.format_percent(_stats.on_damage_chance, 2)
	var damage_add: String = Utils.format_percent(_stats.damage_add, 2)

	var text: String = ""

	text += "[color=GOLD]Frozen Spears[/color]\n"
	text += "Has a %s chance to deal 50%% more damage and stun the target for 0.5 seconds.\n" % on_damage_chance
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "+%s damage\n" % damage_add
	text += "+0.01 seconds"

	return text


func get_ability_description_short() -> String:
	var text: String = ""

	text += "[color=GOLD]Frozen Spears[/color]\n"
	text += "Has a small chance to deal bonus damage and stun the target.\n"

	return text


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(on_damage)


func tower_init():
	cb_stun = CbStun.new("magnataur_warrior_stun", 1.0, 0, false, self)


func on_damage(event: Event):
	var tower: Tower = self

	if !tower.calc_chance(_stats.on_damage_chance):
		return

	var creep: Unit = event.get_target()
	var level: float = tower.get_level()

	CombatLog.log_ability(tower, creep, "Frozen Spears")

	if event.is_main_target():
		event.damage = event.damage * (1.5 + (_stats.damage_add * level))
		SFX.sfx_at_unit("Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl", creep)
		cb_stun.apply_only_timed(tower, creep, 0.5 + tower.get_level() * 0.01)
		var damage_text: String = Utils.format_float(event.damage, 0)
		tower.get_player().display_small_floating_text(damage_text, tower, 255, 150, 150, 0)
