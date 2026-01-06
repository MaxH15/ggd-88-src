extends Node2D

var _current_x:float = 0.0
var _spawn_buffer:float = 1400.0
var _despawn_buffer:float = 700.0
var level:String = "level1"
const _CHUNK_DIRECTORY:String = "res://scenes/objects/chunks/"

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if PlayerVariables.player_pos.x > (_current_x - _spawn_buffer):
		_get_random_chunk()
	
	if get_child_count() > 0:
		if get_child(0) is Chunk:
			var first_chunk:Chunk = get_child(0)
			if (first_chunk.position.x + first_chunk.chunk_width) < (PlayerVariables.player_pos.x - _despawn_buffer):
				first_chunk.queue_free()

func _get_random_chunk() -> void:
	var chunks:PackedStringArray = ResourceLoader.list_directory(_CHUNK_DIRECTORY + level + "/")
	var this_chunk:String = _CHUNK_DIRECTORY + level + "/" + chunks.get(randi_range(0, chunks.size() - 1))
	var new_chunk = load(this_chunk).instantiate()
	
	if new_chunk is Chunk:
		new_chunk.position.x = _current_x
		_current_x += new_chunk.chunk_width
		add_child(new_chunk)
	else:
		print("DUUUDE that's not a chunk bro")
