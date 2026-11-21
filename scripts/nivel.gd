extends Node2D

@export_file("*.tscn") var siguiente := "res://escenas/creditos.tscn"
@export var caida_maxima := 0.0

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

func _physics_process(_delta: float) -> void: # "Utilizamos _ para obviar el valor delta"
	caida_suave()
	comprobar_meta()

##LOGICA CAIDA SUAVE##
# en el sueño se cae despacito, como flotando (0 = caida normal)
func caida_suave() -> void:
	if caida_maxima > 0:
		if laia.velocity.y > caida_maxima:
			laia.velocity.y = caida_maxima
		if enara.velocity.y > caida_maxima:
			enara.velocity.y = caida_maxima

##LOGICA FIN DEL NIVEL##
func comprobar_meta() -> void:
	if terminado:
		return
	var dentro = $Meta.get_overlapping_bodies()
	if laia in dentro and enara in dentro:
		terminado = true
		laia.celebrando = true
		enara.celebrando = true
		$Completado.visible = true
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file(siguiente)
