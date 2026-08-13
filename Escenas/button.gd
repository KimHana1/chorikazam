extends Button


func _ready():
	animar()

func animar():
	var tween = create_tween()

	tween.set_loops()

	tween.tween_property(
		self,
		"scale",
		Vector2(1.05, 1.05),
		0.5
	)

	tween.tween_property(
		self,
		"scale",
		Vector2(1.0, 1.0),
		0.7
	)
