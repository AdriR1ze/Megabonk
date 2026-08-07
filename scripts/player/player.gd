extends CharacterBody3D

const SPEED = 8.5
@export var mouse_sensitivity : float = 0.0008

@onready var spawnpoint = $SpawnPoint
@onready var pivot = $pivot
@onready var camera = $pivot/Camera3D
@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh_instance = $MeshInstance3D

var camera_yaw: float = 0.0
var camera_pitch: float = deg_to_rad(-30.0)

var _regen_timer : float = 0.0

func _ready() -> void:
	if _is_mp() and name == "Player":
		return

	add_to_group("player")
	WeaponManager.player = self
	EventBus.run_started.emit()
	await get_tree().process_frame
	ItemManager.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ItemManager.stats_changed.connect(_on_item_stats_changed)
	health_component.max_health = PlayerStats.max_health
	health_component.health = PlayerStats.max_health
	health_component.health_changed.emit(health_component.health, health_component.max_health)

	if _is_mp() and multiplayer.get_unique_id() != 1:
		_emit_local_init()

func _is_mp() -> bool:
	return multiplayer.has_multiplayer_peer()

func _emit_local_init() -> void:
	PlayerStats.reset_for_new_run()
	if not multiplayer.is_server():
		EnemyManager._on_run_started_local()
	if WeaponManager.weapons.is_empty():
		var random_id = randi() % max(1, ArmaDB.get_all_armas().size())
		WeaponManager.add_weapon(ArmaDB.get_arma(random_id))

func _on_item_stats_changed() -> void:
	if health_component.max_health == PlayerStats.max_health:
		return
	var diff := PlayerStats.max_health - health_component.max_health
	health_component.max_health = PlayerStats.max_health
	if diff > 0.0:
		health_component.health = min(health_component.health + diff, PlayerStats.max_health)
	else:
		health_component.health = min(health_component.health, PlayerStats.max_health)
	health_component.health_changed.emit(health_component.health, health_component.max_health)

func _unhandled_input(event: InputEvent) -> void:
	if _is_mp() and not is_multiplayer_authority():
		return
	if get_tree().paused:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_yaw -= event.relative.x * mouse_sensitivity
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-75.0), deg_to_rad(-5.0))

func _physics_process(delta: float) -> void:
	if _is_mp() and not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	pivot.rotation.y = camera_yaw
	pivot.rotation.x = camera_pitch

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward = Vector3(-sin(camera_yaw), 0, -cos(camera_yaw))
	var right   = Vector3(cos(camera_yaw), 0, -sin(camera_yaw))
	var direction = (right * input_dir.x - forward * input_dir.y).normalized()

	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED * PlayerStats.move_speed
		velocity.z = direction.z * SPEED * PlayerStats.move_speed
		if mesh_instance:
			var target_angle = atan2(direction.x, direction.z) + PI
			mesh_instance.rotation.y = lerp_angle(mesh_instance.rotation.y, target_angle, delta * 12.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if PlayerStats.regen > 0.0:
		_regen_timer += delta
		if _regen_timer >= 1.0:
			_regen_timer = 0.0
			health_component.heal(PlayerStats.regen)

func take_damage(amount: float) -> void:
	var final_damage = max(1.0, amount - (PlayerStats.defense - 1.0))

	var escudo = get_tree().get_first_node_in_group("escudo")
	if escudo and escudo.has_method("try_block") and escudo.try_block():
		EventBus.shield_blocked.emit()
		return

	var sobrevida = get_tree().get_first_node_in_group("sobrevida")
	if sobrevida and sobrevida.has_method("absorb"):
		final_damage = sobrevida.absorb(final_damage)

	if health_component:
		if final_damage > 0.0:
			EventBus.player_took_damage.emit()
		health_component.take_damage(final_damage)
