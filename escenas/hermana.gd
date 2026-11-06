extends CharacterBody2D

@export var activa := false
@export var velocidad := 150.0
@export var salto := -300.0
@export var color_flecha := Color("83c5ef")
@export var puede_empujar := false
@export var puede_agacharse := false
@export var texturas_bola: Array[Texture2D] = []

@onready var forma = $CollisionShape2D
@onready var sprite = $Sprite2D

var tiempo := 0.0
var agachada := false
var alto_normal := 0.0
var y_normal := 0.0
var textura_normal: Texture2D

func _ready() -> void:
	alto_normal = forma.shape.size.y
	y_normal = forma.position.y
	textura_normal = sprite.texture

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if activa:
		if Input.is_action_just_pressed("saltar") and is_on_floor() and not agachada:
			velocity.y = salto
		var direction := Input.get_axis("izquierda", "derecha")
		if direction:
			velocity.x = direction * velocidad
		else:
			velocity.x = move_toward(velocity.x, 0, velocidad)
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

	move_and_slide()

	##LOGICA EMPUJAR CAJA##
	for i in get_slide_collision_count():
		var choque := get_slide_collision(i)
		if puede_empujar and choque.get_collider() is RigidBody2D:
			choque.get_collider().apply_central_impulse(-choque.get_normal() * 25)

	##LOGICA AGACHARSE EN BOLA##
	if puede_agacharse:
		if activa and Input.is_action_pressed("agachar"):
			agachada = true
		elif agachada and not test_move(global_transform, Vector2(0, -8)):
			agachada = false

		if agachada:
			forma.shape.size.y = alto_normal - 8
			forma.position.y = y_normal + 4
			var paso := int(tiempo * 10) % 4
			if velocity.x < 0:
				paso = 3 - paso
			if velocity.x == 0:
				paso = 0
			sprite.texture = texturas_bola[paso]
		else:
			forma.shape.size.y = alto_normal
			forma.position.y = y_normal
			sprite.texture = textura_normal

	##LOGICA CAMARA##
	if activa:
		$Camera2D.make_current()

	##LOGICA INDICADOR HERMANA EN USO##
	if activa:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(0.6, 0.6, 0.6)
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	if activa:
		var y := roundf(-30 + sin(tiempo * 5.0) * 2.0)
		var a := Vector2(-5, y - 6)
		var b := Vector2(5, y - 6)
		var c := Vector2(0, y)
		draw_colored_polygon(PackedVector2Array([a, b, c]), color_flecha)
		draw_polyline(PackedVector2Array([a, b, c, a]), Color("03103a"), 1.0)
