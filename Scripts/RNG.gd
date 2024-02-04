extends Node



class_name RNG
var initial_seed = '69420'
var rng = RandomNumberGenerator.new()

func rand_int(inputs, _min, _max):
	var _seed = str(inputs)+initial_seed 
	_seed = quick_hash(_seed)
	if _seed <0:
		_seed = -_seed
	rng.seed = _seed
	#var val = (_seed)% (_max - _min + 1) + _min
	var val = rng.randi_range(_min, _max)
	printt(inputs, _seed, val)
	return val

func rand_float(inputs):
	var _seed = str(inputs)+initial_seed 
	_seed = quick_hash(_seed)
	if _seed <0:
		_seed = -_seed
	#return float(seed)/0xFFFFFFFF
	rng.seed = _seed
	return rng.randf()
	
func quick_hash(data):
	var hash_value = 538179  # Initial hash value (can be any prime number)
	for byte in data.to_ascii_buffer():
		byte = int(byte)
		if hash_value <0:
			hash_value = -hash_value
		hash_value = ((hash_value << 5) + hash_value) + (byte<<3)  # hash * 33 + byte
	return hash_value & 0xFFFFFFFF
