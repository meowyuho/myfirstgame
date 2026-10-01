extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#移动方向-1,0,1
	var direction := Input.get_axis("move_left", "move_right")
	
	#翻转精灵
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	#动画播放
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")  #检测待机动画
		else:
			animated_sprite_2d.play("run")   #检测奔跑i动画
	else:	
		animated_sprite_2d.play("jump")  #检测跳跃动画
	
	#移动
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
