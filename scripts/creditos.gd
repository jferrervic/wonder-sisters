extends Control

func _ready() -> void:
	$VBoxContainer/BotonReiniciar.pressed.connect(_on_reiniciar)
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir)
	$VBoxContainer/BotonReiniciar.grab_focus()

##LOGICA BOTON REINICIAR##
func _on_reiniciar() -> void:
	get_tree().change_scene_to_file("res://escenas/main.tscn")

func _on_salir() -> void:
	get_tree().quit()
