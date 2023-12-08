extends CharacterBody2D

@export var move_speed : float
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

@onready var jump_velocity = -(2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity = -(-2.0 * jump_height) / jump_time_to_peak ** 2
@onready var fall_gravity = -(-2.0 * jump_height) / jump_time_to_descent ** 2


var authority

signal jumped

func _physics_process(delta):

	if authority:
		$AnimationPlayer.handle_animation()
		
		velocity.x = get_input_velocity() * move_speed
		velocity.y += get_gravity() * delta
		
		if Input.is_action_pressed("jump") and is_on_floor():
			jump()

		move_and_slide()
		
		var player_state = make_player_state()
		
		MultiplayerController.receive_player_state.rpc(player_state)
	else:
		var new_pos_x = MultiplayerController.players[self.name.to_int()]["pos_x"]
		var new_pos_y = MultiplayerController.players[self.name.to_int()]["pos_y"]
		var new_pos = Vector2(new_pos_x, new_pos_y)
		
		var vel_x = MultiplayerController.players[self.name.to_int()]["vel_x"]
		var vel_y = MultiplayerController.players[self.name.to_int()]["vel_y"]
		var vel = Vector2(vel_x, vel_y)
		
		position = new_pos

		$AnimationPlayer.handle_animation()


func make_player_state():
	var time = Time.get_ticks_msec()
	
	var pos = get_global_position()
	var pos_x = pos.x
	var pos_y = pos.y

	var vel_x = velocity.x
	var vel_y = velocity.y

	return {
		"T": time,         # Time stamp
		"PX": pos_x,       # Position x
		"PY": pos_y,       # Position y
		"VX": vel_x,       # Velocity x
		"VY": vel_y        # Velocity y
	}


func jump():
	jumped.emit()
	velocity.y = jump_velocity


func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func get_input_velocity():
	var horizontal = 0.0
	
	if Input.is_action_pressed("left"):
		horizontal -= 1.0
	
	if Input.is_action_pressed("right"):
		horizontal += 1.0
		
	return horizontal
