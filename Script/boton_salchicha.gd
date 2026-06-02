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

@export var tipo_boton : TipoBoton

@export var porcentaje_reduccion := 10.0

func reducir_tamano():

	scale.x *= \
	1.0 - (porcentaje_reduccion / 100.0)
