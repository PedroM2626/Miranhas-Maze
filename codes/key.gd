extends Interactable

@onready var key_manager = get_parent()
@export var monster: CharacterBody3D


func _init():
	interaction_prompt_text = "Press 'E' to collect"

func interacted_with():
	if not key_manager.has_method("key_collected"):
		printerr("key " + self.name + " doesn't have a parent KeyManager with a key_collected method")
	
	print("collected: " + self.name)
	hide()
	$CollisionShape3D.disabled = true # so we can't collect it multiple times
	$KeySoundPlayer.play()
	if monster:
		monster.walkSpeed += 1
		monster.runSpeed +=1
		monster.chaseDistance +=2
		if monster.scale < Vector3(5.0,5.0,5.0):
			monster.increase_scale_HitBox(1.2)
			monster.increase_scale(1.2)
	await $KeySoundPlayer.finished # wait for the sound to finish
	key_manager.key_collected(self) # the key manager will handle freeing the key
	
