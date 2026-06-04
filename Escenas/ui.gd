extends Control
@onready var info_jugador=$InfoJugador
@onready var info_vendedor=$InfoVendedor
@onready var info_total=$InfoTotal
@onready var cooldown=$Cooldown
func actualizar_datos(
	monedas_jugador,
	monedas_vendedor,
	total
):

	info_jugador.text = \
		"Tus Monedas: $" + \
		str(round(monedas_jugador))

	info_vendedor.text = \
		"Monedas del Vendedor: $" + \
		str(round(monedas_vendedor))

	info_total.text = \
		"Total a Pagar: $" + \
		str(round(total))


func actualizar_cooldown(
	tiempo
):

	cooldown.text = \
		"Cooldown: " + \
		str(round(tiempo))


func limpiar_cooldown():

	cooldown.text = ""
