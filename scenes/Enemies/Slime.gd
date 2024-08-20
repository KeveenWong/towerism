extends CharacterBody2D

signal enemy_killed
signal reached_center

enum State { MOVING_HORIZONTAL, MOVING_UP, MOVING_TO_CENTER }
var current_state = State.MOVING_HORIZONTAL

const HORIZONTAL_SPEED = 50  # pixels per second
const VERTICAL_SPEED = 50  # pixels per second
const CENTER_X = 1200 # Adjust based on your game's resolution

@export var castle_node: Node2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 10  # Starting health for the enemy
var initial_x_direction # 1 for right, -1 for left

func _ready():
	add_to_group("enemies")

func apply_gravity(delta):
	if not is_on_floor() and current_state != State.MOVING_TO_CENTER:
		velocity.y += gravity * delta

func _physics_process(delta):
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
				velocity.x = HORIZONTAL_SPEED * initial_x_direction
				velocity.y = 0
				current_state = State.MOVING_TO_CENTER
				z_index = 1  # Make sure the enemy appears in front of the tower
		
		State.MOVING_TO_CENTER:
			apply_gravity(delta)
			move_and_slide()
			if abs(position.x - CENTER_X) < 5:
				emit_signal("reached_center")
				queue_free()
				# Enemy reached the center, implement game over or damage logic here

func hit(damage):
	health -= damage
	if health <= 0:
		emit_signal("enemy_killed")
		queue_free()
		
func get_health():
	return health
