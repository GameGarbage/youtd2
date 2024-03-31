# Faithful Staff
extends ItemBehavior


func get_ability_description() -> String:
	var text: String = ""

	text += "[color=GOLD]Reward the Faithful[/color]\n"
	text += "Whenever the carrier of this item casts a spell on a friendly tower both towers gain 1 experience.\n"

	return text


func load_triggers(triggers: BuffType):
	triggers.add_event_on_spell_casted(on_spell_cast)


func on_spell_cast(event: Event):
	var tower: Unit = item.get_carrier()
	var target_unit: Unit = event.get_target()

	if target_unit is Tower:
		CombatLog.log_item_ability(item, null, "Reward the Faithful")
		
		target_unit.add_exp(1)
		tower.add_exp(1)