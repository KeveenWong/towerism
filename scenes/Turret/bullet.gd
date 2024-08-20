extends Area2D

@export var speed = 750.0
var damage: float

var direction: Vector2

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.hit(damage)
		
		queue_free()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
