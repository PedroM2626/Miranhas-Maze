extends Node3D

@onready var door1 = $Door
@export var should_blink : bool = false
@export var blink_interval : float = 0.5
@export var metaldoor: Node3D
@export var monster: CharacterBody3D
@export var LightMonster: OmniLight3D
@export var keymanager: Node3D
@export var TransitionSound: AudioStreamPlayer3D
@export var RageSound: AudioStreamPlayer3D
@export var RageSoundPermanent: AudioStreamPlayer3D
@export var door: Node3D
@export var doorCamera: Camera3D
@onready var interactable = Interactable2.new()
@onready var ligh_door1 = $Door/Door1Camera/SpotLight3D

var all_lights = []

#@export var world_env: WorldEnvironment 
#@onready var env = world_env.environment

@onready var player = $player
var rage_mode_activated = false  # Flag para ativar o Rage Mode apenas uma vez
var door_opened = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	all_lights = get_tree().get_nodes_in_group("Lights")
	metaldoor.Door_Camera.current = false
	#$Door/Door1Camera.current = false
	player.camera.current = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_tree().call_group("enemy", "target_position", player.global_transform.origin)
	
	if not door_opened and keymanager.get_keys_left() == 1 or Input.is_action_just_pressed("invokeRageMode"):
		door_opened = true
		keymanager.Objectivemanager.update_objective_message("Pegue a última chave")
		door.locked = false
		metaldoor.Door_Camera.current = true
		metaldoor.Door_Camera.visible = true
		door.animator.play("open")
		door.open = false
		await get_tree().create_timer(2).timeout
		metaldoor.Door_Camera.current = false
		metaldoor.Door_Camera.visible = false
		player.camera.current = true
			
	if not rage_mode_activated and keymanager.get_keys_left() == 0:
		doorCamera.current = true
		doorCamera.visible = true
		ligh_door1.visible = true
		$Door/AnimationPlayer2.play("DoorOpen")
		await get_tree().create_timer(3).timeout
		doorCamera.current = false
		doorCamera.visible = false
		player.camera.current = true
		rage_mode_activated = true  # Marca que o Rage Mode foi ativado
		keymanager.Objectivemanager.update_objective_message("")
		TransitionSound.play()
		await TransitionSound.finished
		keymanager.Objectivemanager.update_objective_message("FUJA!!!")
		keymanager.start_tremor(keymanager.ObjectiveLabel, delta)  # Passa como Node2D
		RageMode()
		if should_blink:
			while should_blink:
				blink_lights()
				await get_tree().create_timer(1).timeout

func change_light_colors():
	for light in all_lights:
		if light is OmniLight3D or light is SpotLight3D or light is DirectionalLight3D:
			light.light_color = Color(255, 0, 0)
		
func RageMode():
	change_light_colors()
	monster.stamina = 1000
	monster.chaseDistance = 100
	monster.walkSpeed *= 1.5
	monster.runSpeed *= 1.5
	LightMonster.visible = true		
	LightMonster.light_color = Color(1.0, 0.0, 0.0)  
	LightMonster.light_energy = 10
	RageSound.play()
	#keymanager.start_tremor(keymanager.rageImage)  # Passa como Node2D
	await RageSound.finished
	#keymanager.stop_tremor(keymanager.ObjectiveLabel)  # Passa como Node2D
	#keymanager.stop_tremor(keymanager.rageImage)  # Passa como Node2D
	RageSoundPermanent.play()

func blink_lights() -> void:
	# Alterna o estado das luzes
	await get_tree().create_timer(blink_interval).timeout
	set_all_lights_active(false)
	await get_tree().create_timer(blink_interval).timeout
	set_all_lights_active(true)

func set_all_lights_active(state : bool) -> void:
	# Define o estado de todas as luzes na cena
	for light in all_lights:
		if light is OmniLight3D or light is SpotLight3D or light is DirectionalLight3D:
			light.visible = state
