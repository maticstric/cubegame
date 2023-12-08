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
		if player.velocity.x < 0:
			horizontal_flip(-1)
		elif player.velocity.x > 0:
			horizontal_flip(1)

		if player.velocity.y > 0:
			play("FALL")
		elif player.velocity.x != 0:
			queue("WALK")


func horizontal_flip(horizontal_direction):
	var polygons = $"../Polygons"
	var skeleton2d = $"../Skeleton2D"

	polygons.scale.x = abs(polygons.scale.x) * horizontal_direction
	skeleton2d.scale.x = abs(skeleton2d.scale.x) * horizontal_direction


func _on_jumped():
	play("LEAP")
	queue("RISE")
