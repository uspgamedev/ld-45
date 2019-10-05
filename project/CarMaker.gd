extends Node

enum States {CHASSIS, CHASSIS_DECO, LEFT_WHEEL, RIGHT_WHEEL, PROJECTILE, DONE}

const STATES_NAME = ["Chassis", "Chassis Decoration", "Left Wheel", "Right Wheel", "Projectile", "Done"]

var convex_hull : PoolVector2Array
var left_wheel_hull : PoolVector2Array
var left_wheel_line : Line2D
var right_wheel_hull : PoolVector2Array
var right_wheel_line : Line2D
var outline : Line2D
var chassis_line : Line2D
var chassis_deco : Array
var state = States.CHASSIS

func _ready():
	pass

