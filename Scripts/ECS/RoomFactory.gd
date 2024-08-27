extends Node2D
class_name RoomFactory

# Alto y ancho de las salas por pixeles/tile * tiles/celda
var CELL_HEIGHT = 16 * 12
var CELL_WIDTH = 16 * 20

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
func get_cell_height() -> int:
	return CELL_HEIGHT

# Obtiene el ancho de una sala
func get_cell_width() -> int:
	return CELL_WIDTH

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
