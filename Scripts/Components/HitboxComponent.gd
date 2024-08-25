extends Area2D

@export var health_component : HealthComponent

func take_damage(damage: int):
	if health_component:
		health_component.take_damage(damage)
