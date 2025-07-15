extends Node3D

@onready var ObjectiveLabel = $"../../../ObjectiveLabel"

# Sinal para atualizar a mensagem do objetivo
signal objective_message_updated(message)

func _ready():
	# Conectar o sinal ao método que atualiza a label
	connect("objective_message_updated", Callable(self, "_on_objective_message_updated"))
	
	# Atualiza a mensagem de páginas restantes quando o jogo iniciar
	update_pages_left_message()

func book_collected(book):
	# Remove a página que foi coletada
	book.queue_free()

	# Espera até o próximo frame para liberar a página
	await get_tree().process_frame

	# Atualiza a mensagem do objetivo
	update_pages_left_message()

func update_pages_left_message():
	# Calcula a quantidade de páginas restantes e emite a mensagem
	var remaining_pages = get_books_left()
	var message = str(remaining_pages) + " books left"
	emit_signal("objective_message_updated", message)

func _on_objective_message_updated(message: String):
	# Atualiza o texto da label com a nova mensagem
	ObjectiveLabel.text = message

func get_books_left() -> int:
	var pages_left = 0
	for child in get_children():
		# Verifica se o filho pertence ao grupo 'pages'
		if child.is_in_group("books"):
			pages_left += 1
	return pages_left
