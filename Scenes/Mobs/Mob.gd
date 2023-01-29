class_name Mob
extends Unit


signal moved(delta)
signal dead


export var health_max: int = 100
export var health: int = 100
export var default_mob_move_speed: int = 500
var mob_move_speed: int


var path_curve: Curve2D
var current_path_index: int = 0


onready var _sprite = $Sprite


func _ready():
	mob_move_speed = default_mob_move_speed


func _process(delta):
	var path_point: Vector2 = path_curve.get_point_position(current_path_index)
	var move_speed: float = max(0, mob_move_speed)
	position = position.move_toward(path_point, move_speed * delta)
	emit_signal("moved", delta)
	
	var reached_path_point: bool = (position == path_point)
	
	if reached_path_point:
		current_path_index += 1

		#		Delete mob once it has reached the end of the path
		var reached_end_of_path: bool = (current_path_index >= path_curve.get_point_count())

		if reached_end_of_path:
			die()
			return
		
		var mob_animation: String = _get_mob_animation()
		_sprite.play(mob_animation)


func set_path(path: Path2D):
	path_curve = path.curve
	position = path_curve.get_point_position(0)


func _get_mob_animation() -> String:
	var path_point: Vector2 = path_curve.get_point_position(current_path_index)
	var move_direction: Vector2 = path_point - position
	var move_angle: float = rad2deg(move_direction.angle())

#	NOTE: the actual angles for 4-directional isometric movement are around
#   +- 27 degrees from x axis but checking for which quadrant the movement vector
#	falls into works just as well
	if 0 < move_angle && move_angle < 90:
		return "run_e"
	elif 90 < move_angle && move_angle < 180:
		return "run_s"
	elif -180 < move_angle && move_angle < -90:
		return "run_w"
	elif -90 < move_angle && move_angle < 0:
		return "run_n"
	else:
		return "stand"

func die():
	emit_signal("dead")
	queue_free()


func apply_damage(damage: float):
	health -= damage

	$HealthBar.set_as_ratio(float(health) / float(health_max))

	if health < 0:
		die()


func _modify_property(modification_type: int, value: float):
	match modification_type:
		Modification.Type.MOD_MOVE_SPEED:
			# var modification_value: float = modification.value_base * value_modifier
			mob_move_speed = mob_move_speed + value
