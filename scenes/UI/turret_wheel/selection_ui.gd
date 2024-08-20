extends CanvasLayer

@onready var selection_wheel = $SelectionWheel
var placement_side: String = "left"  # Default to left side
var is_visible = false

func _ready():
	selection_wheel.hide()
	is_visible = false

func _process(delta):
	if Input.is_action_just_pressed("click") and is_visible:
		var tool = selection_wheel.Close()
		$Label.text = "Player Bought Turret: " + tool
		get_parent().get_parent().place_turret(tool, placement_side)
		is_visible = false

func show_wheel():
	is_visible = true
	selection_wheel.show()
	
func hide_wheel():
	is_visible = false
	selection_wheel.hide()
	
func set_placement_side(side: String):
	print("placement side is", side)
	placement_side = side
