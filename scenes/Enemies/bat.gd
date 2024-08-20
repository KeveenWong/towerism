extends CharacterBody2D

class_name Bat

signal enemy_defeated(gold_value: int)
signal enemy_reached_center(plunder_value: int)

const SPEED = 30  # Customize the speed for the bat
const MAX_HEALTH = 30
const GOLD_VALUE = 10
const PLUNDER_VALUE = 5
const REACH_THRESHOLD = 15

var target_position: Vector2  # This will be set to the castle center

@export var castle_node: Node2D
@onready var sprite = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent

func _ready():
	add_to_group("enemies")
	health_component.max_health = MAX_HEALTH
	health_component.current_health = MAX_HEALTH
	health_component.health_depleted.connect(_on_health_depleted)
	
	# Set the target to be the center of the castle
	if castle_node:
		target_position = castle_node.get_castle_center_position()
	else:
		print("Error: Castle node not set!")
		queue_free()

func _physics_process(delta):
	if not castle_node:
		return
	
	# Calculate direction to the castle center
	target_position = castle_node.get_castle_center_position()
	var direction = (target_position - global_position).normalized()
	
	# Set the velocity using the direction and speed
	velocity = direction * SPEED
	
	# Move the bat
	move_and_slide()

	# Check if bat reaches the castle center
	if abs(global_position.x - castle_node.get_castle_center_x()) <= REACH_THRESHOLD:
		print("Global position of bat: ", global_position)
		print("Position of bat", position)
		print("Castle node x", castle_node.get_castle_center_x())
		emit_signal("enemy_reached_center", PLUNDER_VALUE)
		queue_free()

func hit(damage):
	health_component.take_damage(damage)

func get_health():
	return health_component.get_health()

func _on_health_depleted():
	emit_signal("enemy_defeated", GOLD_VALUE)
	queue_free()
