extends VehicleBody3D

var isJumping: bool = false
var isBoosting: bool = false

var current_steering : float = 25
var boost_amount : int = 100
const JUMPOWER : float = 0.3
const BOOSTPOWER : float = 1.1
const MAX_STEERING :float = 25
const MAX_STEERING_HANDBRAKE :float = 50
const ENGINE_POWER : float = 5000
const BRAKE_POWER : float = 2500
var move_direction : Vector2  =Vector2.ZERO
@export var slip_speed = 9.0
@export var friction_slip : Vector2 = Vector2 (0.02,0.845)
@export var wheel_rear_left : VehicleWheel3D
@export var wheel_rear_right : VehicleWheel3D

var drifting = false

func _input(_event):
	move_direction = Input.get_vector("move_right", "move_left","brake", "accellerate")
	if _event.is_action_pressed("jump"):
		isJumping =true
	if _event.is_action_released("jump"):
		isJumping =false
	if _event.is_action_pressed("boost"):
		isBoosting =true
	if _event.is_action_released("boost"):
		isBoosting =false
	if _event.is_action_pressed("handbrake"):
		current_steering = MAX_STEERING_HANDBRAKE
		wheel_rear_left.wheel_friction_slip = friction_slip.x
		wheel_rear_right.wheel_friction_slip = friction_slip.x
		wheel_rear_right.engine_force = 700* move_direction.y
		wheel_rear_left.engine_force = 700* move_direction.y
	if _event.is_action_released("handbrake"):
		current_steering = MAX_STEERING
		wheel_rear_left.wheel_friction_slip = friction_slip.y
		wheel_rear_right.wheel_friction_slip = friction_slip.y

func _physics_process(_delta):
	handle_Acceleration()
	handle_Steering()
	handle_Jump()
	handle_Boost()
	handle_drift()


func handle_Acceleration():
	engine_force = move_direction.y *ENGINE_POWER
	brake = move_direction.y  * BRAKE_POWER
func handle_Steering():
	steering = deg_to_rad(move_direction.x * current_steering)
func handle_Jump():
	if(isJumping):
		global_position += Vector3.UP * JUMPOWER
		global_rotation = Vector3.ZERO

func handle_Boost():
	if (isBoosting):
		engine_force = move_direction.y * BOOSTPOWER

func handle_drift():
	pass
	# # traction
	# if not drifting and angular_velocity.length() > slip_speed:
	# 	drifting = true
	# if drifting and angular_velocity.length() < slip_speed and steering == 0:
	# 	drifting = false
	# var traction = traction_fast if drifting else traction_slow
	# angular_velocity = lerp(angular_velocity, angular_velocity.length(), traction)