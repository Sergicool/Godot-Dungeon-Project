# EntityFactory.gd
extends Node2D
class_name EntityFactory

# Diccionario para mapear el tipo de entidad a la escena correspondiente
var entity_scenes : Dictionary = {
	"player" = preload("res://Scenes/Player/Player.tscn"),
	"slime" = preload("res://Scenes/Enemies/Slime.tscn"),
	"start_room" = preload("res://Scenes/Dungeon/Rooms/StartRoom.tscn")
}

# Crea una entidad del diccionario dada y la devuelve
func create_entity(entity_type : String) -> Node2D:
	if entity_scenes.has(entity_type):
		return entity_scenes[entity_type].instantiate()
	else:
		return null
