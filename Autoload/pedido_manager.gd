extends Node

var pedidos_activos: Array = []
var ultimo_id: int = 0
var pedido_completado: bool = false
var resultado_cliente: String = "normal"
var pedido_actual={}
var cliente_actual_tipo = ""


func registrar_nuevo_pedido(pedido_base: Dictionary, color_cliente: Color) -> Dictionary:
	ultimo_id += 1
	var nuevo_pedido = pedido_base.duplicate(true)
	nuevo_pedido["id"] = ultimo_id
	nuevo_pedido["color"] = color_cliente
	nuevo_pedido["paciencia_actual"] = nuevo_pedido["paciencia"]
	
	pedidos_activos.append(nuevo_pedido)
	return nuevo_pedido

func obtener_pedido_por_id(id: int):
	for p in pedidos_activos:
		if p["id"] == id:
			return p
	return null

func eliminar_pedido_por_id(id: int):
	for i in range(pedidos_activos.size()):
		if pedidos_activos[i]["id"] == id:
			pedidos_activos.remove_at(i)
			break
