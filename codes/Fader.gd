extends ColorRect

@onready var animation_player = $AnimationPlayer

signal fade_finished

func _ready():
	animation_player.connect("animation_finished", Callable(self, "on_animation_finished"))

func fade_in():
	animation_player.play("fade_in")

func fade_out():
	animation_player.play("fade_out")

func on_animation_finished(_animation_name):
	emit_signal("fade_finished")

func set_playback_speed(speed: float):
	if animation_player.is_playing():
		animation_player.playback_speed = speed
