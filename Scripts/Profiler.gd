class_name Profiler

var timers = {}
var last_time
var active

func _init(_active):
	last_time = Time.get_ticks_msec()
	active = _active
func measure(name):
	if active:
		var current_time = Time.get_ticks_msec()
		if name != '':
			printt(name,current_time-last_time)
		last_time = current_time
		return current_time-last_time
