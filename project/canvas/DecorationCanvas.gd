extends TextureRect

const POINTS_TIME = .01
const POINTS_DIST = 1

var lines = []
var lines_backup = []
var line_color = Color.black
var line_width = 10
var time = 0
var is_drawing = false
var drawing_scale = 1

func _input(event):

	if event.is_action_pressed("canvas_click"):
		var point = get_local_mouse_position()
		if point.x >= 0 and point.x <= rect_size.x and point.y >= 0 and point.y <= rect_size.y:
			is_drawing = true
			new_line()
			time = 0
			lines.back().add_point(point)
	elif event.is_action_released("canvas_click"):
		is_drawing = false


func _process(delta):
	if is_drawing and Input.is_action_pressed("canvas_click"):
		time += delta
		while time > POINTS_TIME:
			time -= POINTS_TIME
			var point = get_local_mouse_position()
			var line = lines.back()
			point.x = clamp(point.x, 0, rect_size.x)
			point.y = clamp(point.y, 0, rect_size.y)
			if point.distance_to(line.get_point_position(line.get_point_count()-1)) > POINTS_DIST:
				line.add_point(point)


func undo():
	if lines.size():
		remove_child(lines.back())
		lines.pop_back()
	else:
		lines = lines_backup
		for line in lines:
			add_child(line)
		lines_backup = []


func clear():
	lines_backup = lines.duplicate()
	for line in lines:
		remove_child(line)
	lines = []


func new_line():
	var line = Line2D.new()
	line.default_color = line_color
	line.width = line_width
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(line)
	lines.append(line)


func get_scaled_lines():
	var scaled_lines = []
	for line in lines:
		var scaled_line = line.duplicate()
		var center = rect_size/2
		for i in range(scaled_line.get_point_count()):
			var point = scaled_line.points[i]
			scaled_line.set_point_position(i, center + (point - center)*drawing_scale)
		scaled_line.width *= drawing_scale
		scaled_lines.append(scaled_line)
	return scaled_lines

func change_color(color):
	line_color = color


func change_width(width):
	line_width = width