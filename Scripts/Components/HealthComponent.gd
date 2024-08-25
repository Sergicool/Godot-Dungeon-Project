extends Node2D
class_name HealthComponent

@export var max_health = 0
var health

func _ready():
	health = max_health

func lose_health(ammount : int):
	health -= ammount
	
	if health <= 0:
		get_parent().queue_free()
