extends Node


func canvas_to_top_down(pos_canvas: Vector2) -> Vector2:
	var pos_top_down: Vector2 = pos_canvas * Vector2(1.0, 2.0)

	return pos_top_down


func top_down_to_canvas(pos_top_down: Vector2) -> Vector2:
	var pos_canvas: Vector2 = pos_top_down * Vector2(1.0, 0.5)

	return pos_canvas


func vector3_to_vector2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.y)


func canvas_to_wc3_2d(pos_canvas: Vector2) -> Vector2:
	var pos_top_down_pixels: Vector2 = VectorUtils.canvas_to_top_down(pos_canvas)
	var pos_wc3: Vector2 = pos_top_down_pixels / Constants.WC3_DISTANCE_TO_PIXELS

	return pos_wc3


func wc3_to_canvas(pos_wc3: Vector3) -> Vector2:
	var pos_pixels: Vector3 = pos_wc3 * Constants.WC3_DISTANCE_TO_PIXELS
	var canvas_x: float = pos_pixels.x
	var canvas_y: float = pos_pixels.y * 0.5 - pos_pixels.z
	var pos_canvas: Vector2 = Vector2(canvas_x, canvas_y)

	return pos_canvas


func in_range(start: Vector2, end: Vector2, radius: float) -> bool:
	var distance_squared: float = start.distance_squared_to(end)
	var radius_squared: float = radius * radius
	var result: bool = distance_squared <= radius_squared

	return result