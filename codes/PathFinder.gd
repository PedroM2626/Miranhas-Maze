extends Node
class_name PathFinder

var grid_map : GridMap  # Continua sendo GridMap
var navigation_id = 1
var astar : AStar3D

var navigation_points = []
var indicies = {}

func _init(p_grid_map: GridMap, p_navigation_id: int):  # Usa GridMap aqui também
	if not p_grid_map:
		print("Error: grid_map is null")
		return
	
	self.grid_map = p_grid_map
	self.navigation_id = p_navigation_id
	self.astar = AStar3D.new()
	
	# Configura os tiles de navegação
	for cell in grid_map.get_used_cells():
		var id = grid_map.get_cell_item(Vector3i(cell.x, cell.y, cell.z))
		if id == navigation_id:
			var point = Vector3i(cell.x, cell.y, cell.z)  # Usando Vector3i aqui
			navigation_points.append(point)
			var index = indicies.size()
			indicies[point] = index
			astar.add_point(index, point)
	
	# Conecta cada tile
	for point in navigation_points:
		var index = get_point_index(point)
		var relative_points = PackedVector3Array([
			Vector3i(point.x + 1, point.y, point.z),  # Usando Vector3i aqui
			Vector3i(point.x - 1, point.y, point.z),
			Vector3i(point.x, point.y, point.z + 1),
			Vector3i(point.x, point.y, point.z - 1),
		])
		
		for relative_point in relative_points:
			var relative_index = get_point_index(relative_point)
			if relative_index != -1:
				if astar.has_point(relative_index):
					astar.connect_points(index, relative_index)

func find_path(start: Vector3, target: Vector3) -> Array:
	if not grid_map:
		print("Error: grid_map is null")
		return []
	
	var grid_start = grid_map.local_to_map(start)
	var grid_end = grid_map.local_to_map(target)
	
	grid_start.y = 0
	grid_end.y = 0
	
	var index_start = get_point_index(grid_start)
	var index_end = get_point_index(grid_end)
	
	if index_start == -1 or index_end == -1:
		return []
	
	var astar_path = astar.get_point_path(index_start, index_end)
	var world_path = []
	for point in astar_path:
		world_path.append(grid_map.map_to_local(Vector3i(point.x, point.y, point.z)))  # Usando Vector3i para conversão
			
	return world_path

func get_point_index(vector: Vector3i) -> int:  # Mudança para Vector3i
	if indicies.has(vector):
		return indicies[vector]
	return -1
