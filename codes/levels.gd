extends Control

@onready var backButton = $CanvasLayer/Fader/Control/backButton
@onready var fader = $CanvasLayer/Fader
@onready var animation_player = $AnimationPlayer
@onready var orbs1 = $CanvasLayer/Fader/Control/VBoxContainer/orbs_1
@onready var keys2 = $CanvasLayer/Fader/Control/VBoxContainer/keys_1
@onready var pages3 = $CanvasLayer/Fader/Control/VBoxContainer/pages_1
@onready var LV4 = $CanvasLayer/Fader/Control/VBoxContainer2/LV4

var next_scene_path = ""  # Variável para armazenar o caminho da próxima cena

func _ready():
	backButton.connect("pressed", Callable(self, "on_back_pressed"))
	orbs1.connect("pressed", Callable(self, "on_orbs1_pressed"))
	keys2.connect("pressed", Callable(self, "on_keys2_pressed"))
	pages3.connect("pressed", Callable(self, "on_pages3_pressed"))
	LV4.connect("pressed", Callable(self, "on_LV4_pressed"))
	fader.connect("fade_finished", Callable(self, "on_fade_finished"))

func on_orbs1_pressed() -> void:
	fader.fade_out()
	animation_player.play("fade_out")
	next_scene_path = "res://src/Level.tscn"  # Defina o caminho da próxima cena
	await get_tree().create_timer(1).timeout  # Aguarde 1 segundo
	get_tree().change_scene_to_file(next_scene_path)

func on_keys2_pressed() -> void:
	fader.fade_out()
	animation_player.play("fade_out")
	next_scene_path = "res://labyrinth/labyrinth.tscn"
	await get_tree().create_timer(1).timeout  # Aguarde 1 segundo
	get_tree().change_scene_to_file(next_scene_path)

func on_back_pressed() -> void:
	fader.fade_out()
	animation_player.play("fade_out")
	next_scene_path = "res://src/menu_components/MainMenu.tscn"
	await get_tree().create_timer(0.5).timeout  # Aguarde 1 segundo
	get_tree().change_scene_to_file(next_scene_path)

func on_pages3_pressed() -> void:
	fader.fade_out()
	animation_player.play("fade_out")
	next_scene_path = "res://labyrinth2/labyrinth.tscn"
	await get_tree().create_timer(1).timeout  # Aguarde 1 segundo
	get_tree().change_scene_to_file(next_scene_path)
	
	
func on_LV4_pressed() -> void:
	fader.fade_out()
	animation_player.play("fade_out")
	next_scene_path = "res://src/Level4.tscn"
	await get_tree().create_timer(1).timeout  # Aguarde 1 segundo
	get_tree().change_scene_to_file(next_scene_path)
