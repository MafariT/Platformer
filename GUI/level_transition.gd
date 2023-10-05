extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func play():
	await get_tree().create_timer(0.1).timeout
	animation_player.play("fade")
	await animation_player.animation_finished

func play_backwards():
	await get_tree().create_timer(0.1).timeout
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
