extends CharacterBody2D

signal enemy_killed
signal reached_center

enum State { MOVING_HORIZONTAL, MOVING_UP, MOVING_TO_CENTER }
var current_state = State.MOVING_HORIZONTAL

const HORIZONTAL_SPEED = 50  # pixels per second
const VERTICAL_SPEED = 50  # pixels per second
const REACH_THRESHOLD = 10  # pixels

@export var castle_node: Castle

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 10  # Starting health for the enemy
var initial_x_direction # 1 for right, -1 for left

func _ready():
	add_to_group("enemies")

func apply_gravity(delta):
	if not is_on_floor() and current_state != State.MOVING_TO_CENTER:
		velocity.y += gravity * delta

func _physics_process(delta):
	if not castle_node:
		print("Error: Castle node not set!")
		return

	match current_state:
		State.MOVING_HORIZONTAL:
			apply_gravity(delta)
			velocity.x = HORIZONTAL_SPEED * initial_x_direction
			move_and_slide()
			
			if is_on_wall():
				current_state = State.MOVING_UP
				velocity.x = 0
				velocity.y = -VERTICAL_SPEED
				
		State.MOVING_UP:
			move_and_slide()
			
			if position.y <= castle_node.get_castle_top_floor_position():
				current_state = State.MOVING_TO_CENTER
				z_index = 1  # Make sure the enemy appears in front of the tower
		
		State.MOVING_TO_CENTER:
			apply_gravity(delta)
			var castle_center_x = castle_node.get_castle_center_x()
			var direction_x = sign(castle_center_x - global_position.x)
			velocity.x = direction_x * HORIZONTAL_SPEED
			velocity.y = 0  # Remove vertical movement
			move_and_slide()
			
			# Check if enemy is close enough to the center x
			if abs(global_position.x - castle_center_x) < REACH_THRESHOLD:
				print("Enemy reached center at x position: ", global_position.x)  # Debug print
				emit_signal("reached_center")
				queue_free()

func hit(damage):
	health -= damage
	if health <= 0:
		emit_signal("enemy_killed")
		queue_free()
		
func get_health():
	return health
