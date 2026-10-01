extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	print("HHH,NOOB. U DIED! ")
	
	Engine.time_scale = 0.5       #死亡后的时间变为死亡后的的0.5倍
	body.get_node("CollisionShape2D").queue_free()
	
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1         #时间尺度设置为默认值
	
	get_tree().reload_current_scene()  #重新加载游戏
