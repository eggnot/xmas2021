tool
extends MultiMeshInstance

export(bool) var generate = false setget generate


func generate(_gen):
	_gen = false
	#var b:Basis = Basis.IDENTITY
	#https://docs.godotengine.org/en/stable/tutorials/3d/vertex_animation/animating_thousands_of_fish.html
	
	multimesh.instance_count = 32
	
	var x := - 25.0
	var z := - 0.0
	
	for i in multimesh.instance_count:
		x = -25.0 if x>25.0 else x
		#var t := Transform().translated(Vector3(x, 0, z)) * Transform().rotated(Vector3.UP, PI/2)
		var t := Transform().translated(Vector3(x, 0, z))
		multimesh.set_instance_transform(i, t)
		x += 50.0; z -= 10.0
