extends TowerBehavior


var bloodlust_bt: BuffType
var aura_bt: BuffType


func get_tier_stats() -> Dictionary:
	return {
		1: {bloodlust_crit_damage = 0.45, bloodlust_crit_damage_add = 0.004, bloodlust_attackspeed = 0.15, bloodlust_attackspeed_add = 0.002, bloody_experience_range = 250, bloody_experience_level_cap = 10, bloodlust_level = 150, bloodlust_level_add = 2},
		2: {bloodlust_crit_damage = 0.55, bloodlust_crit_damage_add = 0.006, bloodlust_attackspeed = 0.20, bloodlust_attackspeed_add = 0.003, bloody_experience_range = 300, bloody_experience_level_cap = 15, bloodlust_level = 200, bloodlust_level_add = 3},
		3: {bloodlust_crit_damage = 0.65, bloodlust_crit_damage_add = 0.008, bloodlust_attackspeed = 0.25, bloodlust_attackspeed_add = 0.004, bloody_experience_range = 350, bloody_experience_level_cap = 20, bloodlust_level = 250, bloodlust_level_add = 4},
	}

const BLOODLUST_DURATION: float = 5.0
const BLOODLUST_DURATION_ADD: float = 0.12
const BLOODY_EXPERIENCE_RANGE: float = 250
const BLOODY_EXPERIENCE_EXP_GAIN: float = 1


func get_ability_description() -> String:
	var bloody_experience_level_cap: String = Utils.format_float(_stats.bloody_experience_level_cap, 2)
	var bloody_experience_range: String = Utils.format_float(_stats.bloody_experience_range, 2)
	var bloody_experience_gain: String = Utils.format_float(BLOODY_EXPERIENCE_EXP_GAIN, 2)
	
	var text: String = ""

	text += "[color=GOLD]Bloody Experience - Aura[/color]\n"
	text += "Every tower below %s level in %s range receives %s experience every time it crits. The amount of experience gained is base attackspeed and range adjusted. Level cap does not affect the Shaman himself.\n" % [bloody_experience_level_cap, bloody_experience_range, bloody_experience_gain]
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "+1 level cap every 5 levels\n"

	return text


func get_ability_description_short() -> String:
	var text: String = ""

	text += "[color=GOLD]Bloody Experience - Aura[/color]\n"
	text += "Nearby towers receive experience every time they crit.\n"

	return text


func get_autocast_description() -> String:
	var bloodlust_crit_damage: String = Utils.format_float(_stats.bloodlust_crit_damage, 2)
	var bloodlust_crit_damage_add: String = Utils.format_float(_stats.bloodlust_crit_damage_add, 3)
	var bloodlust_attackspeed: String = Utils.format_percent(_stats.bloodlust_attackspeed, 2)
	var bloodlust_attackspeed_add: String = Utils.format_percent(_stats.bloodlust_attackspeed_add, 2)

	var text: String = ""

	text += "The Shaman makes a friendly tower lust for blood, increasing its crit damage by x%s and attackspeed by %s for %s seconds.\n" % [bloodlust_crit_damage, bloodlust_attackspeed, BLOODLUST_DURATION]
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "+x%s crit damage\n" % bloodlust_crit_damage_add
	text += "+%s attackspeed\n" % bloodlust_attackspeed_add
	text += "+%s seconds duration\n" % BLOODLUST_DURATION_ADD

	return text


func get_autocast_description_short() -> String:
	var text: String = ""

	text += "The Shaman makes a friendly tower lust for blood, increasing its crit damage and attackspeed.\n"

	return text



# NOTE: this tower's tooltip in original game includes
# innate stats
func load_specials(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_SPELL_CRIT_CHANCE, 0.1375, 0.0)


func get_ability_ranges() -> Array[RangeData]:
	return [RangeData.new("Bloodlust", 500, TargetType.new(TargetType.TOWERS))]


func tower_init():
	bloodlust_bt = BuffType.new("bloodlust_bt", 0, 0, true, self)
	var bloodlust_mod: Modifier = Modifier.new()
	bloodlust_mod.add_modification(Modification.Type.MOD_ATTACKSPEED, 0.0, 0.001)
	bloodlust_mod.add_modification(Modification.Type.MOD_ATK_CRIT_DAMAGE, 0.15, 0.002)
	bloodlust_bt.set_buff_icon("orb_triple.tres")
	bloodlust_bt.set_buff_modifier(bloodlust_mod)
	bloodlust_bt.set_buff_tooltip("Bloodlust\nIncreases crit damage and attack speed.")

	aura_bt = BuffType.create_aura_effect_type("aura_bt", true, self)
	aura_bt.add_event_on_damage(bloody_exp_aura_on_damage)
	aura_bt.set_buff_icon("goldbar.tres")
	aura_bt.set_buff_tooltip("Bloody Experience\nGrants experience every time tower crits.")

	var autocast: Autocast = Autocast.make()
	autocast.title = "Bloodlust"
	autocast.description = get_autocast_description()
	autocast.description_short = get_autocast_description_short()
	autocast.icon = "res://path/to/icon.png"
	autocast.caster_art = ""
	autocast.num_buffs_before_idle = 1
	autocast.autocast_type = Autocast.Type.AC_TYPE_OFFENSIVE_BUFF
	autocast.cast_range = 500
	autocast.target_self = true
	autocast.target_art = "BloodlustTarget.mdl"
	autocast.cooldown = 5
	autocast.is_extended = false
	autocast.mana_cost = 15
	autocast.buff_type = bloodlust_bt
	autocast.target_type = TargetType.new(TargetType.TOWERS)
	autocast.auto_range = 500
	autocast.handler = on_autocast
	tower.add_autocast(autocast)


func get_aura_types() -> Array[AuraType]:
	var aura: AuraType = AuraType.new()
	aura.aura_range = _stats.bloody_experience_range
	aura.target_type = TargetType.new(TargetType.TOWERS)
	aura.target_self = true
	aura.level = 1
	aura.level_add = 0
	aura.power = 1
	aura.power_add = 0
	aura.aura_effect = aura_bt
	return [aura]


func on_autocast(event: Event):
	var level: int = tower.get_level()
	var buff_level: int = _stats.bloodlust_level + _stats.bloodlust_level_add * level
	var buff_duration: float = BLOODLUST_DURATION + BLOODLUST_DURATION_ADD * level

	bloodlust_bt.apply_custom_timed(tower, event.get_target(), buff_level, buff_duration)


func bloody_exp_aura_on_damage(event: Event):
	var buff: Buff = event.get_buff()
	var caster: Tower = buff.get_caster()
	var buffed_tower: Tower = buff.get_buffed_unit()
	var max_level_for_gain: int = _stats.bloody_experience_level_cap + caster.get_level() / 5

	if event.get_number_of_crits() > 0 && (buffed_tower.get_level() < max_level_for_gain || buffed_tower == caster):
		var exp_gained: float = BLOODY_EXPERIENCE_EXP_GAIN * buffed_tower.get_base_attackspeed() * (800.0 / buffed_tower.get_range())
		buffed_tower.add_exp(exp_gained)

