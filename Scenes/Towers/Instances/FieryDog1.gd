extends Tower


var cedi_helldog: BuffType

# NOTE: This is basically a magic number. Here's a table
# from original script demonstrating how it works for tier
# 2:
#
# 0.0005  0.003, 0.0045, 0.006, 0.0075, 0.009
# 0.05    0.05 , 0.05  , 0.05 , 0.05  , 0.05
#         70   , 210   , 840  , 1680  , 3360
func _get_tier_stats() -> Dictionary:
	return {
		1: {level_multiplier = 6},
		2: {level_multiplier = 9},
		3: {level_multiplier = 12},
		4: {level_multiplier = 15},
		5: {level_multiplier = 18},
	}


func load_triggers(triggers_buff_type: BuffType):
	triggers_buff_type.add_event_on_damage(self, "on_damage", 0.3, 0.0)


func tower_init():
	var mod: Modifier = Modifier.new()
	mod.add_modification(Modification.Type.MOD_DAMAGE_BASE_PERC, 0.05, 0.0005)

	cedi_helldog = BuffType.new("cedi_helldog", 5.0, 0.0, true)
	cedi_helldog.set_buff_icon("@@0@@")
	cedi_helldog.set_buff_modifier(mod)


func on_damage(_event: Event):
	var tower: Tower = self

	var I: Iterate = Iterate.over_units_in_range_of_caster(tower, TargetType.new(TargetType.TOWERS), 420.0)
	var U: Unit
	var B: Buff = null
	var effect: int = Effect.add_special_effect_target("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", tower, "origin")
	Effect.destroy_effect(effect)

	while true:
		U = I.next()

		if U == null:
			break

		B = U.get_buff_of_type(cedi_helldog)

		if B != null:
			if B.user_int < 100:
				cedi_helldog.apply(tower, U, B.get_level() + _stats.level_multiplier)
				B.user_int = B.user_int + 1
			else:
				B.refresh_duration()
		else:
			B = cedi_helldog.apply(tower, U, tower.get_level() * _stats.level_multiplier)
			B.user_int = 0