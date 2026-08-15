extends Control

var escena_cliente = preload("res://Escenas/cliente.tscn")

func _on_button_pressed():
	get_tree().change_scene_to_packed(escena_cliente)
func _ready() -> void:
	$VideoTutorial.hide()
	$BotonCerrarVideo.hide()

func _on_boton_tutorial_pressed() -> void:
	$VideoTutorial.show()
	$BotonCerrarVideo.show()
	$VideoTutorial.play()

func _on_boton_cerrar_video_pressed() -> void:
	
	$VideoTutorial.stop()
	$VideoTutorial.hide()
	$BotonCerrarVideo.hide()
