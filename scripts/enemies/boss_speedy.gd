extends CharacterBody3D

@export var boss_name: String = "DEMONIO VELOZ"
@export var speed: float = 7.5
@export var dash_speed: float = 22.0
@export var contact_damage: float = 15.0
@export var dash_damage: float = 30.0
@export var dash_cooldown: float = 4.0
@export var wind_up_time: float = 0.5

enum State { IDLE, WINDING_UP, DASHING }
var state: State = State.IDLE

var player: Node3D = null
var attack_timer: float = 0.0
var dash_timer: float = 0.0
var wind_up_timer: float = 0.0
var dash_dir: Vector3 = Vector3.ZERO

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	player = get_tree().get_first_node_in_group("player")

	if health_component:
		health_component.max_health = 600.0
		health_component.health = 600.0
		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_boss_died)

	await get_tree().process_frame
	EventBus.boss_spawned.emit(self, boss_name)
	EventBus.boss_health_changed.emit(health_component.health, health_component.max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	dash_timer += delta

	match state:
		State.DASHING:
			velocity = dash_dir * dash_speed
			move_and_slide()
			for i in get_slide_collision_count():
				var col = get_slide_collision(i)
				var collider = col.get_collider()
				if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
					collider.take_damage(dash_damage)
			return

		State.WINDING_UP:
			wind_up_timer -= delta
			velocity = Vector3.ZERO
			move_and_slide()
			if wind_up_timer <= 0.0:
				_start_dash()
			return

		State.IDLE:
			_move_toward_player(delta)
			_handle_contact_damage(delta)
			if dash_timer >= dash_cooldown:
				_start_wind_up()

func _move_toward_player(delta: float) -> void:
	var dir = (player.global_position - global_position).normalized()
	dir.y = 0
	if dir.length() > 0.01:
		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 8.0)
	velocity = dir * speed
	move_and_slide()

func _handle_contact_damage(delta: float) -> void:
	attack_timer += delta
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("player"):
			if attack_timer >= 0.6:
				attack_timer = 0.0
				if collider.has_method("take_damage"):
					collider.take_damage(contact_damage)

func _start_wind_up() -> void:
	dash_timer = 0.0
	wind_up_timer = wind_up_time
	state = State.WINDING_UP

	if mesh_instance:
		var tween = create_tween()
		tween.tween_property(mesh_instance, "scale", Vector3(0.7, 1.3, 0.7), wind_up_time * 0.6)
		tween.tween_property(mesh_instance, "scale", Vector3(0.5, 0.7, 0.5), wind_up_time * 0.4)

		if mesh_instance.mesh:
			var mat = mesh_instance.get_active_material(0)
			if mat:
				mat.emission_energy_multiplier = 3.0

func _start_dash() -> void:
	state = State.DASHING
	if is_instance_valid(player):
		dash_dir = (player.global_position - global_position).normalized()
		dash_dir.y = 0
		if dash_dir.length() < 0.1:
			dash_dir = Vector3.FORWARD
	else:
		dash_dir = Vector3.FORWARD

	if mesh_instance:
		var tween = create_tween()
		tween.tween_property(mesh_instance, "scale", Vector3(0.6, 0.6, 0.6), 0.1)

		if mesh_instance.mesh:
			var mat = mesh_instance.get_active_material(0)
			if mat:
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.emission_energy_multiplier = 1.5
				tween.tween_property(mat, "albedo_color:a", 0.3, 0.1)

	await get_tree().create_timer(0.8).timeout

	if not is_instance_valid(self):
		return
	state = State.IDLE
	if mesh_instance:
		mesh_instance.scale = Vector3(0.8, 0.8, 0.8)
		var mat = mesh_instance.get_active_material(0)
		if mat:
			mat.albedo_color.a = 1.0
			mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			mat.emission_energy_multiplier = 1.5

func take_damage(damage_amount: float, is_critical: bool = false, crit_tier: int = 0) -> void:
	if health_component:
		health_component.take_damage(damage_amount, is_critical, crit_tier)

func _on_health_changed(current: float, max_hp: float) -> void:
	EventBus.boss_health_changed.emit(current, max_hp)

func _on_boss_died() -> void:
	EventBus.boss_defeated.emit()
