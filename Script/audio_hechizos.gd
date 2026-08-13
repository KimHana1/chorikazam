extends AudioStreamPlayer2D

@export var sonido_cortar: AudioStream
@export var sonido_pelar: AudioStream
@export var sonido_calentar: AudioStream
@export var sonido_emplatar: AudioStream

func reproducir_paso(paso:String):

	match paso:

		"cortar":
			stream = sonido_cortar

		"pelar":
			stream = sonido_pelar

		"calentar":
			stream = sonido_calentar

		"emplatar":
			stream = sonido_emplatar

		_:
			return

	play()
