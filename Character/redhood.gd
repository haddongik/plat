extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_SPEED : int = -1800
const GRAVITY : int = 4200

var started : bool = false

func _physics_process(delta: float) -> void:
	
	if started:
		velocity.y += GRAVITY * delta
		if is_on_floor():
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
			else:
				$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("jump")
	else:
		$AnimatedSprite2D.play("idle")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
