extends Building

class_name Tower

# Tower attacks by periodically firing projectiles at mobs
# that are in range.

signal upgraded

export(int) var id
export(int) var next_tier_id

var attack_type: String
var ingame_name: String
var author: String
var rarity: String
var element: String
var damage: Array
var cost: float
var description: String
var target_mob: Mob = null
var aoe_scene: PackedScene = preload("res://Scenes/Towers/AreaOfEffect.tscn")
var projectile_scene: PackedScene = preload("res://Scenes/Projectile.tscn")

onready var game_scene: Node = get_tree().get_root().get_node("GameScene")
onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
onready var targeting_area: Area2D = $TargetingArea


func _ready():
	add_child(aoe_scene.instance(), true)
	
	var properties = TowerManager.tower_props[id]
	attack_type = properties["attack_type"]
	ingame_name = properties["name"]
	author = properties["author"]
	rarity = properties["rarity"]
	element = properties["element"]
	damage = properties["damage"]
	cost = properties["cost"]
	description = properties["description"]

	var cast_range: float = 3000
	Utils.circle_shape_set_radius($TargetingArea/CollisionShape2D, cast_range)
	$AreaOfEffect.set_radius(cast_range)
	$AreaOfEffect.hide()

	attack_cooldown_timer.connect("timeout", self, "_on_AttackCooldownTimer_timeout")
	attack_cooldown_timer.one_shot = true

	targeting_area.connect("body_entered", self, "_on_TargetingArea_body_entered")
	targeting_area.connect("body_exited", self, "_on_TargetingArea_body_exited")


func _on_AttackCooldownTimer_timeout():
	if !have_target():
		target_mob = find_new_target()
		
	try_to_attack()


func _on_TargetingArea_body_entered(body):
	if have_target():
		return
		
	if body is Mob:
#		New target acquired
		target_mob = body
		try_to_attack()


func _on_TargetingArea_body_exited(body):
	if body == target_mob:
#		Target has gone out of range
		target_mob = find_new_target()
		try_to_attack()


# Find a target that is currently in range
# TODO: prioritizing closest mob here, but maybe change behavior
# based on tower properties or other game design considerations
func find_new_target() -> Mob:
	var body_list: Array = targeting_area.get_overlapping_bodies()
	var closest_mob: Mob = null
	var distance_min: float = 1000000.0
	
	for body in body_list:
		if body is Mob:
			var mob: Mob = body
			var distance: float = (mob.position - self.position).length()
			
			if distance < distance_min:
				closest_mob = mob
				distance_min = distance
	
	return closest_mob


func try_to_attack():
	if building_in_progress:
		return

	if !have_target():
		return
	
	var attack_on_cooldown: bool = attack_cooldown_timer.time_left > 0
	
	if attack_on_cooldown:
		return
	
	var projectile = projectile_scene.instance()
	projectile.init(target_mob, global_position, damage)
	game_scene.add_child(projectile)

	attack_cooldown_timer.start()


func have_target() -> bool:
#	NOTE: have to check validity because mobs can get killed by other towers
#	which free's them and makes them invalid
	return target_mob != null and is_instance_valid(target_mob)


func build_init():
	.build_init()
	$AreaOfEffect.show()


func _select():
	._select()
	print_debug("Tower %s has been selected." % id)


func _unselect():
	._unselect()
	print_debug("Tower %s has been unselected." % id)


func upgrade() -> PackedScene:
	var next_tier_tower = TowerManager.get_tower(next_tier_id)
	emit_signal("upgraded")
	return next_tier_tower
