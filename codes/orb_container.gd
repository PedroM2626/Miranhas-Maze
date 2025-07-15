extends Node3D

@onready var Objectivemanager = ObjectiveManager.new()
@onready var ObjectiveLabel = $"../../../ObjectiveLabel"

func update_objective_message(message : String):
	emit_signal("objective_message_updated", message)
	
func objective_message_updated(message: String):
	ObjectiveLabel.text = message

func _ready():
	update_orbs_left_message()
	Objectivemanager.objective_message_updated.connect(objective_message_updated)


func key_collected(key):
	# remove the key that has been collected
	key.queue_free()
	
	# wait for the next frame (key is not freed immediately)
	await get_tree().process_frame
	
	# update the objective message
	update_orbs_left_message()

func update_orbs_left_message():
	Objectivemanager.update_objective_message(str(get_child_count()) + " orbs left")
