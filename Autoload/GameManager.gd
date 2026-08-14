extends Node

var dia_actual := 1
var duracion_dia := 60.0
var tiempo_restante := 60.0 

var clientes_por_dia := 5
var clientes_restantes := 0
var tutorial_visto: bool = false
var dia_iniciado: bool = false 

func iniciar_dia():

	if dia_iniciado:
		return
		
	tiempo_restante = duracion_dia
	clientes_restantes = clientes_por_dia + (dia_actual - 1)
	dia_iniciado = true
	
	print("Iniciando Día: ", dia_actual, " | Clientes totales hoy: ", clientes_restantes)

func siguiente_dia():
	dia_actual += 1
	dia_iniciado = false
	iniciar_dia()
