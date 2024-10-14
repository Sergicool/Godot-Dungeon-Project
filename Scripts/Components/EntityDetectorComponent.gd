extends Area2D
class_name EntityDetectorComponent

# Este array contendrá todos los cuerpos que actualmente están dentro del área
var cuerpos_en_el_area: Array = []

# Se ejecuta cuando un cuerpo entra en el área
func _on_Area2D_body_entered(body: Node):
	# Agregar el cuerpo al array si no está ya en él
	if body not in cuerpos_en_el_area:
		cuerpos_en_el_area.append(body)
		print("Cuerpo entró:", body.name)

# Se ejecuta cuando un cuerpo sale del área
func _on_Area2D_body_exited(body: Node):
	# Remover el cuerpo del array si estaba en él
	if body in cuerpos_en_el_area:
		cuerpos_en_el_area.erase(body)
		print("Cuerpo salió:", body.name)
		if cuerpos_en_el_area.is_empty():
			print("No queda nadie en la sala")
