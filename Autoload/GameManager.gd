extends Node
var dia_actual := 1

var duracion_dia := 300.0
var tiempo_restante := 300.0

var clientes_por_dia := 3

func iniciar_dia():
	tiempo_restante = duracion_dia
