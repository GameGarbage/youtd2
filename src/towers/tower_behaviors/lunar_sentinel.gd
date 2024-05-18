extends TowerBehavior


var lunar_energy_bt: BuffType
var stun_bt: BuffType

# NOTE: I think there's a typo in tier 4 because for all
# other tiers spell_damage_chance_add is the same as
# spell_damage_add, but for tier 4 it's 1000 instead of 100.
# Leaving as in original.

func get_tier_stats() -> Dictionary:
	return {
		1: {spell_damage = 50, spell_damage_15 = 70, spell_damage_add = 2, spell_damage_chance_add = 2, buff_power = 120, buff_power_15 = 150},
		2: {spell_damage = 500, spell_damage_15 = 700, spell_damage_add = 20, spell_damage_chance_add = 20, buff_power = 160, buff_power_15 = 200},
		3: {spell_damage = 1500, spell_damage_15 = 2100, spell_damage_add = 60, spell_damage_chance_add = 60, buff_power = 200, buff_power_15 = 250},
		4: {spell_damage = 2500, spell_damage_15 = 3500, spell_damage_add = 100, spell_damage_chance_add = 1000, buff_power = 240, buff_power_15 = 300},
	}


func create_autocasts() -> Array[Autocast]:
	var autocast: Autocast = Autocast.make()

	var spell_damage: String = Utils.format_float(_stats.spell_damage, 2)
	var spell_damage_add: String = Utils.format_float(_stats.spell_damage_add, 2)
	var damage_from_spells: String = Utils.format_percent(_stats.buff_power * 0.1 * 0.01, 2)
	var damage_at_15: String = Utils.format_float(_stats.spell_damage_15 - _stats.spell_damage, 2)
	var damage_from_spells_at_15: String = Utils.format_percent((_stats.buff_power_15 - _stats.buff_power)  * 0.1 * 0.01, 2)

	autocast.title = "Lunar Grace"
	autocast.icon = "res://resources/icons/orbs/moon.tres"
	autocast.description_short = "Smites a target creep dealing spell damage. There is also a chance to stun the creep and make it more vulnerable to spells.\n"
	autocast.description = "Smites a target creep dealing %s spell damage to it. There is also a 12.5%% chance to empower the smite with lunar energy dealing %s additional spell damage, stunning the target for 0.3 seconds and making it receive %s more damage from spells for 2.5 seconds.\n" % [spell_damage, spell_damage, damage_from_spells] \
	+ " \n" \
	+ "[color=ORANGE]Level Bonus:[/color]\n" \
	+ "+%s inital and chanced spell damage\n" % spell_damage_add \
	+ "+0.5% chance\n" \
	+ "+%s initial damage at level 15\n" % damage_at_15 \
	+ "+%s spell damage received at level 15\n" % damage_from_spells_at_15 \
	+ "+0.1 seconds stun at level 25"
	autocast.caster_art = ""
	autocast.num_buffs_before_idle = 0
	autocast.autocast_type = Autocast.Type.AC_TYPE_OFFENSIVE_UNIT
	autocast.cast_range = 1200
	autocast.target_self = false
	autocast.target_art = "Abilities/Spells/Items/AIil/AIilTarget.mdl"
	autocast.cooldown = 2
	autocast.is_extended = true
	autocast.mana_cost = 0
	autocast.buff_type = null
	autocast.target_type = null
	autocast.auto_range = 1200
	autocast.handler = on_autocast

	return [autocast]


func tower_init():
	stun_bt = CbStun.new("stun_bt", 0, 0, false, self)

	var m: Modifier = Modifier.new()
	lunar_energy_bt = BuffType.new("lunar_energy_bt", 0, 0, false, self)
	m.add_modification(Modification.Type.MOD_SPELL_DAMAGE_RECEIVED, 0, 0.001)
	lunar_energy_bt.set_buff_icon("res://resources/icons/generic_icons/polar_star.tres")

	lunar_energy_bt.set_buff_tooltip("Lunar Energy\nIncreases spell damage taken.")


func on_autocast(event: Event):
	var level: int = tower.get_level()
	var target: Unit = event.get_target()

	if level < 15:
		tower.do_spell_damage(target, _stats.spell_damage + level * _stats.spell_damage_add, tower.calc_spell_crit_no_bonus())
	else:
		tower.do_spell_damage(target, _stats.spell_damage_15 + level * _stats.spell_damage_add, tower.calc_spell_crit_no_bonus())

	if tower.calc_chance(0.125 + level * 0.005) == true:
		CombatLog.log_ability(tower, target, "Lunar Grace Bonus")

		tower.do_spell_damage(target, _stats.spell_damage + level * _stats.spell_damage_chance_add, tower.calc_spell_crit_no_bonus())

		if level < 25:
			stun_bt.apply_only_timed(tower, target, 0.3)
		else:
			stun_bt.apply_only_timed(tower, target, 0.4)

		if level < 15:
			lunar_energy_bt.apply_advanced(tower, target, 0, _stats.buff_power, 2.5)
		else:
			lunar_energy_bt.apply_advanced(tower, target, 0, _stats.buff_power_15, 2.5)
