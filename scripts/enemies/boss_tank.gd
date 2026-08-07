extends CharacterBody3D

@export var boss_name: String = "TANQUE COLOSAL"
@export var speed: float = 2.5
@export var contact_damage: float = 30.0
@export var slam_damage: float = 40.0
@export var slam_cooldown: float = 5.0
@export var slam_radius: float = 8.0

var player: Node3D = null
var attack_timer: float = 0.0
var slam_timer: float = 0.0
var is_slamming: bool = false

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	player = get_tree().get_first_node_in_group("player")

	if health_component:
		health_component.max_health = 2000.0
		health_component.health = 2000.0
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

	slam_timer += delta

	if is_slamming:
		return

	var dir = (player.global_position - global_position).normalized()
	dir.y = 0

	if dir.length() > 0.01:
		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 4.0)

	velocity = dir * speed
	move_and_slide()

	attack_timer += delta
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("player"):
			if attack_timer >= 0.8:
				attack_timer = 0.0
				if collider.has_method("take_damage"):
					collider.take_damage(contact_damage)

	if slam_timer >= slam_cooldown and not is_slamming:
		_do_ground_slam()

func _do_ground_slam() -> void:
	slam_timer = 0.0
	is_slamming = true

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.3)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.15)
	tween.tween_callback(_apply_slam_damage)
	tween.tween_callback(_end_slam)

func _apply_slam_damage() -> void:
	var bodies = get_tree().get_nodes_in_group("player")
	for body in bodies:
		if is_instance_valid(body) and body.has_method("take_damage"):
			var dist = body.global_position.distance_to(global_position)
			if dist <= slam_radius:
				var falloff = 1.0 - (dist / slam_radius)
				body.take_damage(slam_damage * falloff)

	var area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var col_shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = slam_radius
	col_shape.shape = sphere
	area.add_child(col_shape)
	get_tree().current_scene.add_child(area)
	area.global_position = global_position

	for body in area.get_overlapping_bodies():
		if body and body.is_in_group("player") and body.has_method("take_damage"):
			var dist = body.global_position.distance_to(global_position)
			var falloff = 1.0 - (dist / slam_radius)
			body.take_damage(slam_damage * max(falloff, 0.3))

	area.queue_free()

func _end_slam() -> void:
	is_slamming = false

func take_damage(damage_amount: float, is_critical: bool = false, crit_tier: int = 0) -> void:
	if health_component:
		health_component.take_damage(damage_amount, is_critical, crit_tier)

func _on_health_changed(current: float, max_hp: float) -> void:
	EventBus.boss_health_changed.emit(current, max_hp)

func _on_boss_died() -> void:
	EventBus.boss_defeated.emit()
