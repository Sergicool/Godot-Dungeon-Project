extends Node2D
class_name RoomManager

@onready var room_factory: RoomFactory = $"../RoomFactory"

# Diccionario para almacenar las salas generadas por posición
var rooms_by_position : Dictionary = {}
var type_of_room_by_position : Dictionary = {}

# Crea y posiciona una sala en la mazmorra
func spawn_room(room_type: String, grid_positions: Array) -> Node2D:
	# Instanciamos la sala
	var room = room_factory.create_room(room_type)
	var room_size = Vector2(room_factory.get_cell_width(), room_factory.get_cell_height())
	if room:
		# Movemos la sala de manera que encaje con los tilemaps de la escena
		room.position = get_spawn_position(grid_positions) * room_size
		add_child(room)
		# Almacena la sala por su posición/es en la matriz
		for _position in grid_positions:
			rooms_by_position[_position] = room
			type_of_room_by_position[_position] = room_type
		return room
	return null

# Los tilemaps de las salas tienen como origen la sala mas abajo a la derecha, esta funcion ayuda la
# funcion spawn_room a encontrar la casilla que ocupe mas abajo a la izquierda
func get_spawn_position(grid_positions: Array) -> Vector2:
	# Inicializar la posición más abajo a la izquierda como la primera en la lista
	var spawn_position = grid_positions[0]
	for _position in grid_positions:
		# Verificar si la posición actual está más abajo (mayor y) o
		# si está al mismo nivel y más a la izquierda (menor x)
		if _position.y > spawn_position.y or (_position.y == spawn_position.y and _position.x < spawn_position.x):
			spawn_position = _position
	return spawn_position

# Devuelve las posiciones ocupadas por salas
func get_occupied_positions() -> Array:
	return rooms_by_position.keys()

# Obtiene las posiciones disponibles para generar salas
func get_potential_positions() -> Array:
	var occupied_positions = get_occupied_positions()
	var potential_positions = []
	# Definir los vectores de las posiciones adyacentes
	var directions = [
		Vector2(1, 0),  # Derecha
		Vector2(-1, 0), # Izquierda
		Vector2(0, 1),  # Abajo
		Vector2(0, -1)  # Arriba
	]
	# Convertir occupied_positions a un diccionario para búsquedas rápidas
	var occupied_dict = {}
	for pos in occupied_positions:
		occupied_dict[pos] = true
	
	# Iterar sobre todas las posiciones ocupadas
	for pos in occupied_positions:
		for dir in directions:
			var adjacent = pos + dir
			# Verificar que la posición adyacente no esté ocupada
			if not occupied_dict.has(adjacent):
				# Añadir a potential_positions si no está ya en la lista
				if adjacent not in potential_positions:
					potential_positions.append(adjacent)
	return potential_positions

func get_room_by_position(room_position: Vector2) -> Node2D:
	if rooms_by_position.has(room_position):
		return rooms_by_position[room_position]
	return null
	
func get_room_type_by_position(room_position : Vector2) -> String:
	var room = get_room_by_position(room_position)
	if room:
		return room.type
	return "void"
	
# Obtiene el componente de una sala existente en una posición específica
func get_room_component_by_position(room_position: Vector2) -> RoomComponent:
	var room = get_room_by_position(room_position)
	if room:
		return room.get_node("RoomComponent")
	return null

func get_room_positions(room: Node2D) -> Array:
	var positions = []
	for _position in rooms_by_position:
		if rooms_by_position[_position] == room:
			positions.append(_position)
	return positions

func get_room_height_by_type(room_type: String) -> int:
	return room_factory.get_room_height_by_type(room_type)
	
func get_room_width_by_type(room_type: String) -> int:
	return room_factory.get_room_width_by_type(room_type)
	
func get_random_room_type() -> String:
	return room_factory.get_random_room_type()
	
func get_random_room_type_with_chances() -> String:
	return room_factory.get_random_room_type_with_chances()
	
# Obtiene todas las salas generadas
func get_all_rooms() -> Array:
	return rooms_by_position.values()

# Limpia todas las salas generadas
func clear_rooms():
	for room in rooms_by_position.values():
		if room:
			room.queue_free()
	rooms_by_position.clear()
