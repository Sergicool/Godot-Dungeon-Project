extends Node2D

@onready var entity_manager: EntityManager = $EntityManager
@onready var entity_factory: EntityFactory = $EntityFactory
@onready var room_manager: RoomManager = $RoomManager
@onready var room_factory: RoomFactory = $RoomFactory

var easy_difficulty_floor_properties : Dictionary = {
	"dimensions" : 7,			# Dimensiones del piso
	"min_rooms" : 8,            # Mínimo de salas por piso
	"max_rooms" : 12,           # Máximo de salas por piso
	"interesting_rooms" : 2		# Salas que tienen 3 conexiones o más
}

var generation_chance = 20		# Probabilidad en % de generar un camino adicional a una sala
var current_floor = 0

var player = null

func _ready():
	# Generar el primer piso
	generate_floor()
	# Instanciar el jugador en la sala inicial
	player = entity_manager.spawn_entity("player", Vector2.ZERO)

func generate_floor():
	# Obtenemos propiedades del piso
	var floor_properties = get_floor_properties()
	var dimensions = floor_properties["dimensions"]
	var min_rooms = floor_properties["min_rooms"]
	var max_rooms = floor_properties["max_rooms"]
	
	var num_rooms = randi_range(min_rooms, max_rooms)
	# Inicializar la matriz de salas vacía
	var grid = []
	for i in range(dimensions):
		var row = []
		for j in range(dimensions):
			row.append(null)
		grid.append(row)	
	
	# Calculamos la posición de la sala inicial y el número de salas que va a tener el piso
	var start_room_position = [Vector2(floor(dimensions / 2), floor(dimensions / 2))]
	# Generamos la sala inicial
	var start_room = room_manager.spawn_room("start_room", start_room_position)
	# Ocupamos el grid con la sala inicial
	place_room_in_grid(start_room, grid)
	var generated_rooms = 1
	var generation_tries = 0
	# Generamos el resto de salas del piso
	while generated_rooms < num_rooms or generation_tries > 100:
		# Obtenemos posibles posiciones para generar la sala
		var potential_positions = room_manager.get_potential_positions()
		# Seleccionamos una posicion
		var selected_position = potential_positions[randi() % potential_positions.size()]
		# Selecciona un tipo de sala
		var room_type = room_manager.get_random_room_type_with_chances()
		# Vemos en que posicion se podria colocar la sala y devolvemos las casillas que ocupara
		var new_occupied_positions = get_space_for_room_in_position(room_type, grid, selected_position)
			
		if new_occupied_positions != []:
			var room = room_manager.spawn_room(room_type, new_occupied_positions)
			# Actualizamos el grid con la poisicion de la sala
			place_room_in_grid(room, grid)
			# Una sala generada con exito
			generated_rooms += 1
		else:
			print("Error: No se pudo instanciar la sala en la posición ", selected_position)
		generation_tries += 1
		
	current_floor += 1

# Obtiene las propiedades del piso actual
func get_floor_properties() -> Dictionary:
	if (current_floor >= 10):
		pass # Aqui se puede implementar mas dificultades
	return easy_difficulty_floor_properties

func get_space_for_room_in_position(room_type : String, grid : Array, selected_position : Vector2) -> Array:
	# Posiciones que ocupara la sala
	var positions_for_room = []
	# Pòsiciones ya ocupadas
	var occupied_positions = room_manager.get_occupied_positions()
	# Dimensiones de la sala a colocar
	var height = room_manager.get_room_height_by_type(room_type)
	var width = room_manager.get_room_width_by_type(room_type)
	# Crear lista para almacenar las posiciones iniciales de la sala en la posicion seleccionada dadas sus dimensiones
	# Para que las salas mayores a una 1x1 poder colocarlas de mas de una manera en la posicion seleccionada
	var initial_positions = []
	var pos
	# Calcular los límites del área en base a selected_position
	for x in range(selected_position.x - width + 1, selected_position.x + width):
		for y in range(selected_position.y - height + 1, selected_position.y + height):
			pos = Vector2(x, y)
			# Verificar si la posicion no esta ocupada
			if pos not in occupied_positions:
				# Verificar si la posición está dentro de los límites del grid
				if position_is_in_range_of_grid(pos, grid):
					initial_positions.append(pos)

	var selected_initial_position
	var valid_position = true
	while initial_positions.size() != 0:
		# Seleccionar una posición inicial al azar
		selected_initial_position = initial_positions[randi() % initial_positions.size()]
		valid_position = true
		# Comprobar si la posición seleccionada y el área que ocupa la sala son válidas
		for x in range(selected_initial_position.x, selected_initial_position.x + width):
			for y in range(selected_initial_position.y, selected_initial_position.y + height):
				pos = Vector2(x, y)
				if pos in occupied_positions or not position_is_in_range_of_grid(pos, grid):
					valid_position = false
					break  # Rompe el bucle interno si una posición es inválida
				else:
					# Guardamos la posicion que va a ocupar la sala en caso de exito
					positions_for_room.append(pos)
		# Si la posición es válida, salimos del while
		if valid_position and positions_for_room.has(selected_position):
			break
		else:
			# Si no es válida, eliminamos la posición seleccionada de initial_positions y continuamos
			initial_positions.erase(selected_initial_position)
			# Descartamos las posiciones de las salas elegidas
			positions_for_room.clear()
	# En caso de exito devolver las posiciones para la sala a partir de la posicion inicial, de lo contrario ninguna
	return positions_for_room

func position_is_in_range_of_grid(_position : Vector2, grid : Array):
	if _position.x >= 0 and _position.y >= 0 and _position.x < grid.size() and _position.y < grid[0].size():
		return true
	return false
# Coloca una sala en el grid
func place_room_in_grid(room : Node2D, grid: Array):
	# Obtenemos las posiciones que ocupa la sala en el grid
	var room_positions = room_manager.get_room_positions(room)
	# Asignamos las posiciones a la sala
	for room_position in room_positions:
		var grid_x = room_position.x
		var grid_y = room_position.y
		grid[grid_y][grid_x] = room

# Imprime el estado actual del grid en la consola
func print_grid(grid: Array) -> void:
	var grid_output = ""
	for y in range(grid.size()):
		var row_output = ""
		for x in range(grid[y].size()):
			if grid[y][x] != null:
				row_output += "S " # Representa una celda ocupada por una sala
			else:
				row_output += ". " # Representa una celda libre
		grid_output += row_output + "\n"
	print(grid_output)
