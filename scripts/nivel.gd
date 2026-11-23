extends Node2D

@export_file("*.tscn") var siguiente := "res://escenas/creditos.tscn"
@export var caida_maxima := 0.0
@export var limite_caida := 1000.0   # Más abajo de esta y, se ha caído por un hueco.

@onready var laia = $laia
@onready var enara = $enara

var terminado := false
var vidas := 3

func _ready() -> void:
	laia.activa = true
	# Al empezar, Laia activa y todos los corazones llenos.
	$HUD.poner_activa(true)
	$HUD.poner_vidas(vidas)

##LOGICA CAMBIO DE HERMANA##
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cambiar"):
		laia.activa = not laia.activa
		enara.activa = not enara.activa
		# El HUD oscurece la que no se usa.
		$HUD.poner_activa(laia.activa)

func _physics_process(_delta: float) -> void: # "Utilizamos _ para obviar el valor delta"
	caida_suave()
	caer_al_vacio()
	comprobar_meta()

##LOGICA CAIDA SUAVE##
# en el sueño se cae despacito, como flotando (0 = caida normal)
func caida_suave() -> void:
	if caida_maxima > 0:
		if laia.velocity.y > caida_maxima:
			laia.velocity.y = caida_maxima
		if enara.velocity.y > caida_maxima:
			enara.velocity.y = caida_maxima

##LOGICA VIDAS##
# Quita un corazón. Sin corazones, el subnivel empieza de nuevo.
func quitar_vida() -> void:
	vidas -= 1
	$HUD.poner_vidas(vidas)
	if vidas <= 0:
		get_tree().call_deferred("reload_current_scene")
		##get_tree().reload_current_scene() Error al perder todas las vidas.

##LOGICA CAER AL VACIO##
# Si alguna baja del límite, se ha caído por un hueco.
func caer_al_vacio() -> void:
	if laia.position.y > limite_caida:
		laia.caida()
	if enara.position.y > limite_caida:
		enara.caida()

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
