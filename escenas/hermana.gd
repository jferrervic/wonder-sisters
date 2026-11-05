extends CharacterBody2D

@export var activa := false
@export var velocidad := 150.0
@export var salto := -300.0

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
