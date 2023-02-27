class_name Tower
extends Building


enum CsvProperty {
	SCENE_NAME = 0,
	NAME = 1,
	ID = 2,
	FAMILY_ID = 3,
	AUTHOR = 4,
	RARITY = 5,
	ELEMENT = 6,
	ATTACK_TYPE = 7,
	ATTACK_RANGE = 8,
	ATTACK_CD = 9,
	ATTACK_DAMAGE_MIN = 10,
	ATTACK_DAMAGE_MAX = 11,
	COST = 12,
	DESCRIPTION = 13,
	TIER = 14,
	REQUIRED_ELEMENT_LEVEL = 15,
	REQUIRED_WAVE_LEVEL = 16,
	ICON_ATLAS_NUM = 17,
}

enum AttackStyle {
	NORMAL,
	SPLASH,
	BOUNCE,
}

enum Element {
	ICE ,
	NATURE,
	FIRE,
	ASTRAL,
	DARKNESS,
	IRON,
	STORM,
}

const _mob_type_to_mod_map: Dictionary = {
	Unit.MobType.UNDEAD: Unit.ModType.MOD_DMG_TO_MASS,
	Unit.MobType.MAGIC: Unit.ModType.MOD_DMG_TO_MAGIC,
	Unit.MobType.NATURE: Unit.ModType.MOD_DMG_TO_NATURE,
	Unit.MobType.ORC: Unit.ModType.MOD_DMG_TO_ORC,
	Unit.MobType.HUMANOID: Unit.ModType.MOD_DMG_TO_HUMANOID,
}

const _mob_size_to_mod_map: Dictionary = {
	Unit.MobSize.MASS: Unit.ModType.MOD_DMG_TO_MASS,
	Unit.MobSize.NORMAL: Unit.ModType.MOD_DMG_TO_NORMAL,
	Unit.MobSize.CHAMPION: Unit.ModType.MOD_DMG_TO_CHAMPION,
	Unit.MobSize.BOSS: Unit.ModType.MOD_DMG_TO_BOSS,
	Unit.MobSize.AIR: Unit.ModType.MOD_DMG_TO_AIR,
}

export(AudioStreamMP3) var attack_sound

const ATTACK_CD_MIN: float = 0.2

var _id: int = 0
var _stats: Dictionary
var _attack_autocast = null
var _projectile_scene: PackedScene = preload("res://Scenes/Projectile.tscn")
var _splash_map: Dictionary = {}
var _bounce_count_max: int = 0
var _bounce_damage_multiplier: float = 0.0
var _attack_style: int = AttackStyle.NORMAL


onready var _game_scene: Node = get_tree().get_root().get_node("GameScene")
onready var _attack_sound: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
onready var _range_indicator: RangeIndicator = $RangeIndicator


#########################
### Code starts here  ###
#########################

func _ready():
	_is_tower = true

# 	Load stats for current tier. Stats are defined in
# 	subclass.
	var tier: int = get_tier()
	var tier_stats: Dictionary = _get_tier_stats()
	_stats = tier_stats[tier]

	_attack_sound.set_stream(attack_sound)
	add_child(_attack_sound)

# 	NOTE: settings for attack autocast will be fully loaded
# 	_apply_properties_to_scene_children() is called
	var attack_autocast_data = Autocast.Data.new()
	attack_autocast_data.caster_art = ""
	attack_autocast_data.num_buffs_before_idle = 0
	attack_autocast_data.autocast_type = Autocast.Type.AC_TYPE_OFFENSIVE_UNIT
	attack_autocast_data.the_range = 0
	attack_autocast_data.target_self = false
	attack_autocast_data.target_art = ""
	attack_autocast_data.cooldown = 1
	attack_autocast_data.is_extended = true
	attack_autocast_data.mana_cost = 0
	attack_autocast_data.buff_type = 0
	attack_autocast_data.target_type = TargetType.new(TargetType.UnitType.MOBS)
	attack_autocast_data.auto_range = 0

	var attack_buff = TriggersBuff.new()
	_attack_autocast = attack_buff.add_autocast(attack_autocast_data, self, "_on_attack_autocast")
	attack_buff.apply_to_unit_permanent(self, self, 0)

	_apply_properties_to_scene_children()


#########################
###       Public      ###
#########################

# TODO: implement. Also move to the "owner" class that is
# returned by get_owner(), when owner gets implemented. Find
# out what mystery bools are for.
func give_gold(_amount: int, _unit: Unit, _mystery_bool_1: bool, _mystery_bool_2: bool):
	pass


func change_level(new_level: int):
	set_level(new_level)

# 	NOTE: properties could've change due to level up so
# 	re-apply them
	_apply_properties_to_scene_children()

func enable_default_sprite():
	$DefaultSprite.show()

#########################
###      Private      ###
#########################


func _set_attack_style_splash(splash_map: Dictionary):
	_attack_style = AttackStyle.SPLASH
	_splash_map = splash_map


func _set_attack_style_bounce(bounce_count_max: int, bounce_damage_multiplier: float):
	_attack_style = AttackStyle.BOUNCE
	_bounce_count_max = bounce_count_max
	_bounce_damage_multiplier = bounce_damage_multiplier


# NOTE: if your tower needs to attack more than 1 target,
# call this f-n once in _ready() method of subclass
func _set_target_count(count: int):
	_attack_autocast._target_count_max = count


func _on_attack_autocast(event: Event):
	var target = event.get_target()

	var projectile = _projectile_scene.instance()
	projectile.init(target, global_position)
	projectile.connect("reached_mob", self, "_on_projectile_reached_mob")
	_game_scene.call_deferred("add_child", projectile)

	._do_attack(event)

	_attack_sound.play()


# Override this in subclass to define custom stats for each
# tower tier. Access as _stats.
func _get_tier_stats() -> Dictionary:
	var tier: int = get_tier()
	var default_out: Dictionary = {}

	for i in range(1, tier + 1):
		default_out[i] = {}

	return default_out


func _get_attack_range() -> float:
	var attack_range: float = get_csv_property(CsvProperty.ATTACK_RANGE).to_float()

	return attack_range


func _select():
	._select()

	_range_indicator.show()


func _unselect():
	._unselect()

	_range_indicator.hide()


func _apply_properties_to_scene_children():
	var attack_range: float = _get_attack_range()
	var attack_cooldown: float = get_overall_cooldown()

	_attack_autocast.update_data(attack_range, attack_cooldown)
	_range_indicator.set_radius(attack_range)


# NOTE: returns random damage within range without any mods applied
func _get_rand_damage_base() -> float:
	var damage_min: float = get_damage_min()
	var damage_max: float = get_damage_max()
	var damage: float = rand_range(damage_min, damage_max)

	return damage


func _get_base_properties() -> Dictionary:
	return {}


func _on_modify_property():
	_apply_properties_to_scene_children()


func _get_crit_count() -> int:
	var crit_count: int = 0

	var multicrit_count: int = int(max(0, 1.0 + _mod_value_map[Unit.ModType.MOD_MULTICRIT_COUNT]))

	for _i in range(multicrit_count):
		var attack_crit_chance_mod: float = _mod_value_map[Unit.ModType.MOD_ATTACK_CRIT_CHANCE]
		var is_critical: bool = Utils.rand_chance(attack_crit_chance_mod)

		if is_critical:
			crit_count += 1
		else:
			break

	return crit_count


func _get_damage_mod_for_mob_type(mob: Mob) -> float:
	var mob_type: int = mob.get_type()
	var mod_type: int = _mob_type_to_mod_map[mob_type]
	var damage_mod: float = _mod_value_map[mod_type]

	return damage_mod


func _get_damage_mod_for_mob_size(mob: Mob) -> float:
	var mob_size: int = mob.get_size()
	var mod_type: int = _mob_type_to_mod_map[mob_size]
	var damage_mod: float = _mod_value_map[mod_type]

	return damage_mod


func _get_damage_to_mob(mob: Mob, damage_base: float) -> float:
	var damage: float = damage_base
	
	var damage_mod_list: Array = [
		_get_damage_mod_for_mob_size(mob),
		_get_damage_mod_for_mob_type(mob),
	]

# 	NOTE: crit count can go above 1 because of the multicrit
# 	property
	var crit_count: int = _get_crit_count()
#	NOTE: crits start at 200% damage without any modifiers
	var crit_mod: float = 2.0 + _mod_value_map[Unit.ModType.MOD_ATTACK_CRIT_DAMAGE]

	for _i in range(crit_count):
		damage_mod_list.append(crit_mod)

#	NOTE: clamp at 0.0 to prevent damage from turning
#	negative
	for damage_mod in damage_mod_list:
		damage *= max(0.0, (1.0 + damage_mod))

	return damage


#########################
###     Callbacks     ###
#########################


func _on_projectile_reached_mob(mob: Mob):
	match _attack_style:
		AttackStyle.NORMAL:
			_on_projectile_reached_mob_normal(mob)
		AttackStyle.SPLASH:
			_on_projectile_reached_mob_splash(mob)
		AttackStyle.BOUNCE:
			_on_projectile_reached_mob_bounce(mob)


func _on_projectile_reached_mob_normal(mob: Mob):
	var damage_base: float = _get_rand_damage_base()
	var damage: float = _get_damage_to_mob(mob, damage_base)
	
	._do_damage(mob, damage, true)


func _on_projectile_reached_mob_splash(mob: Mob):
	if _splash_map.empty():
		return

	var damage_base: float = _get_rand_damage_base()
	var damage: float = _get_damage_to_mob(mob, damage_base)
	var splash_target: Unit = mob
	var splash_pos: Vector2 = splash_target.position

#	Process splash ranges from closest to furthers,
#	so that strongest damage is applied
	var splash_range_list: Array = _splash_map.keys()
	splash_range_list.sort()

	var splash_range_max: float = splash_range_list.back()

	var mob_list: Array = Utils.get_mob_list_in_range(splash_pos, splash_range_max)

	for mob in mob_list:
		if mob == splash_target:
			continue
		
		var distance: float = splash_pos.distance_to(mob.position)

		for splash_range in splash_range_list:
			var mob_is_in_range: bool = distance < splash_range

			if mob_is_in_range:
				var splash_damage_ratio: float = _splash_map[splash_range]
				var splash_damage: float = damage * splash_damage_ratio
				_do_damage(mob, splash_damage, true)

				break



func _on_projectile_reached_mob_bounce(mob: Mob):
	var damage_base: float = _get_rand_damage_base()
	var damage: float = _get_damage_to_mob(mob, damage_base)
	
	_on_projectile_bounce_in_progress(mob, damage, _bounce_count_max)


func _on_projectile_bounce_in_progress(prev_mob: Mob, prev_damage: float, current_bounce_count: int):
	._do_damage(prev_mob, prev_damage, true)

# 	Launch projectile for next bounce, if bounce isn't over
	var bounce_end: bool = current_bounce_count == 0

	if bounce_end:
		return

	var next_damage: float = prev_damage * (1.0 - _bounce_damage_multiplier)
	var next_bounce_count: int = current_bounce_count - 1

	var next_target: Mob = _get_next_bounce_target(prev_mob)

	if next_target == null:
		return

	var projectile = _projectile_scene.instance()
	projectile.init(next_target, prev_mob.position)
	projectile.connect("reached_mob", self, "_on_projectile_bounce_in_progress", [next_damage, next_bounce_count])
	_game_scene.call_deferred("add_child", projectile)


func _get_next_bounce_target(prev_target: Mob) -> Mob:
	var attack_range: float = _get_attack_range()
	var mob_list: Array = Utils.get_mob_list_in_range(prev_target.position, attack_range)
	mob_list.erase(prev_target)

	Utils.sort_unit_list_by_distance(mob_list, prev_target.position)

	if !mob_list.empty():
		var next_target = mob_list[0]

		return next_target
	else:
		return null


#########################
### Setters / Getters ###
#########################

func get_name() -> String:
	return get_csv_property(CsvProperty.NAME)


# NOTE: this must be called once after the tower is created
# but before it's added to game scene
func set_id(id: int):
	_id = id


func get_id() -> int:
	return _id


func get_tier() -> int:
	return get_csv_property(CsvProperty.TIER).to_int()


func get_element() -> int:
	var element_string: String = get_csv_property(CsvProperty.ELEMENT)
	var element: int = Element.get(element_string.to_upper())

	return element

func get_icon_atlas_num() -> int:
	var icon_atlas_num_string: String = get_csv_property(CsvProperty.ICON_ATLAS_NUM)

	if !icon_atlas_num_string.empty():
		var icon_atlas_num: int = icon_atlas_num_string.to_int()

		return icon_atlas_num
	else:
		return -1


func get_base_attack_speed() -> float:
	return _mod_value_map[Unit.ModType.MOD_ATTACK_SPEED]


func get_base_cooldown() -> float:
	return get_csv_property(CsvProperty.ATTACK_CD).to_float()


func get_overall_cooldown() -> float:
	var attack_cooldown: float = get_base_cooldown()
	var attack_speed_mod: float = get_base_attack_speed()
	var overall_cooldown: float = attack_cooldown * (1.0 + attack_speed_mod)
	overall_cooldown = max(ATTACK_CD_MIN, overall_cooldown)

	return overall_cooldown


# TODO: implement
func get_exp() -> float:
	return 0.0


# TODO: implement
func remove_exp_flat(_amount: float):
	pass


# TODO: i think this is supposed to return the player that
# owns the tower? Implement later. For now implementing
# owner's function in tower itself and returning tower from
# get_owner()
func get_owner():
	return self


func get_csv_property(csv_property: int) -> String:
	var properties: Dictionary = Properties.get_tower_csv_properties_by_id(_id)
	var value: String = properties[csv_property]

	return value

func get_damage_min():
	return get_csv_property(CsvProperty.ATTACK_DAMAGE_MIN).to_int()


func get_damage_max():
	return get_csv_property(CsvProperty.ATTACK_DAMAGE_MAX).to_int()
