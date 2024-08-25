# PlayerMovementSystem.gd
extends CharacterBody2D
class_name PlayerMovementSystem

@onready var velocity_component = $VelocityComponent
@onready var animated_sprite_2d = $AnimatedSprite2D

var direction = "down"

func _physics_process(_delta):
	process_movement()
	updateAnimation()

func process_movement():
	var movement_direction = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	velocity = movement_direction * velocity_component.velocity
	move_and_slide()

func updateAnimation():
	var animation_prefix = "idle"
	var movement_direction = velocity.normalized()

	if movement_direction != Vector2.ZERO:
		animation_prefix = "walk"
		
		if movement_direction.y > 0:
			direction = "down"
		elif movement_direction.y < 0:
			direction = "up"
		elif movement_direction.x < 0:
			direction = "left"
		elif movement_direction.x > 0:
			direction = "right"

	animated_sprite_2d.play(animation_prefix + "_" + direction)
