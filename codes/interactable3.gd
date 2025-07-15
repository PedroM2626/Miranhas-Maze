class_name Interactable
extends CollisionObject3D
@onready var Pagecounter = "res://autoloads/page_counter.gd"

var interaction_prompt_text = "Press 'E' to interact"

# all interactables should override this method and implement their own behavior

func _init():
	interaction_prompt_text = "Press 'E' to collect"
func interacted_with():      # Quando o jogador interagir, aumenta a contagem de colecionáveis e remove a página
	print("collected: " + self.name)
	Pagecounter.collected_collectables += 1
	$PageSound.play()
	hide()
	$CollisionShape3D.disabled = true
	await $PageSound.finished
	queue_free()
