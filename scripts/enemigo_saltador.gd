extends Area2D

@export var salto := -220.0   # Fuerza del salto. Más negativo, más alto.
@export var espera := 1.5     # Segundos quieto entre salto y salto.
@export var gravedad := 600.0

var suelo_y := 0.0
var velocidad_y := 0.0
var tiempo := 0.0
var en_el_aire := false
var muerto := false

func _ready() -> void:
	# Se guarda la altura del suelo para poder aterrizar en el mismo sitio. 
	suelo_y = position.y
	tiempo = espera
	$AnimatedSprite2D.play("reposo")

func _physics_process(delta: float) -> void:
	if muerto:
		return
	##LOGICA SALTAR##
	# En el aire cae con gravedad hasta tocar el suelo.
	if en_el_aire:
		velocidad_y += gravedad * delta
		position.y += velocidad_y * delta
		if position.y >= suelo_y:
			position.y = suelo_y
			en_el_aire = false
			tiempo = espera
	# En el suelo espera y luego salta.
	else:
		tiempo -= delta
		if tiempo <= 0:
			velocidad_y = salto
			en_el_aire = true

	##LOGICA ANIMACION##
	# Un dibujo para cada momento del salto.
	var nueva := "reposo"
	if en_el_aire:
		if velocidad_y < 0:
			nueva = "subir"
		else:
			nueva = "caer"
	elif tiempo < 0.25:
		nueva = "impulso"
	if $AnimatedSprite2D.animation != nueva:
		$AnimatedSprite2D.play(nueva)

	##LOGICA SOMBRA##
	$sombra.visible = not en_el_aire

##LOGICA TOCAR HERMANA##
func _on_body_entered(body: Node2D) -> void:
	# Solo cuentan las hermanas.
	if muerto or not body is CharacterBody2D:
		return
	# Si le cae encima, lo aplasta y rebota.
	if body.velocity.y > 0 and body.position.y < position.y - 30:
		body.velocity.y = -200
		morir()
	# Si no, daño.
	else:
		body.herida()

##LOGICA MORIR##
func morir() -> void:
	muerto = true
	$sombra.visible = false
	$AnimatedSprite2D.play("morir")
	await $AnimatedSprite2D.animation_finished
	queue_free()
