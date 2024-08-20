extends Node2D

@export var Bullet: PackedScene
@export var fire_rate: float = 0.2
@export var bullet_speed: float = 1000.0
@export var barrel_length: float = 50.0
@export var bullet_damage: float = 5.0

var can_fire = true
var timer: Timer
var side: String = "right"  # Default to right side

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = fire_rate
	timer.timeout.connect(on_timeout_complete)
	add_child(timer)

	if side == "left":
		scale.y = -1
		
	# Check if "fire" action exists
	if not InputMap.has_action("fire"):
		print("Warning: 'fire' action is not defined in the InputMap")

func _process(delta):
	pass
	#var mouse_pos = get_global_mouse_position()
	#var angle_to_mouse = global_position.angle_to_point(mouse_pos)
#
	## Limit the rotation based on the side
	#if side == "left":
		#angle_to_mouse = fmod(angle_to_mouse + 2*PI, 2*PI)
		#angle_to_mouse = clamp(angle_to_mouse, PI/2, 3*PI/2)
	#else:  # right side
		#angle_to_mouse = clamp(angle_to_mouse, -PI/2, PI/2)
	#
	## Set the rotation
	#global_rotation = angle_to_mouse
	#
	#if Input.is_action_pressed("fire") and can_fire:
		#shoot()

func shoot():
	if can_fire:
		can_fire = false
		timer.start()
		
		var bullet = Bullet.instantiate()
		bullet.damage = bullet_damage
		var spawn_point = global_position + Vector2(barrel_length, 0).rotated(global_rotation)
		bullet.global_position = spawn_point
		bullet.global_rotation = global_rotation
		bullet.set_direction(Vector2.RIGHT.rotated(global_rotation))
		bullet.speed = bullet_speed
		get_tree().root.add_child(bullet)

func on_timeout_complete():
	can_fire = true
