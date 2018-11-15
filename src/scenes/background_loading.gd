extends Control

var current_scene = null
var thread = null

onready var Progress = $Margin/Progress

const SIMULATED_DELAY = 1000.0 # Milliseconds

func _thread_load(path):
	var ril = ResourceLoader.load_interactive(path)
	assert(ril)
	var total = ril.get_stage_count()
	# Call deferred to configure max load steps
	Progress.call_deferred("set_max", total)
	
	var resource = null
	
	while true: #iterate until we have a resource
		# Update progress bar, use call deferred, which routes to main thread
		Progress.call_deferred("set_value", ril.get_stage())
		# Simulate a delay
		# OS.delay_msec(SIMULATED_DELAY)
		# Poll (does a load step)
		var err = ril.poll()
		# if OK, then load another one. If EOF, it' s done. Otherwise there was an error.
		if err == ERR_FILE_EOF:
			# Loading done, fetch resource.
			resource = ril.get_resource()
			break
		elif err != OK:
			# Not OK, there was an error.
			print("There was an error loading")
			break
	
	# Send whathever we did (or not) get.
	call_deferred("_thread_done", resource)

func _thread_done(resource):
	assert(resource)
	
	# Always wait for threads to finish, this is required on Windows.
	thread.wait_to_finish()
	
	# Instantiate new scene.
	var new_scene = resource.instance()
	# Free current scene.
	get_tree().current_scene.free()
	get_tree().current_scene = null
	# Add new one to root.
	get_tree().root.add_child(new_scene) 
	# Set as current scene.
	get_tree().current_scene = new_scene
	queue_free()

func load_scene(path):
	thread = Thread.new()
	thread.start(self, "_thread_load", path)
	raise() # Show on top.
