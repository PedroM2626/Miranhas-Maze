extends Control

@onready var fader            = $CanvasLayer/Fader
@onready var animation_player = $AnimationPlayer
@onready var normalbtn        = $CanvasLayer/Fader/Control/VBoxContainer/normalbtn
@onready var hardbtn          = $CanvasLayer/Fader/Control/VBoxContainer/hardbtn
@onready var extremebtn       = $CanvasLayer/Fader/Control/VBoxContainer/extremebtn
@onready var playbtn          = $CanvasLayer/Fader/Control/Play
@onready var difficultyLabel  = $CanvasLayer/Fader/Control/difficultylabel

#const FONT_PATH := "res://fonts/MinhaFonte.ttf"  # seu .ttf/.otf aqui
var next_scene_path = "res://src/menu_components/levels.tscn"  # Caminho da próxima cena

func _ready():
	# carrega fonte com FontFile, não Font (abstrato)
	#var custom_font = FontFile.new()
	#custom_font.font_data = load(FONT_PATH)
	#custom_font.font_size = 32  # ajuste tamanho
	#difficultyLabel.add_theme_font_override("font", custom_font)
	
	normalbtn.connect("pressed", Callable(self, "_on_normal_button_pressed"))
	hardbtn.connect("pressed", Callable(self, "_on_hard_button_pressed"))
	extremebtn.connect("pressed", Callable(self, "_on_extreme_button_pressed"))
	playbtn.connect("pressed", Callable(self, "_on_play_button_pressed"))
	fader.connect("fade_finished", Callable(self, "on_fade_finished"))

func _process(delta: float) -> void:
	match GameSettings.difficulty:
		GameSettings.Difficulty.NORMAL:
			difficultyLabel.text = "NORMAL"
			difficultyLabel.add_theme_color_override("font_color", Color(1, 1, 1))
		GameSettings.Difficulty.HARD:
			difficultyLabel.text = "HARD"
			difficultyLabel.add_theme_color_override("font_color", Color(0, 0, 0))
		GameSettings.Difficulty.EXTREME:
			difficultyLabel.text = "EXTREME"
			difficultyLabel.add_theme_color_override("font_color", Color(1, 0, 0))

func _on_normal_button_pressed():
	GameSettings.difficulty = GameSettings.Difficulty.NORMAL

func _on_hard_button_pressed():
	GameSettings.difficulty = GameSettings.Difficulty.HARD

func _on_extreme_button_pressed():
	GameSettings.difficulty = GameSettings.Difficulty.EXTREME
	
func _on_play_button_pressed():
	fader.fade_out()
	animation_player.play("fade_out")
	
func on_fade_finished():
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
