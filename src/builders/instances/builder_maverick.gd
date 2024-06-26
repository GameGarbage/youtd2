extends Builder


# TODO: the following bonus is not implemented:
# "Unable to share build areas with allies" - need to
# implement multiplier first


func _init():
	_allow_adjacent_towers = false


func apply_to_player(player: Player):
	player.modify_food_cap(-20)
	player.set_wisdom_upgrade_effect_multiplier(-0.375)


func _get_tower_modifier() -> Modifier:
	var mod: Modifier = Modifier.new()
	mod.add_modification(Modification.Type.MOD_DMG_TO_BOSS, 0.50, 0.0)
	mod.add_modification(Modification.Type.MOD_DMG_TO_CHAMPION, 0.25, 0.0)
	mod.add_modification(Modification.Type.MOD_DEBUFF_DURATION, -0.30, 0.0)
	mod.add_modification(Modification.Type.MOD_ITEM_CHANCE_ON_KILL, 0.0, 0.01)
	mod.add_modification(Modification.Type.MOD_DAMAGE_BASE_PERC, 0.0, 0.03)
	mod.add_modification(Modification.Type.MOD_SPELL_DAMAGE_DEALT, 0.0, 0.03)

	mod.add_modification(Modification.Type.MOD_BUFF_DURATION, -0.50, 0.03)

	return mod
