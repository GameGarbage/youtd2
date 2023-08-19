extends Tower


# NOTE: removed the "Rocket deals 125% damage to mass
# creeps." ability. Because:
# 
# 1. Requires a special feature called DamageTable, which is
#    used only by this tower.
# 
# 2. The damage table in original script actually sets
#    damage mod to 0.95, not 1.5 like in description. Maybe
#    a typo in original script.


var cedi_sniper_rocket: ProjectileType


# NOTE: this value is multiplied by 100
func get_tier_stats() -> Dictionary:
	return {
		1: {rocket_damage = 4, rocket_damage_add = 0.1},
		2: {rocket_damage = 12, rocket_damage_add = 0.3},
		3: {rocket_damage = 24, rocket_damage_add = 0.6},
		4: {rocket_damage = 40, rocket_damage_add = 1.0},
	}


func get_extra_tooltip_text() -> String:
	var rocket_damage: String = str(_stats.rocket_damage * 100)
	var rocket_damage_add: String = str(_stats.rocket_damage_add * 100)
	var text: String = ""

	text += "[color=GOLD]Rocket Strike[/color]\n"
	text += "30%% chance to fire a rocket towards the attacked unit. On impact it deals %s damage in a 150 AoE.\n" % rocket_damage
	text += " \n"
	text += "[color=ORANGE]Level Bonus:[/color]\n"
	text += "+0.6%% chance\n"
	text += "+%s damage\n" % rocket_damage_add

	return text


func load_triggers(triggers: BuffType):
	triggers.add_event_on_attack(on_attack)


func load_specials(modifier: Modifier):
	modifier.add_modification(Modification.Type.MOD_DMG_TO_MASS, -0.70, 0.0)
	modifier.add_modification(Modification.Type.MOD_DMG_TO_NORMAL, -0.30, 0.0)
	modifier.add_modification(Modification.Type.MOD_DMG_TO_CHAMPION, 0.20, 0.016)
	modifier.add_modification(Modification.Type.MOD_DMG_TO_BOSS, 0.50, 0.04)
	modifier.add_modification(Modification.Type.MOD_DMG_TO_AIR, 0.20, 0.016)


func rocket_hit(p: Projectile, _t: Unit):
	p.do_spell_damage_pb_aoe(p.user_real, 100, 0)
	var effect: int = Effect.add_special_effect("NeutralBuildingExplosion.mdl", p.x, p.y)
	Effect.destroy_effect(effect)


func tower_init():
	cedi_sniper_rocket = ProjectileType.create_interpolate("RocketMissile.mdl", 750)
	cedi_sniper_rocket.set_event_on_interpolation_finished(rocket_hit)


func on_attack(event: Event):
	var tower: Tower = self

	if !tower.calc_chance(0.30 + 0.006 * tower.get_level()):
		return

	var projectile: Projectile = Projectile.create_linear_interpolation_from_unit_to_unit(cedi_sniper_rocket, tower, _stats.rocket_damage + tower.get_level() * _stats.rocket_damage_add, tower.calc_spell_crit_no_bonus(), tower, event.get_target(), 0.25, true)
	projectile.user_real = 150 