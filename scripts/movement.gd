extends CharacterBody3D

@export var move_speed: float = 6.0
@export var fast_multiplier: float = 2.0
@export var acceleration: float = 8.0
@export var hover_damping: float = 6.0
@export var ascend_speed: float = 5.0
@export var mouse_sensitivity: float = 0.004

var yaw: float = 0.0
var pitch: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Visual/AnimationPlayer.play("fly")
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-60.0), deg_to_rad(60.0))

func _physics_process(delta):
	var dir_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var speed := move_speed
	if Input.is_action_pressed("fly_fast"):
		speed *= fast_multiplier

	var basis := Basis(Vector3.UP, yaw)
	var forward := -basis.z
	var right := basis.x
	var wish_dir := (right * dir_2d.x + forward * dir_2d.y).normalized()

	var horizontal_vel := velocity
	horizontal_vel.y = 0.0
	var target_horizontal := wish_dir * speed
	horizontal_vel = horizontal_vel.lerp(target_horizontal, acceleration * delta)

	var vertical_input := Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	var vertical_vel := velocity.y
	if vertical_input != 0.0:
		vertical_vel = lerp(vertical_vel, vertical_input * ascend_speed, acceleration * delta)
	else:
		vertical_vel = lerp(vertical_vel, 0.0, hover_damping * delta)

	velocity = Vector3(horizontal_vel.x, vertical_vel, horizontal_vel.z)

	rotation.y = yaw
	rotation.x = pitch

	move_and_slide()
