extends Control

@onready var objective_manager = ObjectiveManager.new()  # Referencia o singleton diretamente

func _ready():
	objective_manager.objective_message_updated.connect(objective_message_updated)
	

func objective_message_updated(message: String):
	$ObjectiveLabel.text = message


func set_interaction_text_visible(text_visible : bool):
	$InteractionPrompt.visible = text_visible
	$Crosshair.visible = not text_visible


func set_interaction_label_text(new_text : String):
	$InteractionPrompt.text = new_text
