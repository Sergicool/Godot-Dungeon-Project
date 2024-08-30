extends Node2D
class_name RoomManager

@onready var room_factory: RoomFactory = $"../RoomFactory"

# Diccionario para almacenar las salas generadas por posición
var rooms_by_position : Dictionary = {}

# Crea un tipo de una sala y se coloca en las posiciones indicadas
func spawn_room(room_type: String, grid_positions: Array) -> Node2D:
	# Instanciamos la sala
	var room = room_factory.create_room(room_type)
	# Obtenemos las dimensiones de su tipo de sala
	var room_size = Vector2(room_factory.get_room_width(), room_factory.get_room_height())
	if room:
		# Movemos la sala de manera que encaje con los tilemaps de la escena
		room.position = get_spawn_position(grid_positions) * room_size
		add_child(room)
		# Almacena la sala por su posición/es en la matriz
		for _position in grid_positions:
			rooms_by_position[_position] = room
		return room
	return null

# Los tilemaps de las salas tienen como origen la sala mas abajo a la derecha, esta funcion obtiene
# dicha casilla entre las posiciones de la matriz dadas
func get_spawn_position(grid_positions: Array) -> Vector2:
	# Inicializar la primera en la lista como la posición más abajo a la izquierda
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

# Obtiene la sala que ocupa una posicion
func get_room_by_position(room_position: Vector2) -> Node2D:
	if rooms_by_position.has(room_position):
		return rooms_by_position[room_position]
	return null

# Obtiene la sala que ocupa una posicion
func get_room_by_type(room_type: String) -> Node2D:
	for _position in rooms_by_position.keys():
		var room_component = get_room_component_by_position(_position)
		if room_component.type_of_room == room_type:
			return rooms_by_position[_position]
	return null  # Si no se encuentra, se retorna null
	
# Obtiene el EoomComponent de una sala que ocupa una posicion
func get_room_component_by_position(room_position: Vector2) -> RoomComponent:
	var room = get_room_by_position(room_position)
	if room:
		return room.get_node("RoomComponent")
	return null

# Obtiene las posiciones que ocupa una sala
func get_room_positions(room: Node2D) -> Array:
	var positions = []
	for _position in rooms_by_position:
		if rooms_by_position[_position] == room:
			positions.append(_position)
	return positions

# Obtiene todas las salas generadas
func get_all_rooms() -> Dictionary:
	return rooms_by_position

# Limpia todas las salas generadas y libera sus instancias
func clear_rooms():
	for room in rooms_by_position.values():
		if room:
			room.queue_free()
	rooms_by_position.clear()

func create_door(cell_position : Vector2, direction : Vector2):
	var room = rooms_by_position.get(cell_position)
	# Dependiendo de la direccion en la que queramos crear la puerta elegimos la posicion mas conveniente
	# en caso de tener una sala adyacente en dicha direccion
	var adjacent_cell_position = cell_position + direction
	# Comprobamos que haya una sala diferente en la posicion adjacente
	var adjacent_room = rooms_by_position.get(adjacent_cell_position)
	if adjacent_room and adjacent_room != room:
		room_factory.create_door(room, cell_position, direction)

#----------------------------------------------------#
# Funciones que solicita directamente al RoomFactory #
#----------------------------------------------------#

func get_room_height_by_type(room_type: String) -> int:
	return room_factory.get_room_height_by_type(room_type)

func get_room_width_by_type(room_type: String) -> int:
	return room_factory.get_room_width_by_type(room_type)

func get_random_room_type() -> String:
	return room_factory.get_random_room_type()
	
func get_random_room_type_with_chances() -> String:
	return room_factory.get_random_room_type_with_chances()
