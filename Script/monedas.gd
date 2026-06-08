extends PanelContainer

@onready var label = $MarginContainer/Label


func _ready():
	actualizar_info()


func actualizar_info():

	label.text = "$" + str(
		round(Global.monedas_jugador)
	)
