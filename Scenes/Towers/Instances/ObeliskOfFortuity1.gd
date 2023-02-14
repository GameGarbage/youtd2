extends Tower


const _tier_stats_map: Dictionary = {
	1: {miss_chance_base = 30},
	2: {miss_chance_base = 40},
	3: {miss_chance_base = 50},
	4: {miss_chance_base = 60},
	5: {miss_chance_base = 70},
}


func _ready():
	var warming_up = Buff.new("warming_up")
	warming_up.add_event_handler(Buff.EventType.DAMAGE, self, "on_damage")
	warming_up.apply_to_unit_permanent(self, self, 0, true)


func on_damage(event: Event):
	var tier: int = get_tier()
	var stats = _tier_stats_map[tier]
	var miss_chance: float = stats.miss_chance_base + get_level() * -0.006
	var missed: bool = calc_bad_chance(miss_chance)

	if missed:
		event.damage = 0
		Utils.display_floating_text_x("Miss", self, Color.red, 0.05, 0.0, 2.0)
