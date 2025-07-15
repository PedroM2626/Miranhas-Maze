extends Node
class_name page_counter

signal collected_collectables_updated

var total_collectables = 0
var collected_collectables = 0:
	set(value):
		collected_collectables = value
		emit_signal("collected_collectables_updated", collected_collectables)

# Função para inicializar o número total de colecionáveis
func initialize_variables(initial : int, total : int):
	collected_collectables = initial
	total_collectables = total
