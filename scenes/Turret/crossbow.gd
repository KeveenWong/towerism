extends Weapon
class_name Crossbow

@export var crossbow_damage: int = 1
@export var crossbow_auto_fire_rate: float = 0.5
@export var crossbow_player_fire_rate: float = 0.05

var is_loaded: bool = true

func _ready():
	super._ready()
	bullet_damage = crossbow_damage

func shoot():
	if is_loaded and can_fire:
		super.shoot()
		is_loaded = false
		timer.start(crossbow_auto_fire_rate if is_auto and not is_player_controlled else crossbow_player_fire_rate)

# Override the parent's on_timeout_complete to handle both fire rate and reload
func on_timeout_complete():
	super.on_timeout_complete()
	is_loaded = true
	print("Crossbow reloaded!")  # Debug print

# Override or add any crossbow-specific methods here
