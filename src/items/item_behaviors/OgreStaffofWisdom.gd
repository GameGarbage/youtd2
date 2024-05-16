extends ItemBehavior


func load_modifier(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_DAMAGE_ADD_PERC, 0.20, 0.004)
	modifier.add_modification(Modification.Type.MOD_EXP_RECEIVED, -0.20, 0.0)
	modifier.add_modification(Modification.Type.MOD_BOUNTY_RECEIVED, -0.20, 0.0)
