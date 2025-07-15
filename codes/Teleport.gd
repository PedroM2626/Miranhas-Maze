extends Node3D

@onready var teleport = $Teleporter
@export var teleport_position: Vector3

func _ready() -> void:
	teleport.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Verifica se o corpo tem a propriedade "tag" e se ela é "player" ou "monster"
	if body.is_in_group("player") or body.is_in_group("Monster"):
		body.global_transform.origin = teleport_position
		print("Objeto teletransportado: ", body.name)
