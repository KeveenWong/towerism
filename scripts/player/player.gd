extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration = 1500.0
@export var friction = 1000.0

@onready var animated_sprite = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	setup_animations()

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()
	update_animation()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func handle_movement(delta):
	var input_dir = Input.get_axis("left", "right")
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func setup_animations():
	var sprite_frames = SpriteFrames.new()
	animated_sprite.sprite_frames = sprite_frames
	
	# Assuming your sprite sheet is named "character_sheet.png" and is in the same directory as this script
	var texture = load("res://character_sheet.png")
	
	# Define your animation parameters
	var animations = {
		"idle": {"start_frame": 0, "frame_count": 1},
		"run": {"start_frame": 1, "frame_count": 6},
		"jump": {"start_frame": 7, "frame_count": 1}
	}
	
	var frame_width = 64  # Adjust based on your sprite sheet
	var frame_height = 64  # Adjust based on your sprite sheet
	
	for anim_name in animations:
		sprite_frames.add_animation(anim_name)
		var start_frame = animations[anim_name]["start_frame"]
		var frame_count = animations[anim_name]["frame_count"]
		
		for i in range(frame_count):
			var region = Rect2((start_frame + i) * frame_width, 0, frame_width, frame_height)
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = texture
			atlas_texture.region = region
			sprite_frames.add_frame(anim_name, atlas_texture)
	
	# Set animation properties
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 5)
	sprite_frames.set_animation_loop("run", true)
	sprite_frames.set_animation_speed("run", 10)
	sprite_frames.set_animation_loop("jump", false)
	sprite_frames.set_animation_speed("jump", 10)

func update_animation():
	if not is_on_floor():
		animated_sprite.play("jump")
	elif velocity.x != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")
