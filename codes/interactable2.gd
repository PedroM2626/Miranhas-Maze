extends CollisionObject3D

var interaction_prompt_text = "Press 'E' to interact"

# all interactables should override this method and implement their own behavior
func interacted_with():
	print("interacted with " + self.name)
