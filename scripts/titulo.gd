extends Control

func _ready() -> void:
	$VBoxContainer/BotonJugar.pressed.connect(_on_jugar)
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir)
	$VBoxContainer/BotonJugar.grab_focus()

func _on_jugar() -> void:
	get_tree().change_scene_to_file("res://escenas/main.tscn")

func _on_salir() -> void:
	get_tree().quit()
