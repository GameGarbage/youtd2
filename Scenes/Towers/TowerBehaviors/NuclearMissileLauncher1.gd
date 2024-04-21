extends TowerBehavior


# NOTE: original script implemented progress bar as text
# with bars like "|||||...". Implemented it as an actual
# ProgressBar instead. Also changed how current cooldown
# ratio is calculated to be more straightforward.


var targeted_pt: BuffType
var _progress_bar: ProgressBar


func load_triggers(triggers: BuffType):
	triggers.add_event_on_attack(on_attack)
	triggers.add_event_on_damage(on_damage)
	triggers.add_periodic_event(periodic, 0.5)


func load_specials(_modifier: Modifier):
	tower.set_attack_ground_only()
	tower.set_attack_style_splash({
		400: 1.00,
		500: 0.75,
		600: 0.50,
		})


func tower_init():
	targeted_pt = BuffType.new("targeted_pt", -1, 0, false, self)
	targeted_pt.set_buff_icon("gear_1.tres")
	targeted_pt.add_event_on_create(targeted_pt_on_create)
	targeted_pt.add_event_on_refresh(targeted_pt_on_refresh)
	targeted_pt.set_buff_tooltip("Targeted\nTargeted by a Nuclear Launcher.")


func on_create(_preceding_tower: Tower):
	_progress_bar = ProgressBar.new()
	_progress_bar.size = Vector2(150, 20)
	_progress_bar.position.y = -Constants.TILE_SIZE_PIXELS / 2
	_progress_bar.position.x = -75
	_progress_bar.show_percentage = false
	_progress_bar.modulate = Color.RED
	tower._visual.add_child(_progress_bar)


func on_attack(event: Event):
	var target: Unit = event.get_target()
	targeted_pt.apply(tower, target, tower.get_level())


func on_damage(event: Event):
	var target: Unit = event.get_target()

	if !event.is_main_target():
		return

	var target_effect: int = Effect.create_animated_scaled("MortarMissile.mdl", Vector3(target.get_x(), target.get_y(), 0), 0, 3.0)
	Effect.set_animation_speed(target_effect, 0.5)
	Effect.set_lifetime(target_effect, 0.05)

	var target_buff: Buff = target.get_buff_of_type(targeted_pt)

# 	NOTE: do not remove buff if user_int is above 0 so that
# 	the multiple launchers work correctly together
	if target_buff != null:
		if target_buff.user_int <= 0:
			target_buff.remove_buff()
		else:
			target_buff.user_int -= 1

	SFX.sfx_on_unit("BottleMissile.mdl", target, Unit.BodyPart.ORIGIN)


func periodic(_event: Event):
	var remaining_cd: float = tower.get_remaining_cooldown()
	var attackspeed: float = tower.get_current_attackspeed()
	var cd_ratio: float = 1.0 - remaining_cd / attackspeed

	_progress_bar.set_as_ratio(cd_ratio)


func targeted_pt_on_create(event: Event):
	var buff: Buff = event.get_buff()
	buff.user_int = 0


func targeted_pt_on_refresh(event: Event):
	var buff: Buff = event.get_buff()
	buff.user_int += 1
