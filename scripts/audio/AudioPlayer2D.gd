extends AudioStreamPlayer2D
class_name AudioPlayer2D

@export var path:String
const BASE_PATH:String = "res://assets/sounds/"

func _ready() -> void:
	refresh_sounds(path)

func refresh_sounds(new_path:String) -> void:
	if stream is not AudioStreamRandomizer:
		return
	
	var valid_path:bool = false
	var sounds:PackedStringArray = ResourceLoader.list_directory(BASE_PATH + new_path)
	
	var num_sounds:int = 0
	for res in sounds:
		if res.ends_with("/"):
			continue
		
		var this_res = load(BASE_PATH + new_path + "/" + res)
		if this_res is AudioStream:
			if not valid_path:
				for i in stream.streams_count:
					stream.remove_stream(i)
				valid_path = true
			
			stream.add_stream(num_sounds, this_res)
