
extends RigidBody3D
class_name IdentityCube

# A unique identifier for each cube
@export var cube_id: int = 1

# Records the cube's interactions
var use_history: Array[String] = []


func register_use(action: String) -> void:
	use_history.append(action)

	print(
		"Cube ", cube_id,
		" was used as: ", action
	)


func get_use_history() -> Array[String]:
	return use_history
