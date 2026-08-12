extends Area2D

@onready var libro = get_parent()

func _on_input_event(
	_viewport,
	event: InputEvent,
	_shape_idx
) -> void:

	if event is InputEventMouseButton:

		if event.pressed:

			libro.pasar_pagina()
