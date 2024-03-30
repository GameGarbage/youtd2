# Ritual Talisman
extends ItemBehavior


# NOTE: changed autocast.target_self to false. Original
# script sets it to true but according to description
# autocast is performed "on a nearby tower".

var drol_talisman: BuffType


func get_autocast_description() -> String:
	var text: String = ""

	text += "Performs a shamanistic ritual on a nearby tower, granting it 20% more experience gain and 10% more damage for 10 seconds.\n"
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "+0.8% experience\n"
	text += "+0.2% damage\n"
	
	return text


func item_init():
	var m: Modifier = Modifier.new()
	drol_talisman = BuffType.new("drol_talisman", 10, 0, true, self)
	drol_talisman.set_buff_icon("@@0@@")
	m.add_modification(Modification.Type.MOD_EXP_RECEIVED, 0.2, 0.008)
	m.add_modification(Modification.Type.MOD_DAMAGE_ADD_PERC, 0.1, 0.002)
	drol_talisman.set_buff_modifier(m)
	drol_talisman.set_buff_tooltip("Shamanistic Ritual\nIncreases experience received and attack damage.")

	var autocast: Autocast = Autocast.make()
	autocast.title = "Shamanistic Ritual"
	autocast.description = get_autocast_description()
	autocast.icon = "res://Resources/Textures/UI/Icons/gold_icon.tres"
	autocast.caster_art = ""
	autocast.target_art = "HealingWaveTarget.mdl"
	autocast.num_buffs_before_idle = 1
	autocast.autocast_type = Autocast.Type.AC_TYPE_OFFENSIVE_BUFF
	autocast.target_self = false
	autocast.cooldown = 10
	autocast.is_extended = false
	autocast.mana_cost = 0
	autocast.buff_type = drol_talisman
	autocast.target_type = TargetType.new(TargetType.TOWERS)
	autocast.cast_range = 450
	autocast.auto_range = 450
	autocast.handler = Callable()
	item.set_autocast(autocast)
