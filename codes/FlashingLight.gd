extends SpotLight3D

var timer = null

func _ready():
	randomize()
	timer = Timer.new()
	timer.wait_time = randf_range(0.05, 0.1)
	timer.connect("timeout", Callable(self, "on_timer_timeout"))
	add_child(timer)
	timer.start()
	
func on_timer_timeout():
	timer.wait_time = randf_range(0.05, 0.1)
	light_energy = randf_range(0.0, 2.0)
