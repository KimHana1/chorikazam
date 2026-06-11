extends Node


var tiempo_dia := 300.0



var monedas_jugador := 200.0
var monedas_vendedor := 100.0


var ingredientes : Dictionary[String,int] = {
	"carne": 1,
	"chorizo": 2,
	"pan": 3,
	"papa": 4,
	"tomate": 5
	}



func agregar_ingrediente(nombre:String, cantidad:int = 1):

	if ingredientes.has(nombre):
		ingredientes[nombre] += cantidad


func quitar_ingrediente(nombre:String, cantidad:int = 1):

	if ingredientes.has(nombre):

		ingredientes[nombre] -= cantidad

		if ingredientes[nombre] < 0:
			ingredientes[nombre] = 0


func cantidad_ingrediente(nombre:String) -> int:

	return ingredientes.get(nombre, 0)



func agregar_monedas_jugador(cantidad:float):

	monedas_jugador += cantidad


func quitar_monedas_jugador(cantidad:float):

	monedas_jugador -= cantidad

	if monedas_jugador < 0:
		monedas_jugador = 0


func tiene_monedas_jugador(cantidad:float) -> bool:

	return monedas_jugador >= cantidad



func agregar_monedas_vendedor(cantidad:float):

	monedas_vendedor += cantidad


func quitar_monedas_vendedor(cantidad:float):

	monedas_vendedor -= cantidad

	if monedas_vendedor < 0:
		monedas_vendedor = 0
