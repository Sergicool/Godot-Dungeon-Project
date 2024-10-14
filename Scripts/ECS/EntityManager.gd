# EntityManager.gd
extends Node2D
class_name EntityManager

@onready var entity_factory: EntityFactory = $"../EntityFactory"

var entities: Array = []

# Crea una entidad especifica en una posicion
func spawn_entity(entity_type: String, spawn_position: Vector2) -> Node2D:
	# Crea la entidad
	var entity = entity_factory.create_entity(entity_type)
	# Si se crea la entidad
	if entity:
		# Colocamos la entidad en su respectiva posicion
		entity.position = spawn_position
		add_child(entity)
		# La agregamos a la lista de entidades
		entities.append(entity)
		return entity
	return null

# Devuelve la lista de entidades
func get_all_entities() -> Array:
	return entities

# Devuelve la lista de entidades filtradas por tipo
func get_entities_by_type(entity_type: String) -> Array:
	return entities.filter(func(e): return e.name == entity_type)

# Borra todas las entidades
func clear_entities():
	for entity in entities:
		if entity:
			entity.queue_free()
	entities.clear()
