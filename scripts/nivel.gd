extends Node2D

@onready var laia = $laia
@onready var enara = $enara

func _ready() -> void:
	laia.activa = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cambiar"):
		laia.activa = not laia.activa
		enara.activa = not enara.activa
