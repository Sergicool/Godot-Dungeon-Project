extends Camera2D

var dead_zone = 0
var controled_by_player = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and controled_by_player:
		var _target = event.position - get_viewport().size * 0.5
		if _target.length() < dead_zone:
			self.position = Vector2(0,0)
		else:
			self.position = _target.normalized() * (_target.length() -  dead_zone) * 0.1
