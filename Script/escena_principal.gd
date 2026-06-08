extends GridContainer


func actualizar_inventario():

	for panel in get_tree().get_nodes_in_group(
		"ingrediente_global"
	):
		panel.actualizar_info()
