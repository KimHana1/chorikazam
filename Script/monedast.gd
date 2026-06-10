extends PanelContainer

@onready var sprite = $Sprite2D if has_node("Sprite2D") else null

var valor: float = 1.0

func configurar(nuevo_valor: float):
	valor = nuevo_valor

func tomar():
	Global.agregar_monedas_jugador(valor)
	queue_free()
