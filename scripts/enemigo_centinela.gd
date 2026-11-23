extends Area2D

@export var recorrido := 96.0   # Lo que anda hacia la derecha desde donde empieza.
@export var velocidad := 35.0

var inicio_x := 0.0
var lado := 1
var muerto := false

func _ready() -> void:
	inicio_x = position.x
	$AnimatedSprite2D.play("andar")

func _physics_process(delta: float) -> void:
	if muerto:
		return
	##LOGICA ANDAR##
	# Anda hasta el final del recorrido y se da la vuelta.
	position.x += lado * velocidad * delta
	if position.x > inicio_x + recorrido:
		lado = -1
	if position.x < inicio_x:
		lado = 1
	$AnimatedSprite2D.flip_h = lado == -1

##LOGICA TOCAR HERMANA##
func _on_body_entered(body: Node2D) -> void:
	# Solo le importan las hermanas (no el suelo ni las cajas).
	if muerto or not body is CharacterBody2D:
		return
	# Si la hermana le cae encima, lo aplasta y rebota.
	if body.velocity.y > 0 and body.position.y < position.y - 30:
		body.velocity.y = -200
		morir()
	# Daño que hace.
	else:
		body.herida()

##LOGICA MORIR##
# Pone la animacion de morir y cuando acaba se borra.
func morir() -> void:
	muerto = true
	$AnimatedSprite2D.play("morir")
	await $AnimatedSprite2D.animation_finished
	queue_free()
