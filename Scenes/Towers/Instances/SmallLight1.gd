extends Tower


var sternbogen_holy_buff: BuffType


# NOTE: mod_value and mod_value_add are multiplied by 1000,
# leaving as in original
func _get_tier_stats() -> Dictionary:
	return {
		1: {magical_sight_range = 650, mod_value = 50, mod_value_add = 2, duration = 3, duration_add = 0.12},
		2: {magical_sight_range = 650, mod_value = 100, mod_value_add = 4, duration = 3, duration_add = 0.16},
		3: {magical_sight_range = 650, mod_value = 150, mod_value_add = 6, duration = 4, duration_add = 0.16},
		4: {magical_sight_range = 650, mod_value = 200, mod_value_add = 8, duration = 4, duration_add = 0.20},
		5: {magical_sight_range = 650, mod_value = 300, mod_value_add = 10, duration = 5, duration_add = 0.20},
	}


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(self, "on_damage", 1.0, 0.0)


func load_specials(_modifier: Modifier):
	var magical_sight: BuffType = MagicalSightBuff.new(_stats.magical_sight_range)
	magical_sight.apply_to_unit_permanent(self, self, 0)	


func tower_init():
	var light_mod: Modifier = Modifier.new()
	sternbogen_holy_buff = BuffType.new("sternbogen_holy_buff", 0.0, 0.0, false)
	light_mod.add_modification(Modification.Type.MOD_SPELL_DAMAGE_RECEIVED, 0.0, 0.001)
	light_mod.add_modification(Modification.Type.MOD_ATK_DAMAGE_RECEIVED, 0.0, 0.001)
	sternbogen_holy_buff.set_buff_modifier(light_mod)
	sternbogen_holy_buff.set_buff_icon("@@1@@")


func on_damage(event: Event):
	var tower = self

	var creep = event.get_target()
#	0.001 Basic Bonus
	var bufflevel: int = _stats.mod_value + _stats.mod_value_add * tower.get_level()
	if (Creep.Category.UNDEAD == creep.get_category()):
		sternbogen_holy_buff.apply_custom_timed(tower, event.get_target(), bufflevel, _stats.duration + _stats.duration_add * tower.getLevel())