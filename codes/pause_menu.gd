extends CanvasLayer

@onready var resumeButton = $VBoxContainer/ResumeButton

var GameConcluded = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Capture o mouse de volta


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not GameConcluded == true:
		visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Libera o cursor do mouse
		resumeButton.grab_focus()  # Faz o botão ganhar o foco


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_main_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/menu_components/MainMenu.tscn")
