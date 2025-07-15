extends Node
class_name ObjectiveManager

signal objective_message_updated(message : String)

func update_objective_message(message : String):
	emit_signal("objective_message_updated", message)
