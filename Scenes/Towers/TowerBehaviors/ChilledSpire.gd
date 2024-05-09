extends TowerBehavior


# NOTE: fixed two bugs which were present in original script.
# 
# 1. Health regen values were same for tier 1 and tier 2.
#    They should be different according to the tooltip.
#
# 2. Health regen reduction was not halved for bosses, only
#    the per level portion was halved. Fixed so that the
#    total regen reduction is halved for bosses.


var frozen_bt: BuffType


func get_tier_stats() -> Dictionary:
	return {
		1: {freeze_chance = 0.20, freeze_chance_add = 0.004, freeze_duration = 1.0, mod_regen = 0.20, mod_regen_add = 0.006},
		2: {freeze_chance = 0.25, freeze_chance_add = 0.005, freeze_duration = 1.2, mod_regen = 0.30, mod_regen_add = 0.008},
	}


const FREEZE_DURATION_ADD: float = 0.05


func get_ability_info_list() -> Array[AbilityInfo]:
	var freeze_chance: String = Utils.format_percent(_stats.freeze_chance, 2)
	var freeze_chance_add: String = Utils.format_percent(_stats.freeze_chance_add, 2)
	var freeze_duration: String = Utils.format_float(_stats.freeze_duration, 2)
	var freeze_duration_add: String = Utils.format_float(FREEZE_DURATION_ADD, 2)
	var mod_regen: String = Utils.format_percent(_stats.mod_regen, 2)
	var mod_regen_add: String = Utils.format_percent(_stats.mod_regen_add, 2)

	var list: Array[AbilityInfo] = []
	
	var ability: AbilityInfo = AbilityInfo.new()
	ability.name = "Cold"
	ability.icon = "res://Resources/Icons/magic/eye_blue.tres"
	ability.description_short = "This tower has a chance on attack to freeze the attacked creep and reduce its health regeneration.\n"
	ability.description_full = "This tower has a %s chance on attack to freeze the attacked creep and reduce its health regeneration by %s. The freeze lasts for %s second and cannot be reapplied on already frozen units. Chance to proc, health regeneration reduction and freeze duration are halved for bosses. Does not affect immune creeps.\n" % [freeze_chance, mod_regen, freeze_duration] \
	+ " \n" \
	+ "[color=ORANGE]Level Bonus:[/color]\n" \
	+ "+%s chance\n" % freeze_chance_add \
	+ "+%s seconds duration\n" % freeze_duration_add \
	+ "-%s hp regen\n" % mod_regen_add
	list.append(ability)

	return list


func load_triggers(triggers: BuffType):
	triggers.add_event_on_damage(on_damage)


func tower_init():
	frozen_bt = CbStun.new("frozen_bt", -1, 0, false, self)
	var mod: Modifier = Modifier.new()
	mod.add_modification(Modification.Type.MOD_HP_REGEN_PERC, 0.0, -0.001)
	frozen_bt.set_buff_modifier(mod)
	frozen_bt.set_buff_icon("res://Resources/Icons/GenericIcons/azul_flake.tres")
	frozen_bt.add_event_on_create(frozen_bt_on_create)
	frozen_bt.add_event_on_cleanup(frozen_bt_on_cleanup)
	frozen_bt.set_buff_tooltip("Frozen\nReduces health regeneration.")


func on_damage(event: Event):
	var level: int = tower.get_level()
	var creep: Creep = event.get_target()
	var already_has_buff: bool = creep.get_buff_of_type(frozen_bt) != null
	var effects_multiplier: float
	if creep.get_size() >= CreepSize.enm.BOSS:
		effects_multiplier = 0.5
	else:
		effects_multiplier = 1.0
	var chance: float = (_stats.freeze_chance + _stats.freeze_chance_add * level) * effects_multiplier
	var buff_level: int = int((_stats.mod_regen + _stats.mod_regen_add * level) * 1000 * effects_multiplier)
	var buff_duration: float = (_stats.freeze_duration + FREEZE_DURATION_ADD * level) * effects_multiplier

	if !tower.calc_chance(chance):
		return

	if creep.is_immune() || already_has_buff:
		return

	CombatLog.log_ability(tower, creep, "Cold")

	frozen_bt.apply_custom_timed(tower, creep, buff_level, buff_duration)
	SFX.sfx_at_unit("FreezingBreathTargetArt.mdl", creep)


# NOTE: pauseAnim() in original script
func frozen_bt_on_create(event: Event):
	var buff: Buff = event.get_buff()
	var creep: Creep = buff.get_buffed_unit()
	creep.set_unit_time_scale(0.0)


# NOTE: unPauseAnim() in original script
func frozen_bt_on_cleanup(event: Event):
	var buff: Buff = event.get_buff()
	var creep: Creep = buff.get_buffed_unit()
	creep.set_unit_time_scale(1.0)
