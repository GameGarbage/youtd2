# Arcane Oil of Swiftness
extends ItemBehavior


func load_modifier(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_ATTACKSPEED, 0.04, 0.0016)
