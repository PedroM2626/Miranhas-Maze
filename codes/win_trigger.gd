extends Node3D
class_name barrier
@onready var win_collider = $Area3D
@export var canvasLayer: CanvasLayer
@export var CongratulationsAudio: AudioStreamPlayer3D
@export var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Conectar o sinal corretamente
	win_collider.connect("body_entered", Callable(self, "_on_win_collider_body_entered"))

# Função chamada quando o corpo colide com o WinCollider
func _on_win_collider_body_entered(body):
	if body.name == "player":  # Verifica se o corpo que colidiu é o player
		player.pausescreen.GameConcluded = true
		canvasLayer.visible = true
		CongratulationsAudio.play()
		await CongratulationsAudio.finished
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://src/menu_components/MainMenu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
