extends Camera3D

@export var car : VehicleBody3D= null
@export var target_distance :float  = 3.0
@export var target_height : float  =3.0
var follow_this = null
var last_lookat
func _ready():
	follow_this = car
	print(follow_this.global_transform.origin)
	last_lookat = follow_this.global_transform.origin

func _physics_process(delta):
	followTargetPos(delta)

func followTargetPos(_delta):
	var delta_v = global_transform.origin - follow_this.global_transform.origin
	var target_pos = global_transform.origin

	delta_v.y = 0.0
	if(delta_v.length() > target_distance):
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_pos = follow_this.global_transform.origin + delta_v
	else:
		target_pos.y  = follow_this.global_transform.origin.y + target_height
	global_transform.origin = global_transform.origin.lerp(target_pos, _delta * 20.0)
	last_lookat = last_lookat.lerp(follow_this.global_transform.origin, _delta * 20.0)
	look_at(last_lookat, Vector3(0.0,1,0))
