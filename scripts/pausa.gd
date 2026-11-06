extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$VBoxContainer/BotonContinuar.pressed.connect(_on_continuar)
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		if get_tree().paused:
			_on_continuar()
		else:
			_pausar()

func _pausar() -> void:
	get_tree().paused = true
	visible = true
	$VBoxContainer/BotonContinuar.grab_focus()

func _on_continuar() -> void:
	get_tree().paused = false
	visible = false

func _on_salir() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/titulo.tscn")
