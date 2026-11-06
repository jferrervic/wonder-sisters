extends Node2D

@onready var laia = $laia
@onready var enara = $enara

var terminado := false

func _ready() -> void:
	laia.activa = true

##LOGICA CAMBIO DE HERMANA##
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cambiar"):
		laia.activa = not laia.activa
		enara.activa = not enara.activa

##LOGICA BOTON DEL ROPERO##
func _on_boton_body_entered(body: Node2D) -> void:
	if body.name == "enara":
		for cajon in [$Cajon1, $Cajon2, $Cajon3]:
			cajon.visible = true
			cajon.get_node("CollisionShape2D").set_deferred("disabled", false)
		$Boton.queue_free()

##LOGICA FIN DEL NIVEL##
func _physics_process(_delta: float) -> void: # "Utilizamos _ para obviar el valor delta"
	if terminado:
		return
	var dentro = $Meta.get_overlapping_bodies()
	if laia in dentro and enara in dentro:
		terminado = true
		$Completado.visible = true
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://escenas/creditos.tscn")
