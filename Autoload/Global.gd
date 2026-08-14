extends Node

var tiempo_dia := 300.0

var monedas_jugador := 800.0
var monedas_vendedor := 100.0

# Inicializados todos los ingredientes base en 2 como querías (en minúsculas)
var ingredientes : Dictionary[String,int] = {
	"carne": 2,
	"chorizo": 2,
	"pan": 2,
	"papa": 2,
	"tomate": 2
}

# FUNCIÓN AUXILIAR: Quita los números de variante de forma segura (ej: "papa2" -> "papa")
func _obtener_nombre_base(nombre: String) -> String:
	var nombre_limpio = nombre.to_lower().strip_edges()
	if nombre_limpio.ends_with("2") or nombre_limpio.ends_with("3"):
		nombre_limpio = nombre_limpio.left(-1)
	return nombre_limpio

func agregar_ingrediente(nombre: String, cantidad: int = 1):
	var nombre_base = _obtener_nombre_base(nombre)
	
	if ingredientes.has(nombre_base):
		ingredientes[nombre_base] += cantidad
	else:
		ingredientes[nombre_base] = cantidad

	print("Ingrediente agregado al stock base: ", nombre_base, " x", cantidad)

func quitar_ingrediente(nombre: String, cantidad: int = 1):
	var nombre_base = _obtener_nombre_base(nombre)

	if ingredientes.has(nombre_base):
		ingredientes[nombre_base] -= cantidad
		if ingredientes[nombre_base] < 0:
			ingredientes[nombre_base] = 0

	print("Ingrediente descontado del stock base: ", nombre_base, " x", cantidad)

func cantidad_ingrediente(nombre: String) -> int:
	var nombre_base = _obtener_nombre_base(nombre)
	return ingredientes.get(nombre_base, 0)

func tiene_ingrediente(nombre: String, cantidad: int = 1) -> bool:
	return cantidad_ingrediente(nombre) >= cantidad

func agregar_monedas_jugador(cantidad: float):
	monedas_jugador += cantidad
	print("Jugador ganó: ", cantidad)
	print("Monedas actuales: ", monedas_jugador)

func quitar_monedas_jugador(cantidad: float):
	monedas_jugador -= cantidad
	if monedas_jugador < 0:
		monedas_jugador = 0
	print("Jugador gastó: ", cantidad)
	print("Monedas actuales: ", monedas_jugador)

func tiene_monedas_jugador(cantidad: float) -> bool:
	return monedas_jugador >= cantidad

func agregar_monedas_vendedor(cantidad: float):
	monedas_vendedor += cantidad
	print("Vendedor ganó: ", cantidad)

func quitar_monedas_vendedor(cantidad: float):
	monedas_vendedor -= cantidad
	if monedas_vendedor < 0:
		monedas_vendedor = 0
