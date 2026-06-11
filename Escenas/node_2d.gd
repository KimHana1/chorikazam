extends Node2D

@onready var pagina_1 = $Pagina1
@onready var pagina_2 = $Pagina2

var pagina_actual := 1
var animando := false

func pasar_pagina():

	if animando:
		return

	animando = true

	var tween = create_tween()

	if pagina_actual == 1:

		tween.tween_property(
			pagina_1,
			"scale:x",
			0.0,
			0.15
		)

		await tween.finished

		pagina_1.visible = false
		pagina_2.visible = true

		pagina_2.scale.x = 0.0

		var tween2 = create_tween()

		tween2.tween_property(
			pagina_2,
			"scale:x",
			1.0,
			0.15
		)

		await tween2.finished

		pagina_actual = 2

	else:

		tween.tween_property(
			pagina_2,
			"scale:x",
			0.0,
			0.15
		)

		await tween.finished

		pagina_2.visible = false
		pagina_1.visible = true

		pagina_1.scale.x = 0.0

		var tween2 = create_tween()

		tween2.tween_property(
			pagina_1,
			"scale:x",
			1.0,
			0.15
		)

		await tween2.finished

		pagina_actual = 1

	animando = false
