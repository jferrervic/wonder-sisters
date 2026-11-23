extends Area2D

@export var recorrido := 120.0   # Distancia que vuela hacia la derecha.
@export var velocidad := 40.0
@export var onda := 6.0          # Lo que sube y baja. 0 = vuela recto.

var inicio := Vector2.ZERO
var lado := 1
var tiempo := 0.0
var muerto := false

func _ready() -> void:
	# Se guarda donde empieza. La onda va alrededor de esta altura.
	inicio = position
	$AnimatedSprite2D.play("volar")

func _physics_process(delta: float) -> void:
	if muerto:
		return
	##LOGICA VOLAR##
	# Igual que el centinela. Va y viene.
	position.x += lado * velocidad * delta
	if position.x > inicio.x + recorrido:
		lado = -1
	if position.x < inicio.x:
		lado = 1
	$AnimatedSprite2D.flip_h = lado == -1

	##LOGICA ONDA##
	# El seno va de -1 a 1 y vuelve. Así sube y baja suave.
	tiempo += delta
	position.y = inicio.y + sin(tiempo * 3.0) * onda

##LOGICA TOCAR HERMANA##
func _on_body_entered(body: Node2D) -> void:
	# Solo cuentan las hermanas. Ni suelo ni cajas.
	if muerto or not body is CharacterBody2D:
		return
	# Si le cae encima, lo aplasta y rebota.
	if body.velocity.y > 0 and body.position.y < position.y - 15:
		body.velocity.y = -200
		morir()
	# Si no, daño.
	else:
		body.herida()

##LOGICA MORIR##
# Animación de morir y, al acabar, se borra.
func morir() -> void:
	muerto = true
	$AnimatedSprite2D.play("morir")
	await $AnimatedSprite2D.animation_finished
	queue_free()
