@tool
extends Control

const SPRITE_SIZE = Vector2(32, 32)

@export var bkg_color: Color = Color.DARK_GRAY
@export var line_color: Color = Color.LIGHT_GRAY
@export var highlight_color: Color = Color.GRAY
@export var text_color: Color = Color.WHITE

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var line_width: int = 4

@export var options: Array[WheelOption]

var selection = 0
var font: Font

func _ready():
	_load_font()

func _load_font():
	var font_path = "res://assets/fonts/monogram.ttf"
	var font_resource = load(font_path)
	if font_resource:
		font = font_resource
		print("Custom font loaded successfully")
	else:
		push_error("Failed to load custom font from: " + font_path)
		font = ThemeDB.fallback_font
	
	if not font:
		push_error("No valid font available for SelectionWheel")

func Close():
	hide()
	return options[selection].name

func _draw():
	if not font:
		_load_font()
		if not font:
			push_error("No valid font available for drawing text")
			return

	var offset = SPRITE_SIZE / -2
	
	draw_circle(Vector2.ZERO, outer_radius, bkg_color)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)
	
	if len(options) >= 3:
		
		# draw separator lines
		for i in range(len(options) - 1):
			var rads = TAU * i / ((len(options) - 1))
			var point = Vector2.from_angle(rads)
			draw_line(
				point * inner_radius,
				point * outer_radius,
				line_color,
				line_width,
				true
			)
		
		if selection == 0:
			draw_circle(Vector2.ZERO, inner_radius, highlight_color)
			
		draw_texture_rect_region(
			options[0].atlas,
			Rect2(offset, SPRITE_SIZE),
			options[0].region
		)
		
		for i in range(1, len(options)):
			var start_rads = (TAU * (i-1)) / (len(options) - 1)
			var end_rads = (TAU * i) / (len(options) - 1)
			var mid_rads = (start_rads + end_rads) / 2.0 * -1
			var radius_mid = (inner_radius + outer_radius) / 2
			
			if selection == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				
				for j in range(points_per_arc + 1):
					var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(TAU - angle))
					points_outer.append(outer_radius * Vector2.from_angle(TAU - angle))
					
				points_outer.reverse()
				draw_polygon(
					points_inner + points_outer,
					PackedColorArray([highlight_color])
				)
			
			var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
			draw_texture_rect_region(
				options[i].atlas,
				Rect2(draw_pos, SPRITE_SIZE),
				options[i].region
			)
			
			# Draw cost text
			if options[i].cost > 0:
				var text = str(options[i].cost) + "G"
				var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 24)
				var text_pos = (radius_mid + 25) * Vector2.from_angle(mid_rads) - text_size / 2
				text_pos.y = text_pos.y + 13
				text_pos.x = text_pos.x + 5
				draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, text_color if text_color else Color.WHITE)

func _process(delta):
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius < inner_radius:
		selection = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selection = ceil((mouse_rads / TAU) * (len(options) - 1))
		
	queue_redraw()
