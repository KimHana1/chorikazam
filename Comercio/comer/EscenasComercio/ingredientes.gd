extends Node2D

enum TipoBoton {
	CARNE,
	SALCHICHA,
	PAN,
	PAPA,
	TOMATE,
	DESCUENTO,
	TRATO
}

@export var tipo_boton: TipoBoton = TipoBoton.TRATO
@export var porcentaje_reduccion := 10.0

func reducir_tamano():
	if tipo_boton == TipoBoton.TRATO:
		return

	scale.x *= 1.0 - porcentaje_reduccion / 100.0
	scale.y *= 1.0 - porcentaje_reduccion / 100.0
