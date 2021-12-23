tool
extends MultiMeshInstance

export(bool) var generate = false setget generate


func generate(_gen):
	_gen = false
	#var b:Basis = Basis.IDENTITY
	#https://docs.godotengine.org/en/stable/tutorials/3d/vertex_animation/animating_thousands_of_fish.html
	
	multimesh.instance_count = 24
	
	var x := - 3.0
	var z := - 0.0
	
	for i in multimesh.instance_count:
		x = -3.0 if x>3.0 else x
		var t := Transform()\
				 .scaled(Vector3(1, randi()%10, 1))\
				 .translated(Vector3(x, 0, z))
		
		multimesh.set_instance_transform(i, t)
		x += 6.0; z -= rand_range(4, 12)
