extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration = 1500.0
@export var friction = 1000.0

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#func _ready():
	#setup_animations()

func _physics_process(delta):
	var input_dir = Input.get_axis("left", "right")

	apply_gravity(delta)
	handle_jump()
	handle_movement(delta, input_dir)
	move_and_slide()
	update_animations(input_dir)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func handle_movement(delta, input_dir):
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
	if input_dir != 0:
		sprite.flip_h = (input_dir == -1)
		
func update_animations(input_dir):
	if is_on_floor():
		if input_dir == 0:
			ap.play('idle')
		else:
			ap.play("run")
	else:
		if velocity.y < 0:
			ap.play("jump")
		elif velocity.y > 0: 
			ap.play("fall")