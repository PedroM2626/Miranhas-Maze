extends RayCast3D

@onready var c_dot : TextureRect = get_node(NodePath("Crosshairs/Dot"))
@onready var c_ring : TextureRect = get_node(NodePath("Crosshairs/Ring"))

func _ready() -> void:
	add_exception(owner)
	c_dot.hide()
	c_ring.hide()

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var detected = get_collider()
		
		if detected is Interactable2:
			c_dot.show()
			c_ring.show()
			if Input.is_action_just_pressed("interact"):
				detected._interact(owner)
		else:
			c_dot.hide()
			c_ring.hide()
	else:
		c_dot.hide()
		c_ring.hide()
