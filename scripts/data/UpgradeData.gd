extends Resource
class_name UpgradeData

enum UpgradeType { STAT, NEW_WEAPON, UPGRADE_WEAPON, SYNERGY }

@export var upgrade_name : String = ""
@export var description : String = ""
@export var icon : Texture2D

@export_category("Tipo")
@export var type : UpgradeType = UpgradeType.STAT
@export var rarity : WeaponData.Rarity = WeaponData.Rarity.COMMON

@export_category("Efectos de Estadísticas")
# Cada clave corresponde a una propiedad de PlayerStats que se modifica
# Valores positivos = buff, negativos = nerf
# Ejemplo: {"max_health": 20.0, "move_speed": 0.1}
@export var stat_changes : Dictionary = {}

@export_category("Arma Asociada (si aplica)")
@export var weapon_id : int = -1 # -1 = no aplica
@export var synergy_requires_weapon_ids : Array[int] = []
