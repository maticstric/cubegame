extends AnimationPlayer

@onready var player = get_parent()

var grounded = true
var idle = true


func _ready():
	player.jumped.connect(_on_jumped)
	player.landed.connect(_on_landed)


func handle_animation():
	if player.velocity.length() == 0:
		if current_animation == "LAND" or current_animation == "ATTACK":
			queue("IDLE")
		else:
			play("IDLE")
	elif player.velocity.x != 0:
		if current_animation == "LAND" or current_animation == "ATTACK":
			queue("WALK")
		elif current_animation == "IDLE":
			play("WALK")
	elif player.velocity.y > 0:
		if current_animation == "LAND" or current_animation == "ATTACK":
			queue("FALL")
		else:
			play("FALL")


func _on_jumped():
	if current_animation != "ATTACK":
		play("LEAP")
	
	queue("RISE")

func _on_landed():
	if current_animation != "ATTACK":
		play("LAND")
