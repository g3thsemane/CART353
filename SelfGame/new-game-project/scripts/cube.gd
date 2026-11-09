
extends RigidBody3D
class_name IdentityCube

@export var cube_id: int = 1

# History of all interactions
var use_history: Array[String] = []

# Counts of different uses
var use_counts: Dictionary = {
	"KEY": 0,
	"WEAPON": 0,
	"WEIGHT": 0
}


func register_use(action: String) -> void:

	# Only accept recognized interactions
	if not use_counts.has(action):
		return

	# Record the interaction
	use_history.append(action)

	# Increase the corresponding counter
	use_counts[action] += 1

	print("Cube ", cube_id, " used as: ", action)
	print("Current classification: ", get_classification())
	
	

func get_classification() -> String:

	var highest_count: int = 0
	var classification: String = "UNDEFINED"

	for action in use_counts:

		if use_counts[action] > highest_count:
			highest_count = use_counts[action]
			classification = action

	return classification


func get_use_history() -> Array[String]:
	return use_history
