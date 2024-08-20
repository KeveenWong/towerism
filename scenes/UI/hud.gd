extends CanvasLayer

@onready var health_label = $ScalesLabel
@onready var money_label = $MoneyLabel
@onready var timer_label = $TimerLabel
@onready var pause_button = $PauseButton
@onready var pause_label = $PauseLabel

func _ready():
	pause_label.visible = false

func _process(delta):
	pass

func update_scales(value):
	health_label.text = str(value)

func update_money(value):
	money_label.text = str(value)

func update_score(value):
	timer_label.text = str(value)

func _on_pause_button_pressed():
	toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_label.visible = get_tree().paused
