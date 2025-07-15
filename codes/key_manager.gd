extends Node3D
class_name KeyManager

@onready var Objectivemanager = ObjectiveManager.new()
@export var door_that_keys_open: Node
@export var ObjectiveLabel: Label
@export var rageImage: TextureRect  # Imagem que tremorá junto com o texto

# Variáveis para o efeito de tremor
var tremor_active = false
var tremor_timer = 0.0
var original_position = Vector2.ZERO
@export var tremor_magnitude = 5.0  # Intensidade do tremor
@export var tremor_speed = 0.05  # Velocidade do tremor
@export var tremor_duration = 3.0  # Duração do tremor
var is_red = false  # Alternância de cor

# Função para obter a quantidade de chaves restantes
func get_keys_left() -> int:
	var keys_left = 0
	for child in get_children():
		# Verifica se o filho pertence ao grupo 'keys'
		if child.is_in_group("keys"):
			keys_left += 1
	return keys_left

func update_objective_message(message: String):
	emit_signal("objective_message_updated", message)

func objective_message_updated(message: String):
	ObjectiveLabel.text = message

func _ready():
	print("ObjectiveLabel: ", ObjectiveLabel)  # Verifique se é um Node válido
	print("RageImage: ", rageImage)  # Verifique se é um Node válido

	
	# Atualiza a mensagem de chaves restantes quando o jogo iniciar
	update_keys_left_message()
	Objectivemanager.objective_message_updated.connect(objective_message_updated)
	# Posição inicial do texto
	original_position = ObjectiveLabel.position  # Substitua "rect_position" por "position"

# Função para aplicar o efeito de tremor em um nó (Label, TextureRect, etc)
func apply_tremor(target_node: Node2D, delta: float) -> void:
	if tremor_active:
		tremor_timer += delta
		
		# Aplica o efeito de tremor
		target_node.position = original_position + Vector2(
			randf_range(-tremor_magnitude, tremor_magnitude),
			randf_range(-tremor_magnitude, tremor_magnitude)
		)
		
		# Alterna a cor do nó
		target_node.modulate = Color.RED if is_red else Color.WHITE
		is_red = !is_red

		# Para o efeito após a duração configurada
		if tremor_timer >= tremor_duration:
			stop_tremor(target_node)

func _process(delta: float) -> void:
	pass

# Função para iniciar o tremor
func start_tremor(target_node: CanvasItem, delta: float) -> void:
	if not target_node:
		printerr("O nó alvo está nulo!")
		return

	# Ativa o tremor
	tremor_active = true
	tremor_timer = 0.0
	original_position = target_node.position  # Salva a posição inicial
	target_node.visible = true  # Garante que o nó seja visível

	# Inicia o processo de tremor e alternância de cores
	while tremor_active:
		# Aplica o efeito de tremor
		var offset = Vector2(
			randf_range(-tremor_magnitude, tremor_magnitude),
			randf_range(-tremor_magnitude, tremor_magnitude)
		)
		target_node.position = original_position + offset

		# Alterna a cor entre vermelho e branco
		if int(tremor_timer * 10) % 2 == 0:
			target_node.modulate = Color(1, 0, 0)  # Vermelho
		else:
			target_node.modulate = Color(1, 1, 1)  # Branco

		# Incrementa o tempo para controlar a alternância de cores
		tremor_timer += delta  # Use delta para garantir suavidade
		await get_tree().process_frame  # Aguarda o próximo frame


# Função para parar o tremor
func stop_tremor(target_node: CanvasItem) -> void:
	if not target_node:
		printerr("O nó alvo está nulo!")
		return
	
	tremor_active = false
	tremor_timer = 0.0
	target_node.position = original_position
	target_node.modulate = Color.WHITE
	target_node.visible = false

func key_collected(key):
	# Remove a chave que foi coletada
	key.queue_free()
	
	# Espera até o próximo frame para liberar a chave
	await get_tree().process_frame
	
	# Atualiza a mensagem do objetivo
	update_keys_left_message()
	
	# Se não houver mais chaves...
	#if get_keys_left() == 0:
		## E se a porta estiver conectada e tiver o método "open"...
		#if door_that_keys_open and door_that_keys_open.has_method("open"):
			## Abre a porta
			#door_that_keys_open.open()
			#
			## Atualiza a mensagem do objetivo e inicia o tremor
			#Objectivemanager.update_objective_message("FUJA!!!")
			#start_tremor(ObjectiveLabel)  # Inicia o tremor no texto
			#start_tremor(rageImage)  # Inicia o tremor na imagem
		#else:
			#printerr("No door connected to keymanager or door doesn't have an 'open' method")

func update_keys_left_message():
	# Atualiza a quantidade de chaves restantes
	Objectivemanager.update_objective_message(str(get_keys_left()) + " keys left before door opens")
