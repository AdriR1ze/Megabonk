extends CharacterBody3D

const SPEED = 15.0
const JUMP_VELOCITY = 4.5
@export var bala : PackedScene

@onready var spawnpoint = $SpawnPoint
func _ready() -> void:
	add_to_group("player")
	WeaponManager.player = self
	await get_tree().process_frame
	WeaponManager.add_weapon()
	ItemManager.player = self
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * PlayerStats.move_speed
		velocity.z = direction.z * SPEED * PlayerStats.move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
