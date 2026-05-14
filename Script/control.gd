extends Control

var escena_cliente = preload("res://Escenas/cliente.tscn")

func _on_button_pressed():
	get_tree().change_scene_to_packed(escena_cliente)
