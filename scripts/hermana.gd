extends CharacterBody2D

@export var activa := false
@export var velocidad := 150.0
@export var salto := -300.0
@export var color_flecha := Color("83c5ef")
@export var puede_empujar := false
@export var puede_agacharse := false
@export var alto_bola := 28.0
@export var ropa: SpriteFrames

@onready var forma = $CollisionShape2D
@onready var sprite = $AnimatedSprite2D

var tiempo := 0.0
var agachada := false
var alto_normal := 0.0
var y_normal := 0.0
var en_el_aire := false
var tiempo_aterrizar := 0.0
var tiempo_empujar := 0.0
var lado_empujar := 0.0
var empujando := false
var celebrando := false
var sombra_x := 0.0
var sitio_seguro := Vector2.ZERO
var invencible := 0.0

func _ready() -> void:
	##LOGICA ROPA##
	# Si el nivel le pone otra ropa, se cambian los dibujos
	if ropa != null:
		sprite.sprite_frames = ropa
	alto_normal = forma.shape.size.y
	y_normal = forma.position.y
	# La x que tiene la sombra en el editor (mirando a la derecha)
	sombra_x = $Sombra.position.x
	# Al empezar, el sitio seguro es donde aparece.
	sitio_seguro = position
	sprite.play("quieta")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direccion := 0.0
	if activa and not celebrando:
		if Input.is_action_just_pressed("saltar") and is_on_floor() and not agachada:
			velocity.y = salto
		direccion = Input.get_axis("izquierda", "derecha")
	if direccion:
		velocity.x = direccion * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

	var velocidad_caida := velocity.y
	move_and_slide()

	##LOGICA SITIO SEGURO##
	# Cada vez que pisa suelo, se apunta. Si se cae, vuelve aquí.
	if is_on_floor():
		sitio_seguro = position

	##LOGICA ATERRIZAR## (!!!)
	# Al tocar el suelo despues de una caida se agacha un momento
	if is_on_floor() and en_el_aire and velocidad_caida > 130:
		tiempo_aterrizar = 0.15
	en_el_aire = not is_on_floor()
	tiempo_aterrizar -= delta

	##LOGICA EMPUJAR CAJA##
	for i in get_slide_collision_count():
		var choque := get_slide_collision(i)
		if puede_empujar and choque.get_collider() is RigidBody2D and absf(choque.get_normal().x) > 0.5:
			choque.get_collider().apply_central_impulse(-choque.get_normal() * 25)
			tiempo_empujar = 0.2
			lado_empujar = signf(-choque.get_normal().x)
	# Se sigue empujando 0,2 s despues del ultimo choque (si no salta entre andar y empujar)
	tiempo_empujar -= delta
	empujando = tiempo_empujar > 0 and signf(direccion) == lado_empujar

	##LOGICA AGACHARSE EN BOLA##
	if puede_agacharse:
		if activa and Input.is_action_pressed("agachar") and is_on_floor():
			agachada = true
		elif agachada and not test_move(global_transform, Vector2(0, -(alto_normal - alto_bola))):
			agachada = false

		if agachada:
			forma.shape.size.y = alto_bola
			forma.position.y = y_normal + (alto_normal - alto_bola) / 2
		else:
			forma.shape.size.y = alto_normal
			forma.position.y = y_normal

	##LOGICA ANIMACION##
	if direccion != 0:
		sprite.flip_h = direccion < 0
		# Al mirar a la izquierda, la sombra pasa al otro lado
		if sprite.flip_h:
			$Sombra.position.x = -sombra_x
		else:
			$Sombra.position.x = sombra_x
	var nueva := "quieta"
	if celebrando:
		nueva = "celebrar"
	elif agachada:
		nueva = "bola"
	elif not is_on_floor():
		if velocity.y < -90:
			nueva = "saltar"
		elif velocity.y < 70:
			nueva = "arriba"
		else:
			nueva = "caer"
	elif tiempo_aterrizar > 0:
		nueva = "aterrizar"
	elif empujando:
		nueva = "empujar"
	elif velocity.x != 0:
		nueva = "andar"
	# Solo se cambia cuando es otra. Si se llama a play() en cada fotograma,
	# saltar y caer vuelven a su primer dibujo y parpadean.
	if sprite.animation != nueva:
		sprite.play(nueva)
	# La bola solo gira si Enara se mueve. Parada, se queda derecha (cabeza arriba).
	if agachada:
		if velocity.x == 0:
			sprite.frame = 0
			sprite.pause()
		else:
			sprite.play("bola")

		##LOGICA SOMBRA##
	# La sombra solo se ve cuando estan en el suelo.
	$Sombra.visible = is_on_floor()

	##LOGICA PARPADEO##
	# Tras un golpe parpadea un rato. Mientras, no le hacen daño.
	invencible -= delta
	if invencible > 0:
		sprite.visible = int(invencible * 10) % 2 == 0
	else:
		sprite.visible = true
	
	##LOGICA CAMARA##
	if activa:
		$Camera2D.make_current()

	##LOGICA INDICADOR HERMANA EN USO## (!!!)
	if activa:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(0.6, 0.6, 0.6)
	tiempo += delta
	queue_redraw()

##LOGICA HERIDA##
# Golpe de enemigo. Pierde un corazón y se queda donde está.
func herida() -> void:
	if invencible > 0:
		return
	invencible = 1.0
	velocity.y = -150   # Saltito del susto.
	get_parent().quitar_vida()

##LOGICA CAIDA AL VACIO##
# Se ha caído. Vuelve al último suelo que pisó y pierde un corazón.
func caida() -> void:
	position = sitio_seguro
	velocity = Vector2.ZERO
	invencible = 1.0
	get_parent().quitar_vida()

func _draw() -> void:
	if activa:
		var y := roundf(-30 + sin(tiempo * 5.0) * 2.0)
		var a := Vector2(-5, y - 6)
		var b := Vector2(5, y - 6)
		var c := Vector2(0, y)
		draw_colored_polygon(PackedVector2Array([a, b, c]), color_flecha)
		draw_polyline(PackedVector2Array([a, b, c, a]), Color("03103a"), 1.0)
