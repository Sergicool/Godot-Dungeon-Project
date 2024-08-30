extends Node2D
class_name RoomFactory

# Alto y ancho de las salas por pixeles/tile * tiles/celda
var CELL_HEIGHT = 16
var CELL_WIDTH = 16
var ROOM_CELL_HEIGHT = 12
var ROOM_CELL_WIDTH = 20
var ROOM_HEIGHT = CELL_HEIGHT * ROOM_CELL_HEIGHT
var ROOM_WIDTH = CELL_WIDTH * ROOM_CELL_WIDTH

var horizontal_door = preload("res://Scenes/Dungeon/Doors/HorizontalDoor.tscn")
var vertical_door = preload("res://Scenes/Dungeon/Doors/VerticalDoor.tscn")

# Diccionario con salas las cuales pueden tener varias instancias por piso
var rooms: Dictionary = {
	"easy_room_1_1x1": preload("res://Scenes/Dungeon/Rooms/Easy Rooms/EasyRoom_1_1x1.tscn"),
	"easy_room_2_2x1": preload("res://Scenes/Dungeon/Rooms/Easy Rooms/EasyRoom_1_2x1.tscn"),
	"easy_room_2_2x2": preload("res://Scenes/Dungeon/Rooms/Easy Rooms/EasyRoom_1_2x2.tscn")
}

# Diccionario con salas las cuales solo tendran una instancia por piso
var unique_rooms: Dictionary = {
	"start_room": preload("res://Scenes/Dungeon/Rooms/StartRoom.tscn")
}

# Obtiene el alto de una sala
func get_room_height() -> int:
	return ROOM_HEIGHT

# Obtiene el ancho de una sala
func get_room_width() -> int:
	return ROOM_WIDTH

# Obtiene el alto de un tipo de sala
func get_room_height_by_type(room_type: String) -> int:
	var height
	var room = create_room(room_type)
	if room:
		height = room.get_node("RoomComponent").height
		room.queue_free()
	else:
		height = 0
	return height

# Obtiene el ancho de un tipo de sala
func get_room_width_by_type(room_type: String) -> int:
	var width
	var room = create_room(room_type)
	if room:
		width = room.get_node("RoomComponent").width
		room.queue_free()
	else:
		width = 0
	return width
	
# Obtiene un tipo de sala al azar
func get_random_room_type() -> String: # Se puede modificar para que de las salas de dificultad/es especifica/s
	var room_types = rooms.keys()
	return room_types[randi() % room_types.size()]
	
# Obtiene un tipo de sala al azar para la generacion del mapa
func get_random_room_type_with_chances() -> String: # Se puede modificar para que de las salas de dificultad/es especifica/s
	var room
	var room_component
	var room_type = ""
	var chosen = false
	# Elegimos salas al azar hasta cumplir una probabilidad de generacion	
	while not chosen:
		# Crear la instancia de la sala
		room = create_room(get_random_room_type())
		room_component = room.get_node("RoomComponent")
		# Verificar si la generación tiene éxito
		if randi() % 100 < room_component.generation_chance:
			room_type = room_component.type_of_room
			chosen = true
		# Liberar la instancia de la sala
		room.queue_free()
	return room_type
	
# Crea la instancia de un tipo de sala
func create_room(room_type: String) -> Node2D:
	var room = null
	if unique_rooms.has(room_type):
		room = unique_rooms[room_type].instantiate()
	elif rooms.has(room_type):
		room = rooms[room_type].instantiate()
	# Guardamos el tipo de sala en su RoomComponent
	if room:
		room.get_node("RoomComponent").type_of_room = room_type
		return room
	return null
	
func create_door(room : TileMap, cell_position : Vector2, direction : Vector2):
	var door_position
	var door_positions
	var room_position = room.position / Vector2(ROOM_WIDTH, ROOM_HEIGHT)
	# Calculamos el offset para la posicion de la puerta en caso de ser una sala mayor a una 1x1
	var door_position_offset = (cell_position - room_position) * Vector2(ROOM_CELL_WIDTH, ROOM_CELL_HEIGHT)
	# Si la direccion es vertical
	if direction == Vector2.UP or direction == Vector2.DOWN:
		# Posicion del borde superior de la sala
		if direction == Vector2.UP:
			door_position = direction * Vector2(0, ROOM_HEIGHT/CELL_HEIGHT/2)
		# Posicion del borde inferior de la sala
		if direction == Vector2.DOWN:
			door_position = direction * Vector2(0, ROOM_HEIGHT/CELL_HEIGHT/2 - 1)
		# Le sumamos el offset
		door_position += door_position_offset
		# Casillas que hay que modificar para hacer espacio a la puerta de arriba a abajo
		door_positions = [
			door_position + Vector2.LEFT * 3,
			door_position + Vector2.LEFT * 2,
			door_position + Vector2.LEFT,
			door_position,
			door_position + Vector2.RIGHT,
			door_position + Vector2.RIGHT * 2
		]
		# Reemplazamos las casillas para crear una conexion entre salas
		for position_in_cell in door_positions:
			# Borramos la celda
			room.erase_cell(0, position_in_cell)
			# Colocar borde izquierdo
			if position_in_cell == door_positions[0]:
				if direction == Vector2.UP:
					room.set_cell(0, position_in_cell, 0, Vector2i(5, 11))
				else:
					room.set_cell(0, position_in_cell, 0, Vector2i(5, 10))
			# Colocar borde derecho
			elif position_in_cell == door_positions[door_positions.size() - 1]:
				if direction == Vector2.UP:
					room.set_cell(0, position_in_cell, 0, Vector2i(4, 11))
				else:
					room.set_cell(0, position_in_cell, 0, Vector2i(4, 10))
			# Colocar casilla intermedia
			else:
				room.set_cell(0, position_in_cell, 0, Vector2i(1, 5))
	# Si la direccion es horizontal		
	elif direction == Vector2.LEFT or direction == Vector2.RIGHT:
		# Posicion del borde izquierdo
		if direction == Vector2.LEFT:
			door_position = direction * Vector2(ROOM_WIDTH/CELL_WIDTH/2, 0)
		# Posicion del borde derecha
		if direction == Vector2.RIGHT:
			door_position = direction * Vector2(ROOM_WIDTH/CELL_WIDTH/2 - 1, 0)
		# Le sumamos el offset
		door_position += door_position_offset
		# Casillas que hay que modificar para hacer espacio a la puerta de la izquierda o derecha
		door_positions = [
			door_position + Vector2.UP * 3,
			door_position + Vector2.UP * 2,
			door_position + Vector2.UP,
			door_position,
			door_position + Vector2.DOWN,
			door_position + Vector2.DOWN * 2
		]
		# Reemplazamos las casillas para crear una conexion entre salas
		for position_in_cell in door_positions:
			# Borramos la celda
			room.erase_cell(0, position_in_cell)
			# Colocar borde superior
			if position_in_cell == door_positions[0]:
				if direction == Vector2.LEFT:
					room.set_cell(0, position_in_cell, 0, Vector2i(5, 11))
				else:
					room.set_cell(0, position_in_cell, 0, Vector2i(4, 11))
			# Colocar borde inferior
			elif position_in_cell == door_positions[door_positions.size() - 1]:
				if direction == Vector2.LEFT:
					room.set_cell(0, position_in_cell, 0, Vector2i(5, 10))
				else:
					room.set_cell(0, position_in_cell, 0, Vector2i(4, 10))
			# Colocar casilla intermedia
			else:
				room.set_cell(0, position_in_cell, 0, Vector2i(1, 5))
				
func spawn_door(direction : Vector2):
	pass
