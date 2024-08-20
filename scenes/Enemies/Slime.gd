extends CharacterBody2D

signal enemy_defeated(gold_value: int)
signal enemy_reached_center(plunder_value: int)


const HORIZONTAL_SPEED = 50  # pixels per second
const VERTICAL_SPEED = 50  # pixels per second
const REACH_THRESHOLD = 10  # pixels
const MAX_HEALTH = 10
const GOLD_VALUE = 5
const PLUNDER_VALUE = 2

enum State { MOVING_HORIZONTAL, MOVING_UP, MOVING_TO_CENTER }

var current_state = State.MOVING_HORIZONTAL
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var initial_x_direction # 1 for right, -1 for left

@export var castle_node: Node2D
@onready var sprite = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent

func _ready():
	add_to_group("enemies")
	health_component.max_health = MAX_HEALTH
	health_component.health_depleted.connect(_on_health_depleted)
	
	# Customize VelocityComponent for this enemy type
	velocity_component.set_speeds(HORIZONTAL_SPEED, VERTICAL_SPEED)

func _physics_process(delta):
	if not castle_node:
		print("Error: Castle node not set!")
		return
	
	match current_state:
		State.MOVING_HORIZONTAL:
			if initial_x_direction == -1:
				sprite.flip_h = true
			velocity_component.apply_gravity(delta)
			velocity_component.move_horizontal(initial_x_direction)
			velocity_component.apply_velocity()
			
			if is_on_wall():
				current_state = State.MOVING_UP
				sprite.flip_v = true
				velocity_component.stop_horizontal()
				velocity_component.move_vertical(-1)  # Moving up
				
		State.MOVING_UP:
			velocity_component.apply_velocity()
			
			if position.y <= castle_node.get_castle_top_floor_position() - 10: # For smoother transitions
				current_state = State.MOVING_TO_CENTER
				z_index = 1  # Make sure the enemy appears in front of the tower
		
		State.MOVING_TO_CENTER:
			sprite.flip_v = false
			velocity_component.apply_gravity(delta)
			var castle_center_x = castle_node.get_castle_center_x()
			var direction_x = sign(castle_center_x - position.x)
			velocity_component.move_horizontal(direction_x)
			velocity_component.stop_vertical()
			velocity_component.apply_velocity()
			
			# Check if enemy is close enough to the center x
			if abs(position.x - castle_center_x) < REACH_THRESHOLD:
				emit_signal("enemy_reached_center", PLUNDER_VALUE)
				queue_free()

func hit(damage):
	health_component.take_damage(damage)

func get_health():
	return health_component.get_health()
	
func get_speeds():
	return [HORIZONTAL_SPEED, VERTICAL_SPEED]

func _on_health_depleted():
	emit_signal("enemy_defeated", GOLD_VALUE)
	queue_free()
