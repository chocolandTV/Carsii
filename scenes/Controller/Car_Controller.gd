extends VehicleBody3D
enum Gamestate {
	FLYMODE,
	RACEMODE
}
var current_game_state : Gamestate = Gamestate.RACEMODE
var is_Jumping: bool = false
var is_Boosting: bool = false
var is_rolling : bool = false
var current_boost : float = 1
var current_steering : float = 25.0
var boost_amount : int = 100
const JUMPOWER : float = 6.0
const BOOSTPOWER : float = 1.5
const MAX_STEERING :float = 25.0
const MAX_STEERING_HANDBRAKE :float = 50.0
const ENGINE_POWER : float = 5000
const BRAKE_POWER : float = 5000
const ROLL_SPEED: float = 20.0
const PITCH_SPEED: float  = 8.0
const ANGULAR_VELOCITY_DECAY : float = 0.96
const YAW_SPEED = 8.0

var move_direction : Vector2  =Vector2.ZERO
@export var friction_slip : Vector2 = Vector2 (0.02,0.845)
@export var wheel_rear_left : VehicleWheel3D
@export var wheel_rear_right : VehicleWheel3D
@export var light_brake_left : OmniLight3D
@export var light_brake_right : OmniLight3D
var current_jumps = 0
const MAX_JUMPS : int = 2
func _input(_event):
	move_direction = Input.get_vector("move_right", "move_left","brake", "accellerate")
	################ JUMP
	if _event.is_action_pressed("jump"):
		is_Jumping =true
	if _event.is_action_released("jump"):
		is_Jumping =false
	#################### ROLL
	if _event.is_action_pressed("roll"):
		is_rolling =true
	if _event.is_action_released("roll"):
		is_rolling =false
	################### BOOST 
	if _event.is_action_pressed("boost"):
		is_Boosting =true
		current_boost = BOOSTPOWER
	if _event.is_action_released("boost"):
		is_Boosting =false
		current_boost = 1
	############################ HANDBRAKE
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
	if current_game_state == Gamestate.FLYMODE:
		handle_flying()

func handle_Acceleration():
	engine_force = move_direction.y *ENGINE_POWER *current_boost
	brake = move_direction.y  * BRAKE_POWER
	if brake > 5:
		light_brake_left.light_energy = 6
		light_brake_right.light_energy = 6
	if brake < 5:
		light_brake_left.light_energy = 1
		light_brake_right.light_energy = 1
func handle_Steering():
	steering = deg_to_rad(move_direction.x * current_steering)
func handle_Jump():
	if(is_Jumping and current_jumps < MAX_JUMPS):
		#reset on ground
		current_game_state = Gamestate.FLYMODE
		current_jumps += 1
		linear_velocity += Vector3.UP * JUMPOWER
		global_rotation = Vector3.ZERO
	if linear_velocity.y <1:
		current_jumps = 0
		current_game_state = Gamestate.RACEMODE

func handle_flying():
	add_constant_torque(Vector3.RIGHT * PITCH_SPEED * move_direction.y)

	if(is_rolling):
		add_constant_torque(Vector3.FORWARD * ROLL_SPEED * -move_direction.x)
	else:
		add_constant_torque(Vector3.UP * YAW_SPEED * move_direction.x)

	angular_velocity *= ANGULAR_VELOCITY_DECAY
