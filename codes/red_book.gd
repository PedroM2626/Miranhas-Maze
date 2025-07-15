extends Interactable
class_name Book

@export var book_color: Color = Color(1, 1, 1)  # Cor inicial padrão (branco)
@onready var BookCounter = preload("res://Books/book_counter.gd").new()
@onready var BookManager = $".."  # Referencia o PageManager para emitir o sinal correto

signal objective_message_updated(message)

func _ready():
	# Aplica a cor configurada no Inspetor ao material do livro
	if has_node("$Mesh1_Mesh1_045"):
		var mesh_instance = $Mesh1_Mesh1_045
		if mesh_instance.material_override:
			var material = mesh_instance.material_override.duplicate()  # Duplica o material para evitar mudar a cena original
			material.albedo_color = book_color
			mesh_instance.material_override = material

func _init():
	interaction_prompt_text = "Press 'E' to collect"

func interacted_with():
	print("Collected: " + self.name)
	BookCounter.collected_collectables += 1
	$BookSound.play()
	hide()
	$CollisionShape3D.disabled = true
	await $BookSound.finished
	queue_free()
	
	# Atualiza o objetivo no PageManager após a coleta da página
	BookManager.book_collected(self)  # Chama o método do PageManager

	# Emite o sinal para notificar o progresso
	emit_signal("objective_message_updated", "Collected book")
