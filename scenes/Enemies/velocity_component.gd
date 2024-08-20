extends Node

class_name VelocityComponent

@export var speed_horizontal: float
@export var speed_vertical: float
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var apply_gravity_flag: bool = true  # Default to true, but set to false for bats


var velocity: Vector2 = Vector2.ZERO
var parent: CharacterBody2D

func _ready():
	parent = get_parent() as CharacterBody2D
	if not parent:
		push_error("VelocityComponent must be a child of a CharacterBody2D")

func apply_gravity(delta: float):
	if apply_gravity_flag:
		velocity.y += gravity * delta

func move_horizontal(direction: float):
	velocity.x = direction * speed_horizontal

func move_vertical(direction: float):
	velocity.y = direction * speed_vertical

func stop_horizontal():
	velocity.x = 0

func stop_vertical():
	velocity.y = 0

func apply_velocity():
	if parent:
		parent.velocity = velocity
		parent.move_and_slide()
		velocity = parent.velocity  # Update velocity after collision

func set_speeds(horizontal: float, vertical: float):
	speed_horizontal = horizontal
	speed_vertical = vertical
