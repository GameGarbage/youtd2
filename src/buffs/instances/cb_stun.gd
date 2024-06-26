class_name CbStun
extends BuffType

# NOTE: analog of globally available cb_stun in JASS


# NOTE: BuffType.createDuplicate(cb_stun...) in JASS
func _init(type: String, time_base: float, time_level_add: float,friendly: bool, parent: Node):
	super(type, time_base, time_level_add, friendly, parent)
	add_event_on_create(on_create)
	add_event_on_cleanup(_on_cleanup)

#	NOTE: this is the default tooltip for stun buff. It may
#	be overriden in buffs that extend this buff.
	set_buff_tooltip("Stun\nStunned.")
	set_buff_icon("res://resources/icons/generic_icons/knocked_out_stars.tres")
	set_buff_icon_color(Color.WHITE)


func on_create(event: Event):
	var buff: Buff = event.get_buff()
	var target = buff.get_buffed_unit()

	target.add_stun()


func _on_cleanup(event: Event):
	var buff: Buff = event.get_buff()
	var target = buff.get_buffed_unit()

	target.remove_stun()
