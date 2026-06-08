extends TextureButton

signal comercio_iniciado

@export var escala_click := 1.05
@export var rotacion_click := 1.0
@export var duracion_animacion := 0.08

func _ready():
<<<<<<< HEAD
	if not pressed.is_connected(al_presionar):
		pressed.connect(al_presionar)

func al_presionar():
	print("boton Comercio presionado")

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "scale", Vector2(escala_click, escala_click), duracion_animacion)
	tween.tween_property(self, "rotation_degrees", rotacion_click, duracion_animacion)
=======

	pressed.connect(al_presionar)


func al_presionar():

	print("boton Comercio presionado")

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		self,
		"scale",
		Vector2(escala_click, escala_click),
		duracion_animacion
	)

	tween.tween_property(
		self,
		"rotation_degrees",
		rotacion_click,
		duracion_animacion
	)
>>>>>>> 2d643843303f7eeb55e10825c0207415adcb00a4

	await tween.finished

	var tween_retorno = create_tween()
<<<<<<< HEAD
	tween_retorno.set_parallel(true)

	tween_retorno.tween_property(self, "scale", Vector2.ONE, duracion_animacion)
	tween_retorno.tween_property(self, "rotation_degrees", 0.0, duracion_animacion)

	print("inicio comercio")
=======

	tween_retorno.set_parallel(true)

	tween_retorno.tween_property(
		self,
		"scale",
		Vector2.ONE,
		duracion_animacion
	)

	tween_retorno.tween_property(
		self,
		"rotation_degrees",
		0.0,
		duracion_animacion
	)

	print("inicio comercio")

>>>>>>> 2d643843303f7eeb55e10825c0207415adcb00a4
	comercio_iniciado.emit()
