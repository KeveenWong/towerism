extends Node2D

@export var highlight_color = Color(0.0, 1.0, 0.0, 0.3)  # Semi-transparent green
@export var normal_color = Color(1.0, 1.0, 1.0, 0.0)  # Fully transparent white

func _ready():
	var left_window = $LeftWindow
	var right_window = $RightWindow
	
	var player = get_tree().get_nodes_in_group("player")[0]

	left_window.body_entered.connect(player._on_left_window_entered)
	left_window.body_exited.connect(player._on_window_exited)
	right_window.body_entered.connect(player._on_right_window_entered)
	right_window.body_exited.connect(player._on_window_exited)
	
	left_window.body_entered.connect(_on_left_window_entered)
	left_window.body_exited.connect(_on_window_exited)
	right_window.body_entered.connect(_on_right_window_entered)
	right_window.body_exited.connect(_on_window_exited)
	
	# Add ColorRect for visual highlighting
	_add_highlight_rect(left_window, "LeftHighlight")
	_add_highlight_rect(right_window, "RightHighlight")

func _add_highlight_rect(window: Area2D, name: String):
	var highlight = ColorRect.new()
	highlight.name = name
	highlight.size = window.get_node("CollisionShape2D").shape.size
	highlight.position = -highlight.size / 2  # Center the rect on the Area2D
	highlight.color = normal_color
	window.add_child(highlight)

func _on_left_window_entered(body):
	if body.is_in_group("player"):
		body.enter_placement_area("left")
		get_node("/root/Castle Game/Ui/CanvasLayer").set_placement_side("left")
		_highlight_window($LeftWindow/LeftHighlight)

func _on_right_window_entered(body):
	if body.is_in_group("player"):
		body.enter_placement_area("right")
		get_node("/root/Castle Game/Ui/CanvasLayer").set_placement_side("right")
		_highlight_window($RightWindow/RightHighlight)

func _on_window_exited(body):
	if body.is_in_group("player"):
		body.exit_placement_area()
		_unhighlight_windows()

func _highlight_window(highlight: ColorRect):
	highlight.color = highlight_color

func _unhighlight_windows():
	$LeftWindow/LeftHighlight.color = normal_color
	$RightWindow/RightHighlight.color = normal_color
