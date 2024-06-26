extends TowerBehavior


var firestorm_bt: BuffType

func get_tier_stats() -> Dictionary:
	return {
		1: {firestorm_chance = 0.12, firestorm_chance_add = 0.004, firestorm_damage = 100, firestorm_damage_add = 3},
		2: {firestorm_chance = 0.16, firestorm_chance_add = 0.005, firestorm_damage = 300, firestorm_damage_add = 10},
		3: {firestorm_chance = 0.20, firestorm_chance_add = 0.006, firestorm_damage = 800, firestorm_damage_add = 35},
		4: {firestorm_chance = 0.24, firestorm_chance_add = 0.007, firestorm_damage = 1400, firestorm_damage_add = 65},
	}


func get_ability_info_list() -> Array[AbilityInfo]:
	var firestorm_chance: String = Utils.format_percent(_stats.firestorm_chance, 2)
	var firestorm_chance_add: String = Utils.format_percent(_stats.firestorm_chance_add, 2)
	var firestorm_damage: String = Utils.format_float(_stats.firestorm_damage, 2)
	var firestorm_damage_add: String = Utils.format_float(_stats.firestorm_damage_add, 2)

	var list: Array[AbilityInfo] = []
	
	var ability: AbilityInfo = AbilityInfo.new()
	ability.name = "Firestorm"
	ability.icon = "res://resources/icons/tower_variations/mossy_acid_sprayer_red.tres"
	ability.description_short = "Attacks have a chance to cause repeating AoE spell damage around the main target.\n"
	ability.description_full = "Attacks have a %s chance to apply 3 charges of [color=GOLD]Firestorm[/color] to the target. Each second, a charge will be spent, dealing %s spell damage to enemies in 300 range. If the target already has charges, the charges will accumulate and a charge will be consumed instantly. On death all remaining [color=GOLD]Firestorm[/color] charges get consumed at once.\n" % [firestorm_chance, firestorm_damage] \
	+ " \n" \
	+ "[color=ORANGE]Level Bonus:[/color]\n" \
	+ "+%s chance\n" % firestorm_chance_add \
	+ "+%s damage\n" % firestorm_damage_add
	list.append(ability)

	return list


func load_triggers(triggers: BuffType):
	triggers.add_event_on_attack(on_attack)


func ashbringer_firestorm_damage(creep: Unit):
	var effect: int = Effect.create_scaled("DoomDeath.mdl", Vector3(creep.get_x(), creep.get_y(), 0), 0, 5)
	Effect.destroy_effect_after_its_over(effect)
	tower.do_spell_damage_aoe_unit(creep, 300, _stats.firestorm_damage + (_stats.firestorm_damage_add * tower.get_level()), tower.calc_spell_crit_no_bonus(), 0.0)


func ashbringer_firestorm_periodic(event: Event):
	var b: Buff = event.get_buff()
	var target: Unit = b.get_buffed_unit()
	b.user_int = b.user_int - 1
	if b.user_int <= 0:
#		need to do it in this order, because the damage can
#		kill the buff carrier, and removing buff after the
#		carrier is dead causes double free
		b.remove_buff()
	ashbringer_firestorm_damage(target)


func ashbringer_firestorm_setint(event: Event):
	var b: Buff = event.get_buff()
	b.user_int = b.get_power()


func firestorm(event: Event):
	var b: Buff = event.get_buff()
	var creep: Creep = b.get_buffed_unit() 
	var effect: int = Effect.create_scaled("DoomDeath.mdl", Vector3(creep.get_x(), creep.get_y(), 0), 0, 5)
	Effect.destroy_effect_after_its_over(effect)
	tower.do_spell_damage_aoe_unit(creep, 300, b.get_power()* (_stats.firestorm_damage + (_stats.firestorm_damage_add * tower.get_level())), tower.calc_spell_crit_no_bonus(), 0.0)


func tower_init():
	firestorm_bt = BuffType.new("firestorm_bt", 1000, 0, false, self)
	firestorm_bt.set_buff_icon("res://resources/icons/generic_icons/flame.tres")
	firestorm_bt.set_buff_tooltip("Firestorm\nPeriodically deals AoE damage.")
	firestorm_bt.add_event_on_create(ashbringer_firestorm_setint)
	firestorm_bt.add_periodic_event(ashbringer_firestorm_periodic, 1)
	firestorm_bt.add_event_on_death(firestorm)


func on_attack(event: Event):
	if !tower.calc_chance(_stats.firestorm_chance + _stats.firestorm_chance_add * tower.get_level()):
		return

	var creep: Unit = event.get_target()
	var b: Buff
	var i: int
	b = creep.get_buff_of_type(firestorm_bt)

	CombatLog.log_ability(tower, creep, "Firestorm")

	if b != null:
		ashbringer_firestorm_damage(creep)
		i = b.get_power() + 2
		b.set_power(i)
		b.user_int = i
	else:
		i = 3
		firestorm_bt.apply_custom_power(tower, creep, i, i)

