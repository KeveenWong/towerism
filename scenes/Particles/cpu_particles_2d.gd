extends CPUParticles2D

@onready var timer = $Timer

func _ready():
	emitting = false
	if timer:
		timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	else:
		print("Timer node not found!")

func start_effect():
	emitting = true
	if timer:
		timer.start()
		print("time started")
	else:
		print("Timer not found, effect may not stop automatically")

func _on_timer_timeout():
	emitting = false
