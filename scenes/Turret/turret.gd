extends Weapon
class_name Turret

func _ready():
	super._ready()
	# Any turret-specific initialization can go here

func _process(delta):
	super._process(delta)
	# Any turret-specific processing can go here

# Override or add any turret-specific methods here
