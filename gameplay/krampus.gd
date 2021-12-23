extends PathFollow

export(float) var gravity = -9.8
export(float) var jump_velocity = 5
export(float) var track_offset = 1.2

var velocity_up := 0.0
var track := 0

onready var tween := $"Tween"
onready var model_anims := $"ModelAnimations"

func _physics_process(delta):
	velocity_up += gravity * delta
	
	if Input.is_key_pressed(KEY_SPACE):
		_jump()
	if Input.is_action_just_pressed('ui_left'):
		_switch_track(_clamp_track(track + 1))
	if Input.is_action_just_pressed('ui_right'):
		_switch_track(_clamp_track(track - 1))
	
	if v_offset >= 0.0:
		v_offset += velocity_up * delta
	if v_offset < 0.0:
		v_offset = 0.0
		velocity_up = 0.0

func _jump():
	if v_offset > 0.00001:
		return
	
	model_anims.set('parameters/jump/active', true)
	
	velocity_up = jump_velocity

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
	
	tween.stop_all()
	tween.interpolate_property(self, 'h_offset', null, target_offset, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	self.track = track

func _on_collision(area: Area):
	if area.is_in_group('Obstacles'):
		# TODO
		get_tree().reload_current_scene()
		return
	if area.is_in_group('PickupBoxes'):
		area.get_parent().get_parent().queue_free()
		print('Box picked up')
