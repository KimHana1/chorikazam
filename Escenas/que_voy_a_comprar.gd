extends Control
@onready var carne=$CarneCantidad
@onready var chorizo =$ChorizoCantidad
@onready var pan = $PanCantidad
@onready var papa = $PapaCantidad
@onready var tomate = $TomateCantidad

func actualizar_carrito(carrito):

	carne.text = str(carrito["carne"])+  " Carne"

	chorizo.text = str(carrito["chorizo"])+  " Chorizo"

	pan.text = str(carrito["pan"])+  " Pan" 

	papa.text = str(carrito["papa"]) + " Papa"

	tomate.text = str(carrito["tomate"]) +  " Tomate"
