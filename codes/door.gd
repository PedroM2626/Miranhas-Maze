extends Node3D
class_name Door1

@export var Audio: AudioStreamPlayer3D 
#@onready var animator = $AnimationPlayer2

@onready var animator = $AnimationPlayer2
	
func open():
	if Audio != null:
		hide()
		Audio.play()
		$MeshInstance3D/StaticBody3D/CollisionShape3D.disabled = true
func open2():
	animator.play("DoorOpen")
