extends ItemBehavior


var chain_lightning_st: SpellType
var stun_bt: BuffType


func get_ability_description() -> String:
	var text: String = ""

	text += "[color=GOLD]Purify[/color]\n"
	text += "Grants the carrier a 12.5% attackspeed adjusted chance on attack to cast a purifying beam of magic. Deals 250 spelldamage on the first target and bounces to 2 other targets. Each bounce reduces the damage by 25%. Undead and Orc creeps also get stunned for 0.5 seconds when hit by this beam.\n"

	return text


func load_triggers(triggers: BuffType):
	triggers.add_event_on_attack(on_attack)


# NOTE: drol_chainStun() in original script
func chain_lightning_st_on_damage(event: Event, d: DummyUnit):
	var creep: Unit = event.get_target()

	if creep.get_category() == 0 || creep.get_category() == 3:
		stun_bt.apply_only_timed(d.get_caster(), event.get_target(), 0.5)


func item_init():
	stun_bt = CbStun.new("stun_bt", 0, 0, false, self)
	
	chain_lightning_st = SpellType.new("@@0@@", "chainlightning", 5.0, self)
	chain_lightning_st.set_damage_event(chain_lightning_st_on_damage)
	chain_lightning_st.data.chain_lightning.damage = 250
	chain_lightning_st.data.chain_lightning.damage_reduction = 0.25
	chain_lightning_st.data.chain_lightning.chain_count = 3


func on_attack(event: Event):
	var tower: Tower = item.get_carrier()
	var speed: float = tower.get_base_attackspeed()

	if tower.calc_chance(0.125 * speed):
		CombatLog.log_item_ability(item, event.get_target(), "Purify")
		chain_lightning_st.target_cast_from_caster(tower, event.get_target(), 1, tower.calc_spell_crit_no_bonus())
