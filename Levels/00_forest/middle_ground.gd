extends TileMapLayer
class_name BreakableTileMap

@export var break_delay: float = 1.1
@export var respawn_delay: float = 3.0
@export var shake_intensity: float = 2.0

var breaking_tiles: Dictionary = {}


func _ready() -> void:
	add_to_group("breakable_tilemaps")
	fix_collision()


func _exit_tree() -> void:
	# Ruim dummy sprites op
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()


func fix_collision() -> void:
	var old = tile_set
	tile_set = null
	await get_tree().process_frame
	if is_inside_tree():
		tile_set = old


func break_tile(cell: Vector2i) -> void:
	if !is_inside_tree():
		return

	var source_id := get_cell_source_id(cell)
	if source_id == -1 or breaking_tiles.has(cell):
		return

	# Tile data opslaan
	breaking_tiles[cell] = {
		"source_id": source_id,
		"atlas_coords": get_cell_atlas_coords(cell),
		"alternative_tile": get_cell_alternative_tile(cell)
	}

	# Dummy sprite maken
	var tile_set_source: TileSetAtlasSource = tile_set.get_source(source_id)
	var dummy_sprite := Sprite2D.new()
	dummy_sprite.texture = tile_set_source.texture
	dummy_sprite.region_enabled = true
	dummy_sprite.region_rect = tile_set_source.get_tile_texture_region(breaking_tiles[cell]["atlas_coords"])

	var parent := get_parent()
	if parent == null:
		return
	parent.add_child(dummy_sprite)

	var tile_world_pos := map_to_local(cell) + global_position
	dummy_sprite.global_position = tile_world_pos

	# Start het proces (async door await)
	_break_process(cell, dummy_sprite, tile_world_pos)


func _break_process(cell: Vector2i, dummy_sprite: Sprite2D, tile_world_pos: Vector2) -> void:
	var time_passed := 0.0

	# Shake fase
	while time_passed < break_delay:
		if !is_inside_tree():
			return

		var random_offset := Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		dummy_sprite.global_position = tile_world_pos + random_offset

		await get_tree().physics_frame
		if !is_inside_tree():
			return

		time_passed += get_process_delta_time()

	# Tile verwijderen
	if is_inside_tree():
		set_cell(cell, -1)

	# Dummy sprite verwijderen
	if is_instance_valid(dummy_sprite):
		dummy_sprite.queue_free()

	# Respawn timer
	var timer := get_tree().create_timer(respawn_delay)
	await timer.timeout
	if !is_inside_tree():
		return

	# Tile terugzetten
	if breaking_tiles.has(cell):
		var data = breaking_tiles[cell]
		set_cell(cell, data["source_id"], data["atlas_coords"], data["alternative_tile"])
		breaking_tiles.erase(cell)
