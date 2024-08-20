extends Node2D

var debug_rects = []

func _ready():
	var left_window = $LeftWindow
	var right_window = $RightWindow
	
	left_window.body_entered.connect(_on_left_window_entered)
	left_window.body_exited.connect(_on_window_exited)
	right_window.body_entered.connect(_on_right_window_entered)
	right_window.body_exited.connect(_on_window_exited)
	
	# Create debug rectangles
	create_debug_rect(left_window, Color.RED)
	create_debug_rect(right_window, Color.BLUE)

func create_debug_rect(window: Area2D, color: Color):
	var rect = ColorRect.new()
	rect.size = Vector2(20, 20)  # Size of the debug rectangle
	rect.color = color
	rect.global_position = window.global_position - rect.size / 2
	add_child(rect)
	debug_rects.append(rect)

func _on_left_window_entered(body):
	if body.is_in_group("player"):
		body.enter_placement_area()
		get_node("/root/Castle Game/Ui/CanvasLayer").set_placement_side("left")
		debug_rects[0].color.a = 0.7  # Increase opacity when player enters

func _on_right_window_entered(body):
	if body.is_in_group("player"):
		body.enter_placement_area()
		get_node("/root/Castle Game/Ui/CanvasLayer").set_placement_side("right")
		debug_rects[1].color.a = 0.7  # Increase opacity when player enters

func _on_window_exited(body):
	if body.is_in_group("player"):
		body.exit_placement_area()
		debug_rects[0].color.a = 0.3  # Decrease opacity when player exits
		debug_rects[1].color.a = 0.3  # Decrease opacity when player exits

# Toggle debug visuals
func toggle_debug_visuals():
	for rect in debug_rects:
		rect.visible = !rect.visible
