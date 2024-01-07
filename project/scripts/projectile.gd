extends Area2D

var speed = 50
var velocity = Vector2.ZERO
var gravity_scale = 9.8

var initial_speed # set by player
var deceleration_percentage = 0.01

func _ready():
	velocity.x = initial_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravity_scale * delta
	velocity.x -= velocity.x * deceleration_percentage
	
	set_global_position(global_position + velocity)
