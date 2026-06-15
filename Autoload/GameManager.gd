extends Node

var dia_actual := 1
var duracion_dia := 300.0
var tiempo_restante := 300.0

var clientes_por_dia := 3
var clientes_restantes := 0

func iniciar_dia():
	tiempo_restante = duracion_dia
	
	clientes_restantes = clientes_por_dia + (dia_actual - 1)
	
	print("Iniciando Día: ", dia_actual, " | Clientes totales hoy: ", clientes_restantes)

func siguiente_dia():
	dia_actual += 1
	iniciar_dia()
