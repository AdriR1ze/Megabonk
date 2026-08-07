extends Area3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D

var bob_height: float = 0.4
var bob_speed: float = 2.5
var start_y: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	start_y = global_position.y
	_setup_material()

func _setup_material() -> void:
	if not mesh_instance or not mesh_instance.mesh:
		return
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.75, 0.1, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.6, 0.0)
	mat.emission_energy_multiplier = 3.0
	mesh_instance.material_override = mat

func _process(delta: float) -> void:
	global_position.y = start_y + sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_height
	rotation.y += delta * 2.5

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_give_item()
		queue_free()

func _give_item() -> void:
	var items = ItemDB.get_all_items()
	var pool: Array = []
	for it in items:
		if it is Item and (it.rarity == 2 or it.rarity == 3):
			pool.append(it)

	if pool.is_empty():
		return

	var item: Item = pool.pick_random()
	ItemManager.agregar_item(item.id)
	EventBus.item_picked.emit(item.id)
