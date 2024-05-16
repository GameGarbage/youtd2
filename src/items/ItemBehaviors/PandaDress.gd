extends ItemBehavior


func load_modifier(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_SPELL_DAMAGE_DEALT, 0.10, 0.0)
	modifier.add_modification(Modification.Type.MOD_TRIGGER_CHANCES, 0.05, 0.01)
	modifier.add_modification(Modification.Type.MOD_BUFF_DURATION, 0.05, 0.01)
