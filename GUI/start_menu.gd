extends CenterContainer

@onready var start = %Start


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	start.grab_focus()

func _on_start_pressed():
	await LevelTransition.play()
	get_tree().change_scene_to_file("res://Levels/level_one.tscn")
	LevelTransition.play_backwards()

func _on_exit_pressed():
	get_tree().quit()
