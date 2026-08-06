class_name EscudoAbsorbente
extends Node3D

var max_charges := 1
var charges := 1
var cooldown := 10.0

var _timer: Timer
var _mesh: MeshInstance3D
var _mat: StandardMaterial3D

const COLOR_READY := Color(0.3, 0.65, 1.0, 0.35)
const COLOR_COOLDOWN := Color(0.2, 0.25, 0.3, 0.15)

func _ready() -> void:
	add_to_group("escudo")
	charges = max_charges
	_build_visual()
	_timer = Timer.new()
	_timer.wait_time = cooldown
	_timer.timeout.connect(_on_refill)
	add_child(_timer)
	_timer.start()
	EventBus.shield_status_changed.emit(charges > 0)

func _build_visual() -> void:
	_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.9
	sphere.height = 1.8
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = COLOR_READY
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere.material = _mat
	_mesh.mesh = sphere
	_mesh.position = Vector3(0, 0.9, 0)
	add_child(_mesh)

func try_block() -> bool:
	if charges <= 0:
		return false
	charges -= 1
	_update_visual()
	EventBus.shield_status_changed.emit(charges > 0)
	return true

func _on_refill() -> void:
	charges = max_charges
	_update_visual()
	EventBus.shield_status_changed.emit(charges > 0)

func refresh() -> void:
	charges = min(charges, max_charges)
	_update_visual()
	EventBus.shield_status_changed.emit(charges > 0)

func _update_visual() -> void:
	if _mat:
		_mat.albedo_color = COLOR_READY if charges > 0 else COLOR_COOLDOWN
