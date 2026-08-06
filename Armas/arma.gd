extends Area3D
class_name Weapon

@export var data: WeaponData
@export var player: Node3D

var enemies_in_range: Array = []
var mas_cercano: Node3D

func _ready():
	actualizar_stats()
	$Timer.one_shot = false
	$Timer.stop()

	ItemManager.stats_changed.connect(_on_stats_change)

func _process(delta):
	var mesh_node = $MeshInstance3D
	if not mesh_node:
		return
		
	# Limpiar enemigos invalidos o liberados
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	if not enemies_in_range.is_empty():
		var distancia_minima := INF
		var target: Node3D = null
		for enemigo in enemies_in_range:
			var d = global_position.distance_to(enemigo.global_position)
			if d < distancia_minima:
				distancia_minima = d
				target = enemigo
		
		if target:
			# Obtener direccion en coordenadas locales del arma
			var target_local_pos = to_local(target.global_position)
			var dir = (target_local_pos - mesh_node.position).normalized()
			
			if dir.length() > 0.01:
				# Basis.looking_at en espacio local
				var target_basis = Basis.looking_at(dir, Vector3.UP)
				# Corregir los 90 grados en Y para nuestros modelos (sumados 180 grados adicionales)
				target_basis = target_basis.rotated(Vector3.UP, deg_to_rad(90.0))
				
				# Interpolar suavemente conservando la escala
				var current_basis = mesh_node.transform.basis.orthonormalized()
				var slerped_basis = current_basis.slerp(target_basis.orthonormalized(), delta * 12.0)
				var scale_vec = mesh_node.transform.basis.get_scale()
				mesh_node.transform.basis = slerped_basis.scaled(scale_vec)
	else:
		# Si no hay enemigos, volver suavemente a la orientacion original rotada 180 grados
		var target_idle = Basis.IDENTITY.rotated(Vector3.UP, deg_to_rad(180.0))
		var current_basis = mesh_node.transform.basis.orthonormalized()
		var slerped_basis = current_basis.slerp(target_idle, delta * 6.0)
		var scale_vec = mesh_node.transform.basis.get_scale()
		mesh_node.transform.basis = slerped_basis.scaled(scale_vec)

func actualizar_stats():
	$Timer.wait_time = max(0.05, data.cooldown / PlayerStats.atq_speed)

	var shape = $CollisionShape3D.shape
	if shape is SphereShape3D:
		shape.radius = data.rango * PlayerStats.range_multiplier
	elif shape is CylinderShape3D:
		shape.radius = data.rango * PlayerStats.range_multiplier


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if !enemies_in_range.has(body):
			enemies_in_range.append(body)

		if $Timer.is_stopped():
			attack()
			$Timer.start()


func _on_body_exited(body):
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)

		if enemies_in_range.is_empty():
			$Timer.stop()


func _on_timer_timeout():
	attack()


func attack():
	enemies_in_range = enemies_in_range.filter(
		func(e): return is_instance_valid(e)
	)

	if enemies_in_range.is_empty():
		$Timer.stop()
		return

	var distancia_minima := INF
	mas_cercano = null

	for enemigo in enemies_in_range:
		var d = global_position.distance_to(enemigo.global_position)

		if d < distancia_minima:
			distancia_minima = d
			mas_cercano = enemigo

	if mas_cercano != null:
		perform_attack(mas_cercano)
		EventBus.weapon_fired.emit()


func perform_attack(target):
	pass


func _on_stats_change():
	$Timer.wait_time = data.cooldown / PlayerStats.atq_speed
	var shape = $CollisionShape3D.shape
	if shape is SphereShape3D or shape is CylinderShape3D:
		shape.radius = data.rango * PlayerStats.range_multiplier


func upgrade():
	data.upgrade()
	actualizar_stats()
