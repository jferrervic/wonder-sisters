extends Button

@export_file("*.tscn") var escena := ""   # A qué escena lleva este botón.
@export var empezar_aqui := false          # Marcar solo en el primer botón de la pantalla.

func _ready() -> void:
	##LOGICA FOCO##
	# El primer botón sale seleccionado.
	if empezar_aqui:
		grab_focus()

##LOGICA CAMBIAR ESCENA##
func _pressed() -> void:
	get_tree().change_scene_to_file(escena)
	
	
