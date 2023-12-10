extends AnimationPlayer

@onready var player = get_parent()

var grounded = true
var idle = true

func _ready():
	player.jumped.connect(_on_jumped)


func handle_animation():

	if player.is_on_floor():
		if not grounded:
			play("LAND")
			
		grounded = true
	else:
		grounded = false

	if player.velocity.length() == 0:
		queue("IDLE")
	else:
		if player.velocity.y > 0:
			play("FALL")
		elif player.velocity.x != 0:
			queue("WALK")


func _on_jumped():
	play("LEAP")
	queue("RISE")
