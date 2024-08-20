extends Node2D
class_name Weapon

@export var Bullet: PackedScene
@export var auto_fire_rate: float = 2
@export var player_fire_rate: float = 0.5
@export var bullet_speed: float = 1000.0
@export var barrel_length: float = 50.0
@export var bullet_damage: float = 5.0
@export var detection_radius: float = 300.0

var can_fire = true
var timer: Timer
var side: String = "right"
var is_auto = false
var is_player_controlled = false
var target: Node2D = null

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_timeout_complete)

	if side == "left":
		scale.y = -1

func _process(delta):
	if is_auto and not is_player_controlled:
		auto_target()
		if can_fire and target:
			shoot()
	elif is_player_controlled:
		player_target()
		if can_fire and Input.is_action_pressed("fire"):
			shoot()

func auto_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy = null
	var closest_distance = detection_radius

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_enemy = enemy
			closest_distance = distance

	target = closest_enemy
	if target:
		look_at(target.global_position)

func player_target():
	var mouse_pos = get_global_mouse_position()
	var angle_to_mouse = global_position.angle_to_point(mouse_pos)

	if side == "left":
		angle_to_mouse = fmod(angle_to_mouse + 2*PI, 2*PI)
		angle_to_mouse = clamp(angle_to_mouse, PI/2, 3*PI/2)
	else:  # right side
		angle_to_mouse = clamp(angle_to_mouse, -PI/2, PI/2)

	global_rotation = angle_to_mouse

func shoot():
	if can_fire:
		can_fire = false
		timer.start(auto_fire_rate if is_auto and not is_player_controlled else player_fire_rate)
		
		var bullet = Bullet.instantiate()
		bullet.damage = bullet_damage
		var spawn_point = global_position + Vector2(barrel_length, 0).rotated(global_rotation)
		bullet.global_position = spawn_point
		bullet.global_rotation = global_rotation
		bullet.set_direction(Vector2.RIGHT.rotated(global_rotation))
		bullet.speed = bullet_speed
		get_tree().root.add_child(bullet)
		$Shoot.play()

func on_timeout_complete():
	can_fire = true

func set_auto(value: bool):
	is_auto = value
	if is_auto:
		print("Weapon set to auto mode")
	else:
		print("Weapon auto mode disabled")

func set_player_control(value: bool):
	is_player_controlled = value
	if is_player_controlled:
		print("Player now controlling weapon")
	else:
		print("Player released weapon control")
