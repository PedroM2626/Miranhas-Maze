extends Node3D

@export var monster: CharacterBody3D = null
@onready var play_button = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/LevelsButton
@onready var quit_button = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/QuitButton
@onready var fader = $CanvasLayer/Fader
@onready var animation_player = $AnimationPlayer

@export var game_scene: PackedScene = null

func _ready():
	play_button.connect("pressed", Callable(self, "on_levels_pressed"))
	quit_button.connect("pressed", Callable(self, "on_quit_pressed"))
	
	fader.connect("fade_finished", Callable(self, "on_fade_finished"))

func on_levels_pressed():
	fader.fade_out()
	animation_player.play("fade_out")
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://difficulty_menu.tscn")

func on_quit_pressed():
	get_tree().quit()

func on_fade_finished():
	get_tree().change_scene_to_file("res://difficulty_menu.tscn")
