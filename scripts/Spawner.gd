extends Node
# Port ringkas dari ZombieSpawner.cs - spawn musuh mengelilingi pemain.
# Kesulitan naik seiring waktu (baca Waktu.detik / GameTimer.Detik).

var player: Node2D = null

var jeda_awal := 0.9
var jarak := 950.0
var maks_awal := 22
var maks_mutlak := 90
var sekaligus := 2

var _timer := 0.0
var _elapsed := 0.0

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	var W = get_node_or_null("/root/Waktu")
	if W != null:
		_elapsed = W.detik
	else:
		_elapsed += delta
	var level := 1 + int(_elapsed / 20.0)
	var jeda_now := maxf(0.25, jeda_awal - 0.06 * (level - 1))
	var maks_now := mini(maks_mutlak, maks_awal + 5 * (level - 1))
	_timer += delta
	if _timer >= jeda_now:
		_timer = 0.0
		for i in sekaligus:
			_spawn(level, maks_now)

func _spawn(level: int, maks_now: int) -> void:
	if get_tree().get_nodes_in_group("musuh").size() >= maks_now:
		return
	var a := randf() * TAU
	var pos := player.global_position + Vector2(cos(a), sin(a)) * jarak
	var e = preload("res://scripts/Enemy.gd").new()
	var spd := 90.0 + randf() * 55.0 + float(level) * 4.0
	var life := 1 + int(level / 3)
	e.setup(player, spd, life, 10, 30.0)
	var main = get_tree().get_first_node_in_group("main")
	if main == null:
		return
	main.add_child(e)
	e.global_position = pos
