extends Node3D

@export var target_light: OmniLight3D  # Luz a ser controlada
@export var off_range: float = 0.0  # Alcance da luz desligada
@export var on_range: float = 10.0  # Alcance da luz ligada
@export var interaction_distance: float = 4.0  # Distância de interação permitida
@export var rotation_angle: float = 30.0  # Ângulo de rotação da alavanca
@export var rotation_speed: float = 5.0  # Velocidade de rotação
@export var switch_sound: AudioStream  # Som do interruptor

@onready var player_camera: Camera3D = $"/root/Main/Player/Camera3D"  # Ajuste o caminho para sua câmera
@onready var interaction_text: Label3D = $InteractionText  # Texto de interação
@onready var switch_handle: Node3D = $SwitchHandle  # Alavanca do interruptor
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer  # Reprodutor de som

var is_light_on: bool = false  # Estado atual da luz
var is_player_looking: bool = false  # Verifica se o jogador está olhando para o interruptor
var off_rotation: Basis  # Rotação desligada da alavanca
var on_rotation: Basis  # Rotação ligada da alavanca
var focused_switch: Area3D = null  # Interruptor atualmente focado pelo jogador

func _ready():
	# Configura o estado inicial da luz
	if target_light:
		target_light.omni_range = off_range
	
	# Configura as rotações da alavanca
	if switch_handle:
		off_rotation = switch_handle.transform.basis
		on_rotation = Basis(Vector3(1, 0, 0), deg_to_rad(rotation_angle)) * off_rotation
	
	# Configura o som
	if switch_sound:
		audio_player.stream = switch_sound

	# Esconde o texto de interação
	if interaction_text:
		interaction_text.visible = false

func _process(delta: float):
	# Verifica se o jogador está olhando para o interruptor
	check_player_looking_at_switch()

	# Alterna a luz se o jogador apertar "E"
	if is_player_looking and Input.is_action_just_pressed("interact"):
		toggle_light()

func check_player_looking_at_switch():
	var distance = player_camera.global_transform.origin.distance_to(global_transform.origin)
	if distance <= interaction_distance:
		# Testa se o jogador está olhando para o botão
		var from = player_camera.global_transform.origin
		var to = global_transform.origin
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(from, to, [], 0b111111)  # Ajuste a camada de colisão se necessário

		if result and result["collider"] == self:
			is_player_looking = true
			if focused_switch != self:
				interaction_text.visible = true
				focused_switch = self
			return

	# Esconde o texto se o jogador não está olhando
	if focused_switch == self:
		interaction_text.visible = false
		focused_switch = null
	is_player_looking = false

func toggle_light():
	# Alterna o estado da luz
	is_light_on = not is_light_on

	# Ajusta o alcance da luz
	if target_light:
		target_light.omni_range = on_range if is_light_on else off_range

	# Toca o som
	if switch_sound:
		audio_player.play()

	# Esconde o texto de interação
	if interaction_text:
		interaction_text.visible = false

	# Anima a rotação da alavanca
	if switch_handle:
		animate_switch(is_light_on)

func animate_switch(turn_on: bool):
	var target_rotation = on_rotation if turn_on else off_rotation
	var tween = create_tween()
	tween.tween_property(switch_handle, "transform:basis", target_rotation, 1.0 / rotation_speed)
