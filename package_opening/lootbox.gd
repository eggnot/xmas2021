extends Spatial

onready var animation_tree: AnimationTree = $"AnimationTree"

func _ready():
	animation_tree.tree_root.set_start_node('Idle')

func _on_press():
	animation_tree.get('parameters/playback').travel('Open')

func _on_area_input(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton \
			and event.pressed:
		_on_press()
