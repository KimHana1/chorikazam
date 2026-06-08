extends Area2D

enum TipoBoton {
	CARNE,
	SALCHICHA,
	PAN,
	PAPA,
	TOMATE,
	DESCUENTO,
	TRATO
}

@export var tipo_boton := TipoBoton.TRATO

func reducir_tamano():

	print(
		name,
		" intento reducirse pero esta bloqueado"
	)

	print(
		"Escala actual: ",
		scale
	)

	pass
