extends Interactable
class_name page

@onready var PageCounter = preload("res://autoloads/page_counter.gd").new()
@onready var PageManager = $"../../PageManager"  # Referencia o PageManager para emitir o sinal correto

signal objective_message_updated(message)

func _init():
	interaction_prompt_text = "Press 'E' to collect"

func interacted_with():
	print("collected: " + self.name)
	PageCounter.collected_collectables += 1
	$PageSound.play()
	hide()
	$CollisionShape3D.disabled = true
	await $PageSound.finished
	queue_free()

	# Atualiza o objetivo no PageManager após a coleta da página
	PageManager.page_collected(self)  # Chama o método do PageManager
