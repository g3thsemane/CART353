
extends StaticBody3D

var is_removed: bool = false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func use_cube(cube: IdentityCube) -> bool:

	if is_removed:
		return false

	# Record the interaction internally
	cube.register_use("KEY")

	# Remove the obstruction
	is_removed = true
	visible = false
	collision_shape.set_deferred("disabled", true)

	print("Barrier removed by Cube ", cube.cube_id)

	return true
