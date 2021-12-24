extends PathFollow

export(float) var gravity = -9.8
export(float) var jump_velocity = 5
export(float) var track_offset = 1.2

var velocity_up := 0.0
var track := 0
var controllable := true

onready var tween := $"Tween"
onready var model_anims := $"ModelAnimations"
onready var move_anim := $"MoveAnimation"
onready var sounds := $"../../Sounds"
onready var death_timer := $"../../DeathTimer"

func _physics_process(delta):
	velocity_up += gravity * delta
	
	if controllable:
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
	
	tween.stop_all()
	tween.interpolate_property(self, 'h_offset', null, target_offset, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	self.track = track
	
	sounds.get_node("Whoosh").play()

func _on_collision(area: Area):
	if area.is_in_group('Obstacles'):
		# TODO
		_lose()
		return
	if area.is_in_group('PickupBoxes'):
		area.get_parent().get_parent().queue_free()
		print('Box picked up')
		sounds.get_node('Pickup').play()

func _lose():
	controllable = false
	model_anims.set('parameters/die/active', true)
	move_anim.stop()
	death_timer.start()
	
	sounds.get_node('Lose').play()
	
	var theme = sounds.get_node("Theme")
	var tween = sounds.get_node("Theme/Tween")
	tween.interpolate_property(theme, "volume_db", theme.volume_db, -24, 2.0)
	tween.start()

func _on_DeathTimer_timeout():
	get_tree().reload_current_scene()
