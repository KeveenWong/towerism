extends Node2D

var money = 0
var score
# var screen_size
@export var slime_scene: PackedScene

const CASTLE_LOCATION_X = 1200
const CASTLE_LOCATION_Y = 120
const SCREEN_WIDTH = 1280  # Adjust based on your game's resolution
const SCREEN_HEIGHT = 720
const SPAWN_LEFT = CASTLE_LOCATION_X - (SCREEN_WIDTH / 3)
const SPAWN_RIGHT = CASTLE_LOCATION_X + (SCREEN_WIDTH / 3)
const SPAWN_Y = 0  # Adjust based on where you want enemies to spawn vertically

# Move some of this to a new_game() function later
func _ready():
	# screen_size = get_viewport_rect().size
	score = 0
	#$ScoreTimer.start()
	$EnemyTimer.start()
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_enemy_killed():
	pass
	#money += 10
	#money_label.text = "Money: $" + str(money)
	#print("Enemy killed! Money: $", money)  # Debugging Line
	
func _on_score_timer_timeout() -> void:
	score += 1
	# $HUD.update_score(score)


func _on_enemy_timer_timeout() -> void:
	var enemy = slime_scene.instantiate()
	
	enemy.castle_node = $Castle
	
	# Randomly choose left or right side
	var spawn_left = randf() < 0.5
	var spawn_x = SPAWN_LEFT if spawn_left else SPAWN_RIGHT
	
	enemy.position = Vector2(spawn_x, SPAWN_Y)
	enemy.initial_x_direction = 1 if spawn_left else -1
	
	# Connect the enemy_killed signal
	enemy.connect("enemy_killed", _on_enemy_killed)
	add_child(enemy)
