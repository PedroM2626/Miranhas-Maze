extends Node3D
class_name MetalDoor

@export var animator : AnimationPlayer
@export var door_open_sfx : AudioStreamPlayer3D
@export var door_close_sfx : AudioStreamPlayer3D
@export var Door_Camera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Door_Camera.current = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if objetocount == 0:
		#OpenDoor()
	pass
	
func OpenDoor():
	animator.play("open")
	door_open_sfx.play()
	door_open_sfx.pitch_scale = randf_range(0.8, 1.2)
	pass
