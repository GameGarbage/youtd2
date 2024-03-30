# Magic Branch
extends ItemBehavior


func load_modifier(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_ATTACKSPEED, 0.05, 0.0)
	modifier.add_modification(Modification.Type.MOD_SPELL_DAMAGE_DEALT, 0.15, 0.0)
