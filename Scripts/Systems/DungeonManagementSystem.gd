extends Node2D

@onready var entity_manager: EntityManager = $EntityManager
@onready var entity_factory: EntityFactory = $EntityFactory
@onready var room_manager: RoomManager = $RoomManager
@onready var room_factory: RoomFactory = $RoomFactory

#---------------------------------------#
# Propiedades de un piso por dificultad #
#---------------------------------------#

# Dificultad facil
var easy_difficulty_floor_properties : Dictionary = {
	"dimensions" : 7,			# Dimensiones del piso
	"min_rooms" : 8,            # Mínimo de salas por piso
	"max_rooms" : 12,           # Máximo de salas por piso
	"interesting_rooms" : 2		# Salas que tienen 3 conexiones o más
}

# Probabilidad en % de generar un camino adicional a una sala
var generation_chance = 20
# Piso actual
var current_floor = 0
# Instancia del jugador
var player = null

func _ready():
	var start_room_position = [Vector2.ZERO]
	# Generar el primer piso
	generate_floor()
	# Conectar salas
	generate_conections()
	# Instanciar el jugador en la sala inicial
	var initial_position = room_manager.get_room_by_type("start_room").position
	player = entity_manager.spawn_entity("player", initial_position)

# Funcion para generar la estructura de un piso completo
func generate_floor():
	# Obtenemos propiedades del piso
	var floor_properties = get_floor_properties()
	var dimensions = floor_properties["dimensions"]
	var min_rooms = floor_properties["min_rooms"]
	var max_rooms = floor_properties["max_rooms"]
	# Elegimos un numero de salas a generar
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
	# Contador de salas generadas
	var generated_rooms = 1
	# Intentos de generacion para evitar bucles infinitos
	var generation_tries = 0
	# Generamos el resto de salas del piso hasta generar todas o agotar los intentos
	while generated_rooms < num_rooms or generation_tries > 100:
		# Obtenemos posibles posiciones para generar nuevas salas
		var potential_positions = room_manager.get_potential_positions()
		# Seleccionamos una posicion
		var selected_position = potential_positions[randi() % potential_positions.size()]
		# Elegimos un tipo de sala para generar (Con pobabilidad)
		var room_type = room_manager.get_random_room_type_with_chances()
		# Vemos en que posicion se podria colocar la sala y devolvemos las casillas que ocupara
		var new_occupied_positions = get_space_for_room_in_position(room_type, grid, selected_position)
		# Si hay nuevas posiciones a ocupar significa que la sala se puede crear
		if new_occupied_positions != []:
			# Creamos e instanciamos la sala
			var room = room_manager.spawn_room(room_type, new_occupied_positions)
			# Actualizamos el grid con la poisicion de la sala
			place_room_in_grid(room, grid)
			# Una sala generada con exito
			generated_rooms += 1
		# Un intento de generacion
		generation_tries += 1
	# Se ha creado el piso perfectamente
	current_floor += 1

# Obtiene las propiedades para el piso actual
func get_floor_properties() -> Dictionary:
	if (current_floor >= 10):
		pass # Aqui se puede implementar mas dificultades
	return easy_difficulty_floor_properties

# Obtiene las casillas que va a ocupar un tipo de sala en una determinada posicion
func get_space_for_room_in_position(room_type : String, grid : Array, selected_position : Vector2) -> Array:
	# Posiciones que ocupara la sala
	var positions_for_room = []
	# Pòsiciones ya ocupadas
	var occupied_positions = room_manager.get_occupied_positions()
	# Dimensiones de la sala a colocar
	var height = room_manager.get_room_height_by_type(room_type)
	var width = room_manager.get_room_width_by_type(room_type)
	# Lista que guardara las casillas a partir de la que se generara la sala, siendo estas 
	# elegidas a partir de la posicion seleccionada, en un radio de las dimensiones de la sala
	var initial_positions = []
	var pos
	# Obtener las casillas libres de un a área en base a selected_position para probar posiciones de generacion
	for x in range(selected_position.x - width + 1, selected_position.x + width):
		for y in range(selected_position.y - height + 1, selected_position.y + height):
			pos = Vector2(x, y)
			# Verificar si la posicion no esta ocupada
			if pos not in occupied_positions:
				# Verificar si la posición está dentro de los límites del grid
				if position_is_in_range_of_grid(pos, grid):
					initial_positions.append(pos)
	# Posicion seleccionada en la que se probara a generar la sala, si alguna dimension es mayor a 1, la sala
	# se generara a partir de esa casilla (inicial) extendiendose hacia abajo y a la derecha
	var selected_initial_position
	var valid_position = true
	while initial_positions.size() != 0:
		# Seleccionar una posición inicial al azar
		selected_initial_position = initial_positions[randi() % initial_positions.size()]
		valid_position = true
		# Comprobar si la posición seleccionada y el área hacia el que se extiende las dimensiones de la sala
		# no abarcan ningun espacio ocupado
		for x in range(selected_initial_position.x, selected_initial_position.x + width):
			for y in range(selected_initial_position.y, selected_initial_position.y + height):
				pos = Vector2(x, y)
				if pos in occupied_positions or not position_is_in_range_of_grid(pos, grid):
					# Si en una posicion hay una sala o se sale de los limites se descarta esa generacion
					valid_position = false
					break  # Rompe el bucle interno si una posición es inválida
				else:
					# Guardamos la posicion que va a ocupar la sala en caso de exito
					positions_for_room.append(pos)
		# Si la posición es válida, salimos del while
		if valid_position and positions_for_room.has(selected_position):
			break
		else:
			# Si no es válida, eliminamos la posición seleccionada de initial_positions y continuamos con otra
			initial_positions.erase(selected_initial_position)
			# Descartamos las posiciones de las salas elegidas
			positions_for_room.clear()
	# En caso de exito devolver las posiciones para la sala a partir de la posicion inicial, 
	# de lo contrario ninguna
	return positions_for_room

# Comprobacion para saber si una posicion esta dentro del rango de una grid (para evitar repetitividad molesta)
func position_is_in_range_of_grid(_position : Vector2, grid : Array):
	if _position.x >= 0 and _position.y >= 0 and _position.x < grid.size() and _position.y < grid[0].size():
		return true
	return false

# Coloca una sala en el grid
func place_room_in_grid(room : Node2D, grid: Array):
	# Obtenemos las posiciones que ocupara la sala en el grid
	var room_positions = room_manager.get_room_positions(room)
	# Asignamos las posiciones a la sala
	for room_position in room_positions:
		var grid_x = room_position.x
		var grid_y = room_position.y
		grid[grid_y][grid_x] = room

func generate_conections():
	var rooms_by_position = room_manager.get_all_rooms()
	# Por cada posicion que ocupa una sala
	for cell_position in rooms_by_position:
		print("---",cell_position,"---")
		# Obtenemos la sala que ocupa dicha posicion
		room_manager.create_door(cell_position, Vector2.UP)
		room_manager.create_door(cell_position, Vector2.DOWN)
		room_manager.create_door(cell_position, Vector2.LEFT)
		room_manager.create_door(cell_position, Vector2.RIGHT)

# Imprime el estado actual del grid en la consola (Para depurar)
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
