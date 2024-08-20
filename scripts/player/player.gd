extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration = 1500.0
@export var friction = 1000.0
@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var camera = $Camera2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var zoom_speed = 0.05
var min_zoom = 0.3
var max_zoom = 1
var castle: Castle
var near_window = false
var current_window_side = ""
var current_floor = 0
var main_scene

# if player can be controlled or not
var controllable = true

func _ready():
	castle = get_parent().get_node("Castle")
	main_scene = get_tree().get_root().get_node("Castle Game")
	
func _physics_process(delta):
	if not controllable:
		return
	var input_dir = Input.get_axis("left", "right")
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta, input_dir)
	move_and_slide()
	update_animations(input_dir)
	update_selection_wheel_status()
	
func set_controllable(value: bool):
	controllable = value
	if not controllable:
		velocity = Vector2.ZERO
		
func handle_interaction():
	if near_window and main_scene.has_turret_at_window(current_floor, current_window_side):
		main_scene.show_selection_menu(current_window_side)

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		zoom_camera(zoom_speed)
	elif event.is_action_pressed("zoom_out"):
		zoom_camera(-zoom_speed)
	elif event.is_action_pressed("up"):
		if castle and castle.change_floor(castle.current_floor + 1):
			update_player_position()
	elif event.is_action_pressed("down"):
		if castle and castle.change_floor(castle.current_floor - 1):
			update_player_position()
	elif event.is_action_pressed("build_floor"):
		if castle:
			var new_floor = castle.build_new_floor()
	elif event.is_action_pressed("interact") and near_window:
		if main_scene.has_turret_at_window(castle.current_floor, current_window_side):
			main_scene.show_selection_menu(current_window_side)
		else:
			main_scene.show_selection_wheel()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$Jump.play()
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

func zoom_camera(zoom_factor):
	var new_zoom = camera.zoom.x + zoom_factor
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	camera.zoom = Vector2(new_zoom, new_zoom)

func update_player_position():
	if castle and castle.floors.has(castle.current_floor):
		var floor_instance = castle.floors[castle.current_floor].instance
		if floor_instance:
			var spawn_point = floor_instance.get_node("PlayerSpawnPoint")
			if spawn_point:
				global_position = spawn_point.global_position
			else:
				print("Warning: PlayerSpawnPoint not found on floor ", castle.current_floor)
				global_position.y = floor_instance.global_position.y
	else:
		print("Cannot update player position: current floor does not exist")

func enter_placement_area(side: String):
	near_window = true
	current_window_side = side
	current_floor = main_scene.castle.current_floor

func exit_placement_area():
	near_window = false
	current_window_side = ""
	main_scene.hide_selection_menu()


func _on_left_window_entered(body):
	if body == self:
		current_window_side = "left"
		enter_placement_area(current_window_side)

func _on_right_window_entered(body):
	if body == self:
		current_window_side = "right"
		enter_placement_area(current_window_side)

func _on_window_exited(body):
	if body == self:
		exit_placement_area()
		current_window_side = ""
		
func update_selection_wheel_status():
	if near_window == false:
		main_scene.hide_selection_wheel()
		main_scene.hide_selection_menu()

func _on_enemy_timer_timeout() -> void:
	pass # Replace with function body.
