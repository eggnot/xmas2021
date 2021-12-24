extends PathFollow

export(float) var gravity = -9.8
export(float) var jump_velocity = 5
export(float) var track_offset = 1.2

var velocity_up := 0.0
var track := 0
var controllable := true

var drag :bool= false
var swipe_vector :Vector2 = Vector2.ZERO

#var backpack:BoneAttachment
#var last_box:MeshInstance
onready var jp := $KramJump
onready var turns := $KramJump/turns
onready var model_anims := $KramJump/model_animations
onready var backpack := $KramJump/model/Armature/Skeleton/backpack
onready var last_box := backpack.get_node("box")
onready var sounds := $"../../Sounds"

var msec_jump_start := 0
var msec_jump_ended := 0

var on_platform := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	velocity_up += gravity * delta
	
	if controllable:
		if Input.is_action_just_pressed("ui_accept"):
			_jump()
		if Input.is_action_just_pressed('ui_left'):
			_switch_track(_clamp_track(track + 1))
		if Input.is_action_just_pressed('ui_right'):
			_switch_track(_clamp_track(track - 1))
	
	#!!!
		
		if jp.translation.y < 0.0:
			jp.translation.y = 0.0
			velocity_up = 0.0
		#		if OS.is_debug_build():
		#			print("jump ", OS.get_ticks_msec()-msec_jump_start, "ms")
		elif jp.translation.y > 0.0 and not on_platform:
			jp.translation.y += velocity_up * delta

		var new_x = clamp(jp.translation.x, -0.75, 0.75)
		$Camera.translation.x = lerp($Camera.translation.x, new_x, .05)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		drag = event.pressed
		if drag:
			$swipe.start()
		else:
			if not $swipe.is_stopped(): # tap
				pass #jump
	
	if drag and event is InputEventMouseMotion:
		if $swipe.is_stopped():
			if swipe_vector.length_squared() < 100:
				return
			var swn := swipe_vector.normalized()
			if swn.y < -0.7:
				pass #jump
			elif swn.x > 0.7:
				pass #turn_right
			elif swn.x < 0.7:
				pass #turn_left
			drag = false
			swipe_vector = Vector2.ZERO
		else:
			swipe_vector += event.relative
		
	
	if event.is_action_pressed("ui_left"):
		pass #turn_left
	elif event.is_action_pressed("ui_right"):
		pass #turn_right
		
	elif event.is_action_pressed("ui_page_up"):
		$move_and_play.stop(false)
		$move_and_play.play("run1")
	elif event.is_action_pressed("ui_page_down"):
		$move_and_play.stop(false)
		$move_and_play.play_backwards("run1")
		
	elif event.is_action_pressed("ui_end"):
		$move_and_play.stop(false)
		
	elif event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	
	elif event.is_action_pressed("ui_home"):
		if model_anims["parameters/movement/blend_position"] > 0.5:
			model_anims["parameters/movement/blend_position"] = 0.0
		else:
			model_anims["parameters/movement/blend_position"] = 1.0
	
	#translation.x = clamp(translation.x, -1.2, 1.2)


func add_one_box():
	var new_box = last_box.duplicate()
	new_box.translation.y += 0.22 * 100 #armature scale is 0.01
	backpack.add_child(new_box)
	last_box = new_box
	
func _jump():
	if jp.translation.y > 0.00001 and not on_platform:
		return #in air
	
	while model_anims['parameters/jump/active']:
		yield(get_tree().create_timer(.02), "timeout")
		
	msec_jump_start = OS.get_ticks_msec()
	model_anims.set('parameters/jump/active', true)

	if on_platform:
		#NOT WORKING NOW
		velocity_up = jump_velocity/3
	else:
		velocity_up = jump_velocity
		jp.translation.y = 0.00001
		
	sounds.get_node("Jump").play()

func _clamp_track(track: int) -> int:
	if track <= -1:
		return -1
	elif track >= 1:
		return 1
	else:
		return track

func _switch_track(track: int):
	if self.track == track:
		return
	
	assert(-1 <= track and track <= 1)
	
	var target_offset = track_offset * track
	$tween.stop_all()
	$tween.interpolate_property(jp, 'translation:x',\
		null, target_offset, 0.35, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$tween.start()
	
	if track < self.track:
		turns.play("turn_left")
	else:
		turns.play("turn_right")
	
	self.track = track
	
	sounds.get_node("Whoosh").play()

func _on_collision(area: Area):
	#var parent = area.get_parent()

	if area.is_in_group('Platform'):
		on_platform = true
	elif area.is_in_group('Obstacles'):
		area.get_parent().queue_free()
		_lose()
	elif area.is_in_group('Finish'):
		area.get_parent().queue_free()
		_win()
	elif area.is_in_group('PickupBoxes'):
		add_one_box()
		area.get_parent().queue_free()
#		print('PickupBox')
	

		sounds.get_node('Pickup').play()

func _on_collision_exited(area):
	if area.is_in_group('Platform'):
#		print('platform exit')
		on_platform = false

func _win():
	controllable = false
	$move_and_play.stop()
	model_anims['parameters/states/current'] = 2 # 2 is for wave!
	turns.play("cam_zoom")
	yield(turns, "animation_finished")
	
	#GO TO WIN SCENE
	get_tree().change_scene("res://package_opening/lootbox.tscn")
	
func _lose():
	controllable = false
	$move_and_play.stop()
	model_anims['parameters/states/current'] = 1 # 1 is dead!
	turns.play("cam_zoom")
	
	yield(turns, "animation_finished")
	get_tree().reload_current_scene()
	
	#death_timer.start()
	
	sounds.get_node('Lose').play()
	
	#var theme = sounds.get_node("Theme")
	#var tween = sounds.get_node("Theme/Tween")
	#tween.interpolate_property(theme, "volume_db", theme.volume_db, -24, 2.0)
	#tween.start()

func _on_DeathTimer_timeout():
	get_tree().reload_current_scene()
