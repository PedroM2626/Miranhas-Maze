extends Node3D

@export var directional_light: DirectionalLight3D
@export var day_color: Color = Color(1, 1, 1)
@export var night_color: Color = Color(0, 0, 1)
@export var day_duration: float = 20.0
@export var night_duration: float = 300.0
@export var environment: WorldEnvironment

var timer: float
var is_day: bool = true

func _ready():
	timer = day_duration
	set_day(true)

func _process(delta):
	timer -= delta

	if timer <= 0:
		if is_day:
			call_deferred("_await_timer_and_set_night")
		else:
			call_deferred("_await_timer_and_set_day")

func _await_timer_and_set_night() -> void:
	await get_tree().create_timer(5.0).timeout
	set_day(false)
	timer = night_duration

func _await_timer_and_set_day() -> void:
	await get_tree().create_timer(5.0).timeout
	set_day(true)
	timer = day_duration

func set_day(day: bool):
	is_day = day
	if day:
		directional_light.light_color = day_color
		environment.environment.ambient_light_color = day_colord
	else:
		directional_light.light_color = night_color
		environment.environment.ambient_light_color = night_color
