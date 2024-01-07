extends CharacterBody2D

@export var projectile_scene : PackedScene
@export var projectile_min_speed : float
@export var projectile_max_speed : float
@onready var projectile_initial_speed = projectile_min_speed

@export var move_speed : float
@export var throw_move_speed : float
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var max_jumps : int

var current_knockback = Vector2.ZERO
@export var knockback : float
@export_range(0, 1, 0.1) var knockback_diminishment_rate : float

@onready var jump_velocity = -(2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity = -(-2.0 * jump_height) / jump_time_to_peak ** 2
@onready var fall_gravity = -(-2.0 * jump_height) / jump_time_to_descent ** 2


var authority
var grounded
var cur_time = 0
var jump_num = 0



signal jumped
signal landed

var position_state = {
	"t": 0,
	"x": 0,
	"y": 0
}

var animation_state = {
	"t": 0,
	"prev_t": 0,
	"a": "IDLE"
}

var hor_dir_state = {
	"t": 0,
	"prev_t": 0,
	"h": 1
}

func _ready():
	$AnimationPlayer.animation_started.connect(_on_animation_started)
	$Hurtbox.area_entered.connect(_on_hurtbox_entered)

func _physics_process(delta):
	cur_time = Time.get_ticks_msec()
	
	if authority:
		
		if is_on_floor():
			if not grounded:
				landed.emit()
				
			grounded = true
		else:
			grounded = false

		$AnimationPlayer.handle_animation()
		
		if velocity.x < 0:
			horizontal_flip(-1)
		elif velocity.x > 0:
			horizontal_flip(1)
		
		velocity.x = get_input_velocity() * move_speed
		velocity.y += get_gravity() * delta
		velocity += current_knockback
		
		# Slowly reduce knockback if any
		current_knockback = current_knockback.slerp(Vector2.ZERO, knockback_diminishment_rate)
		
		if Input.is_action_just_pressed("attack"):
			$AnimationPlayer.play("ATTACK")
		
		if Input.is_action_pressed("throw"):
			#projectile_initial_speed += 1
			
			if projectile_initial_speed < projectile_max_speed:
				projectile_initial_speed += 1
				
			if abs(velocity.x) > 0:
				velocity.x = get_input_velocity() * throw_move_speed
				
		elif Input.is_action_just_released("throw"):
			var projectile = projectile_scene.instantiate()
			projectile.set_global_position($ProjectileSpawnPosition.global_position)
			projectile.initial_speed = projectile_initial_speed
			get_tree().root.add_child(projectile)
			
			projectile_initial_speed = projectile_min_speed
		
		if is_on_floor():
			jump_num = 0
		
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				jump()
			elif jump_num < max_jumps - 1:
				jump()
				jump_num += 1
		
		move_and_slide()
		
		var new_position_state = {}
		new_position_state["t"] = cur_time
		new_position_state["x"] = get_global_position().x
		new_position_state["y"] = get_global_position().y
		
		receive_position_state.rpc(new_position_state)
	else:
		var new_pos = Vector2(position_state["x"], position_state["y"])
		new_pos = get_global_position().lerp(new_pos, 0.5)
		set_global_position(new_pos)

@rpc("any_peer", "call_remote", "unreliable")
func receive_position_state(new_position_state):
	if new_position_state["t"] > position_state["t"]:
		position_state = new_position_state


@rpc("any_peer", "call_remote", "unreliable")
func receive_hor_dir_state(new_hor_dir_state):
	if new_hor_dir_state["t"] > hor_dir_state["t"]:
		hor_dir_state = new_hor_dir_state
		horizontal_flip(hor_dir_state["h"])


@rpc("any_peer", "call_remote", "unreliable")
func receive_animation_state(new_animation_state):
	if new_animation_state["t"] > animation_state["t"]:
		animation_state = new_animation_state
		$AnimationPlayer.play(animation_state["a"])


func _on_animation_started(animation_name):
	if authority:
		var new_animation_state = {}
		new_animation_state["t"] = cur_time
		new_animation_state["a"] = animation_name
		receive_animation_state.rpc(new_animation_state)


func jump():
	jumped.emit()
	velocity.y = jump_velocity


func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func horizontal_flip(horizontal_direction):
	var polygons = $Polygons
	var skeleton2d = $Skeleton2D
	var hitbox = $Hitbox

	polygons.scale.x = abs(polygons.scale.x) * horizontal_direction
	skeleton2d.scale.x = abs(skeleton2d.scale.x) * horizontal_direction
	hitbox.scale.x = abs(hitbox.scale.x) * horizontal_direction
	
	var new_hor_dir_state = {}
	new_hor_dir_state["t"] = cur_time
	new_hor_dir_state["h"] = horizontal_direction
	receive_hor_dir_state.rpc(new_hor_dir_state)


func get_input_velocity():
	var horizontal = 0.0
	
	if Input.is_action_pressed("left"):
		horizontal -= 1.0
	
	if Input.is_action_pressed("right"):
		horizontal += 1.0
		
	return horizontal


func _on_hurtbox_entered(area):
	# We only want to do something if we have authority
	if authority == true:
		var hitting_player = area.owner # Player who is hitting
		var direction = get_global_position() - hitting_player.get_global_position()
		direction = direction.normalized()
		
		current_knockback = direction * hitting_player.knockback
		
		print(str(multiplayer.get_unique_id()) + str(direction))
	#print(str(multiplayer.get_unique_id()) + " " + str(area.name))
