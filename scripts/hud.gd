extends CanvasLayer

@export var lleno: Texture2D   # Dibujo del corazón lleno.
@export var vacio: Texture2D   # Dibujo del corazón vacío.

##LOGICA CORAZONES##
# Los que quedan, llenos. El resto, vacíos.
func poner_vidas(vidas: int) -> void:
	var corazones = [$corazon1, $corazon2, $corazon3]
	for i in corazones.size():
		if i < vidas:
			corazones[i].texture = lleno
		else:
			corazones[i].texture = vacio

##LOGICA HERMANA ACTIVA##
# La que no se usa, más oscura. Igual que en el nivel.
func poner_activa(laia_activa: bool) -> void:
	if laia_activa:
		$retratoLaia.modulate = Color(1, 1, 1)
		$retratoEnara.modulate = Color(0.5, 0.5, 0.5)
	else:
		$retratoLaia.modulate = Color(0.5, 0.5, 0.5)
		$retratoEnara.modulate = Color(1, 1, 1)
