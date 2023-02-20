extends Tower

# TODO: implement visual

func _get_tier_stats() -> Dictionary:
	return {
		1: {attack_speed = 0.03, miss_chance_add = 0.008},
		2: {attack_speed = 0.03, miss_chance_add = 0.009},
		3: {attack_speed = 0.03, miss_chance_add = 0.010},
		4: {attack_speed = 0.03, miss_chance_add = 0.011},
		5: {attack_speed = 0.03, miss_chance_add = 0.012},
		6: {attack_speed = 0.03, miss_chance_add = 0.013},
	}


func _ready():
	var on_damage_buff = Buff.new("")
	on_damage_buff.add_event_handler(Buff.EventType.DAMAGE, self, "on_damage")
	on_damage_buff.apply_to_unit_permanent(self, self, 0, true)

	var specials_modifier: Modifier = Modifier.new()
	specials_modifier.add_modification(Modification.Type.MOD_ATTACK_SPEED, 0, -_stats.attack_speed)
	add_modifier(specials_modifier)


func on_damage(event: Event):
	var tower = self

	if tower.calc_bad_chance(0.33 - _stats.miss_chance_add * tower.get_level()):
		event.damage = 0
		Utils.display_floating_text_x("Miss", tower, Color.red, 0.05, 0.0, 2.0)
