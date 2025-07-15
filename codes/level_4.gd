extends Node3D
@onready var book_manager: Node3D = $NavigationRegion3D/GridMap/Objects
@onready var monster = $GridMap/Monster
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if book_manager.get_books_left() == 0:
		monster.kill_player()	
