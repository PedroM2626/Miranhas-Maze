extends Node3D

@onready var monster = $Monster
@onready var player = get_node("player")
@onready var orb_container = $NavigationRegion3D/GridMap/OrbContainer
@onready var ObjectiveLabel = $ObjectiveLabel

var collected_orbs = 0
var total_orb_count = 20

var m = FollowTarget3D

func _process(delta: float) -> void:
	get_tree().call_group("enemy", "target_position", player.global_transform.origin)

# Atualiza a mensagem de objetivo e emite o sinal
func update_objective_message(message: String):
	ObjectiveLabel.text = message
	emit_signal("objective_message_updated", message)

func _ready():
	update_orbs_left_message()

	# Conecte o sinal para atualizar a mensagem de objetivo
	self.connect("objective_message_updated", Callable(self, "objective_message_updated"))

	# Verifique se o jogador foi encontrado
	if player:
		player.connect("orb_collected", Callable(self, "on_orb_collected"))  # Conecte o sinal
	else:
		print("Erro: O jogador não foi encontrado!")

	total_orb_count = orb_container.get_child_count()

func update_orbs_left_message():
	var orbs_left = total_orb_count - collected_orbs
	update_objective_message(str(orbs_left) + " orbs left")  # Atualize a mensagem aqui

func on_orb_collected():
	collected_orbs += 1
	update_orbs_left_message()
	print("Orb collected! Total: ", collected_orbs)  # Mensagem de depuração

	if collected_orbs >= total_orb_count:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://src/menu_components/MainMenu.tscn")  # Transição para o menu principal

func objective_message_updated(message: String):
	ObjectiveLabel.text = message  # Atualiza o texto do ObjectiveLabel
