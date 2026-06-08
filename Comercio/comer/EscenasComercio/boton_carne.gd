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

@export var tipo_boton: TipoBoton = TipoBoton.PAN
@export var porcentaje_reduccion := 10.0

func reducir_tamano():
	if tipo_boton == TipoBoton.TRATO:
		return

	scale *= 1.0 - porcentaje_reduccion / 100.0
