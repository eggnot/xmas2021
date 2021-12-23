extends KinematicBody

export(float) var delta_speed = 0.1

var drag :bool= false
var swipe_vector :Vector2 = Vector2.ZERO

var backpack:BoneAttachment
var last_box:MeshInstance


# Called when the node enters the scene tree for the first time.
func _ready():
	backpack = $model/Armature/Skeleton/backpack
	last_box = backpack.get_node("box")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_pressed("ui_right"):
#		$jump.play("turn_right")
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		drag = event.pressed
		if drag:
			$swipe.start()
		else:
			if not $swipe.is_stopped(): # tap
				$jump.play("jump")
	
	if drag and event is InputEventMouseMotion:
		if $swipe.is_stopped():
			if swipe_vector.length_squared() < 100:
				return
			var swn := swipe_vector.normalized()
			if swn.y < -0.7:
				$jump.play("jump")
			elif swn.x > 0.7:
				$jump.play("turn_right")
			elif swn.x < 0.7:
				$jump.play("turn_left")
			drag = false
			swipe_vector = Vector2.ZERO
		else:
			swipe_vector += event.relative
		
	
	if event.is_action_pressed("ui_left"):
		#strafe_x(-1.2)
		$jump.play("turn_left")
	elif event.is_action_pressed("ui_right"):
		#strafe_x(+1.2)
		$jump.play("turn_right")
		
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_accept"):
		$jump.play("jump")
	elif event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	
	#translation.x = clamp(translation.x, -1.2, 1.2)


func _on_box_detector_area_entered(area:Area):
	if area.is_in_group("boxes"):
		add_one_box()
		area.queue_free()
	elif area.is_in_group("obstacles"):
		get_tree().reload_current_scene()

func add_one_box():
	var new_box = last_box.duplicate()
	new_box.translation.y += 0.22 * 100 #armature scale is 0.01
	backpack.add_child(new_box)
	last_box = new_box
	
func strafe_x(x:float, t:float=0.2):
	$Tween.interpolate_property(self, 'translation:x',
	 translation.x, translation.x+x, t, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
