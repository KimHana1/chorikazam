extends Area2D

@export var nombre_ingrediente: String = ""
@export var velocidad: float = 180.0
@export var limite_izq: float = 6.0
@export var limite_der: float = 921.0
@export var limite_arriba: float = 39.0
@export var limite_abajo: float = 629.0

@export_group("Texturas por Estado")
@export var textura_pelado: Texture2D
@export var textura_cortado: Texture2D
@export var textura_calentado: Texture2D

@onready var sprite = $Sprite2D

var direccion: Vector2 = Vector2.ZERO
var terminado: bool = false
var congelado: bool = false
var puede_congelarse: bool = true

var escala_original: Vector2

func _ready():
	add_to_group("ingredientes")
	input_pickable = true
	escala_original = sprite.scale 
	reiniciar_direccion_aleatoria()

func _process(delta):
	if terminado or congelado:
		return

	position += direccion * velocidad * delta

	if position.x <= limite_izq:
		direccion.x = abs(direccion.x)
	elif position.x >= limite_der:
		direccion.x = -abs(direccion.x)

	if position.y <= limite_arriba:
		direccion.y = abs(direccion.y)
	elif position.y >= limite_abajo:
		direccion.y = -abs(direccion.y)

func reiniciar_direccion_aleatoria():
	direccion = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()

	if direccion == Vector2.ZERO:
		direccion = Vector2(1, 1).normalized()

func obtener_cocina():
	var nodo = get_parent()
	while nodo != null:
		if nodo.has_method("verificar_ingrediente") or nodo.has_method("intentar_finalizar_pedido"):
			return nodo
		nodo = nodo.get_parent()
	return null

func aplicar_hechizo(paso: String):
	paso = paso.to_lower()
	var cocina = obtener_cocina()

	if cocina:
		if paso == "emplatar" or paso == "cerrado" or paso == "circulo":
			if cocina.has_method("intentar_finalizar_pedido"):
				cocina.intentar_finalizar_pedido()
		else:
			cambiar_sprite_por_estado(paso)
			
			if cocina.has_method("verificar_ingrediente"):
				cocina.verificar_ingrediente(nombre_ingrediente, paso)

func cambiar_sprite_por_estado(estado: String):
	match estado:
		"pelar":
			if textura_pelado:
				sprite.texture = textura_pelado
		"cortar":
			if textura_cortado:
				sprite.texture = textura_cortado
		"calentar":
			if textura_calentado:
				sprite.texture = textura_calentado

func correcto():
	if terminado:
		return

	terminado = true
	congelado = true

	direccion = Vector2.ZERO
	velocidad = 0
	
	sprite.scale = escala_original 

	var cocina = obtener_cocina()
	if cocina and cocina.has_method("mover_ingrediente_al_plato"):
		cocina.mover_ingrediente_al_plato(self, nombre_ingrediente)

	sprite.modulate = Color.WHITE

func incorrecto():
	if terminado:
		return

	sprite.modulate = Color.RED

	get_tree().create_timer(0.4).timeout.connect(func():
		if not terminado:
			sprite.modulate = Color.WHITE
	)

func _on_mouse_entered():
	if terminado or congelado:
		return

	if not puede_congelarse:
		return

	congelado = true
	puede_congelarse = false
	sprite.scale = escala_original * 1.15

	get_tree().create_timer(1.0).timeout.connect(_on_descongelar)

func _on_descongelar():
	if terminado:
		return

	congelado = false
	sprite.scale = escala_original
	reiniciar_direccion_aleatoria()

	get_tree().create_timer(2.0).timeout.connect(_on_cooldown_terminado)

func _on_cooldown_terminado():
	puede_congelarse = true
