# Scarab Amulet
extends ItemBehavior


func load_modifier(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_DAMAGE_ADD_PERC, 0.12, 0.0)
