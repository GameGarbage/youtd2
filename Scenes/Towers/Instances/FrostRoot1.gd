extends Tower


func _get_tier_stats() -> Dictionary:
	return {
		1: {damage = 25, damage_add = 1},
		2: {damage = 125, damage_add = 5},
		3: {damage = 375, damage_add = 15},
		4: {damage = 750, damage_add = 30},
		5: {damage = 1500, damage_add = 60},
		6: {damage = 2500, damage_add = 100},
	}


func get_extra_tooltip_text() -> String:
	return "[color=gold]Frozen Thorn[/color]\nHas a 15%% chance to deal %d additional spell damage each time it deals damage.\n[color=orange]Level Bonus:[/color]\n+%d spell damage" % [_stats.damage, _stats.damage_add]


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(self, "_on_damage", 1.0, 0.0)


func _on_damage(event: Event):
	var tower = self

	if event.is_main_target() && tower.calc_chance(0.15) && !event.get_target().is_immune():
		Utils.sfx_at_unit("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl", event.get_target())
		tower.do_spell_damage(event.get_target(), _stats.damage + _stats.damage_add * get_level(), tower.calc_spell_crit_no_bonus())