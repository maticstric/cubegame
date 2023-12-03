extends AnimationPlayer


func handle_animation(velocity):
	if velocity.length() == 0:
		play("IDLE")
	else:
		
		if velocity.x < 0:
			horizontal_flip(-1)
		elif velocity.x > 0:
			horizontal_flip(1)

		if velocity.y < 0:
			play("RISE")
		elif velocity.y > 0:
			play("FALL")
		elif velocity.x != 0:
			play("WALK")


func horizontal_flip(horizontal_direction):
	var polygons = $"../Polygons"
	var skeleton2d = $"../Skeleton2D"

	polygons.scale.x = abs(polygons.scale.x) * horizontal_direction
	skeleton2d.scale.x = abs(skeleton2d.scale.x) * horizontal_direction

