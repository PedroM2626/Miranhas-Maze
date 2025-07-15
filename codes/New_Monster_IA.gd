extends CharacterBody3D
class_name Monster2

# Export variables
@export var runSpeed: float = 10.0
@export var walkSpeed: float = 5.0
@export var chaseDistance: float = 20.0
@export var stamina: float = 100.0
@export var staminaDrainRate: float = 5.0
@export var staminaRegenRate: float = 2.0
@export var chaseMusic: AudioStreamPlayer3D
@export var killMusic: AudioStreamPlayer
@export var gameOverText: Label
@export var fadeImage: TextureRect
@export var staticaEffect: TextureRect
@export var maxDistance: float = 20.0
@export var maxAlpha: float = 0.8
@export var maxStaticaAlpha: float = 0.8
@export var blackScreen: ColorRect = null

var has_triggered_chase_effect = false
@export var start_chase_audio_stream: AudioStreamPlayer  # Substitua pelo caminho correto do áudio
@export var screenShakeMagnitude: float = 0.5 # Intensidade do tremor
@export var screenShakeDuration: float = 1  # Duração do tremor

# Posições de patrulha
@export var patrolRadius: float = 20.0  # Raio para geração de patrulhas aleatórias
@export var patrolCooldown: float = 2.0  # Intervalo de 2 segundos para mudar o ponto de patrulha

var currentPatrolPoint: Vector3 = Vector3.ZERO  # Ponto de patrulha atual
var patrolTimer: Timer = null  # Temporizador para mudar o ponto de patrulha

# Variáveis internas
var currentDistance: float = 0.0
var isChasing: bool = false
@export var agent: NavigationAgent3D
@export var animator: AnimationTree
@onready var player = $"../../player" if $"../player" == null else $"../player"
@onready var playerCamera
@onready var PlayerSpeed
@onready var hitbox_area = $HitboxArea

# Flag para verificar a presença do jogador
var playerExists: bool = false

var isRecoveringStamina: bool = false

func _ready() -> void:
	if player:
		PlayerSpeed = player.WALKING_SPEED
		playerCamera = player.get_node("HeadYPivot/HeadXPivot/CameraTilt")
		print(playerCamera)  # Para verificar se a referência foi atribuída corretamente
	
	$HitboxArea.connect("body_entered", Callable(self, "_on_body_entered"))
	agent = $NavigationAgent3D
	animator = $Skeleton3D/node_4486ddc7_b84c_45a4_942e_26f380915c43_mesh0/AnimationTree
	if gameOverText:
		gameOverText.text = ""
		blackScreen.visible = false
	else: print("sem GameOver")

	if player == null:
		playerExists = false
	else:
		playerExists = true

	# Configura visibilidade dos efeitos
	fadeImage.visible = playerExists
	staticaEffect.visible = playerExists
	
	# Configura o temporizador de patrulha
	patrolTimer = Timer.new()
	patrolTimer.wait_time = patrolCooldown
	patrolTimer.one_shot = true
	add_child(patrolTimer)
	patrolTimer.connect("timeout", Callable(self, "_on_patrol_timeout"))
	
	# Inicia a patrulha
	_on_patrol_timeout()

func _process(delta: float) -> void:
	if not playerExists:
		return
	
	# Atualiza a distância para o jogador
	currentDistance = global_position.distance_to(player.global_position)
	agent.set_target_position(player.global_position)

	# Calcula a direção
	var direction = (agent.get_next_path_position() - global_position).normalized()
	var next_location = agent.get_next_path_position()
	var new_velocity = (next_location - global_position).normalized() * (runSpeed if isChasing else walkSpeed)

	if currentDistance <= chaseDistance and stamina > 0:
		isChasing = true
		stamina -= staminaDrainRate * delta
		isRecoveringStamina = false
		
		# Se o efeito ainda não foi acionado, inicia o tremor e o áudio
		if !has_triggered_chase_effect:        
			has_triggered_chase_effect = true
			start_screen_shake_effect()
	elif currentDistance <= chaseDistance and stamina <= 0:
		isChasing = true
		stamina -= staminaDrainRate * delta
		isRecoveringStamina = true
	else:
		isChasing = false
		move_to_patrol_point(delta)
		isRecoveringStamina = true

	# Garante que a stamina fique no intervalo [0, 100]
	stamina = clamp(stamina, 0.0, 100.0)
	
	# Rotaciona o monstro na direção do movimento
	if direction != Vector3.ZERO:
		look_at(global_position + direction, Vector3.UP)

	# Move o monstro
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()

	# Atualiza a animação e os efeitos visuais
	update_animation(delta)
	update_visual_effects(delta)

func target_position(target):
	agent.target_position = target

func start_screen_shake_effect() -> void:
	var original_speed = PlayerSpeed
	
	# Reproduz o áudio de início de perseguição
	if start_chase_audio_stream:
		start_chase_audio_stream.play()

	# Salva a posição local original da câmera
	var original_position = playerCamera.position
	
	print("Tremor iniciado")
	print("Posição original (local):", original_position)

	var elapsed_time = 0.0

	while elapsed_time < screenShakeDuration:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		PlayerSpeed = 0.0

		# Aplica tremor na posição local
		playerCamera.position = original_position + Vector3(
			randf_range(-screenShakeMagnitude, screenShakeMagnitude),
			randf_range(-screenShakeMagnitude, screenShakeMagnitude),
			0
		)

		# Aguarda um frame
		await get_tree().process_frame
		elapsed_time += get_process_delta_time()

	# Restaura a posição local original
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerSpeed = original_speed
	playerCamera.position = original_position
	
	print("Tremor concluído")
	print("Posição restaurada (local):", playerCamera.position)


func move_to_patrol_point(delta: float) -> void:
	# Se o monstro não está perseguindo, ele se move para o ponto de patrulha
	var direction = (currentPatrolPoint - global_position).normalized()
	velocity = direction * walkSpeed
	
	# Se o monstro chegou ao ponto de patrulha, aguarda o próximo ponto
	if global_position.distance_to(currentPatrolPoint) < 1.0:
		if not patrolTimer.is_stopped():
			patrolTimer.start()  # Reinicia o temporizador para trocar o ponto de patrulha

func _on_patrol_timeout() -> void:
	# Gera uma nova posição de patrulha aleatória dentro de um raio
	var randomOffset = Vector3(randf_range(-patrolRadius, patrolRadius), 0, randf_range(-patrolRadius, patrolRadius))
	currentPatrolPoint = global_position + randomOffset
	agent.set_target_position(currentPatrolPoint)

func update_visual_effects(delta: float) -> void:
	if not playerExists:
		return
	
	var normalizedDistance = clamp(currentDistance / maxDistance, 0.0, 1.0)
	set_transparency(normalizedDistance)
	set_statica_effect(normalizedDistance)

func set_transparency(normalizedDistance: float) -> void:
	var color = fadeImage.modulate
	color.a = lerp(maxAlpha, 0.0, normalizedDistance)
	fadeImage.modulate = color

func set_statica_effect(normalizedDistance: float) -> void:
	var color = staticaEffect.modulate
	color.a = lerp(maxStaticaAlpha, 0.0, normalizedDistance)
	staticaEffect.modulate = color

func update_animation(delta: float) -> void:
	var current_speed = velocity.length()
	var max_speed: float = runSpeed
	var blend_value: float = 0.0

	# Define o valor do blend com base na situação atual
	if isChasing:
		if stamina <= 0:  # Sem stamina, correndo devagar
			blend_value = 2.0
		elif current_speed > 0:  # Correndo normalmente
			blend_value = clamp(current_speed / max_speed * 3.0, 2.0, 3.0)
		else:  # Parado durante a perseguição
			blend_value = 0.0
	else:
		if current_speed > 0:  # Andando durante patrulha
			blend_value = 1.0
		else:  # Parado durante patrulha
			blend_value = 0.0

	# Aplica o valor calculado no parâmetro do AnimationTree
	if animator:
		animator.set("parameters/blend_position", blend_value)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body == player:
		kill_player()

func kill_player() -> void:
	player.pausescreen.GameConcluded = true
	get_tree().paused = true
	player.pausescreen.queue_free()
	gameOverText.text = "GAME OVER!"
	blackScreen.visible = true
	runSpeed = 0
	walkSpeed = 0
	chaseMusic.stop()
	killMusic.play()
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://src/menu_components/MainMenu.tscn")

func increase_scale(factor: float) -> void:
	# Multiplica a escala atual pelo fator fornecido
	scale *= Vector3(factor, factor, factor)
	
func increase_scale_HitBox(scale_factor: float):
	# Aumenta a escala do monstro
	self.scale *= scale_factor
	
	# Ajusta a escala da área de colisão (Hitbox)
	if hitbox_area:
		hitbox_area.scale *= scale_factor
