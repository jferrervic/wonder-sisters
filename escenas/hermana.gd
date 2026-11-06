extends CharacterBody2D

@export var activa := false
@export var velocidad := 150.0
@export var salto := -300.0
@export var color_flecha := Color("83c5ef")
@export var puede_empujar := false

var tiempo := 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if activa:
		if Input.is_action_just_pressed("saltar") and is_on_floor():
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
