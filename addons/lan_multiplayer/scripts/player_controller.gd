extends Node

#Functions for you: func_and_sync()

export(NodePath) var camera_path

export(Array, NodePath) var nodes
export(Array, String) var properties

export(Array, NodePath) var Nodes
export(Array, String) var functions

#AUTHORITY AND CONNECTION CONTROL
func _enter_tree():
	get_parent().set_network_master(get_parent().name.to_int())

func _ready():
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	
	set_process(false)
	
	# Wait to continue...

func _continue_ready():
	if not get_parent().is_network_master():
		for i in nodes.size():
			var node = get_node(nodes[i])
			if node.has_method("_process"):
				node.call_deferred("set_process", false)
			if node.has_method("_physics_process"):
				node.call_deferred("set_physics_process", false)
		for i in nodes.size():
			var node = get_node(nodes[i])
			if node.has_method("_process"):
				node.call_deferred("set_process", false)
			if node.has_method("_physics_process"):
				node.call_deferred("set_physics_process", false)
		if get_node_or_null(camera_path):
			get_node_or_null(camera_path).queue_free()
			
	set_process(true)

func _on_server_disconnected():
	set_process(false)

func _process(_delta):
	if get_parent().is_network_master():
		for i in nodes.size():
			rpc("unreliable", nodes[i], properties[i], get_node(nodes[i])[properties[i]])
		var camera = get_node_or_null(camera_path)
		if camera:
			if not camera.current:
				camera.current = true

remote func unreliable(node_path, property, value):
	get_node(node_path)[property] = value

#FUNCTIONS SYNC
func func_and_sync(function_name, v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	if get_parent().is_network_master():
		rpc("function", function_name, v1, v2, v3, v4, v5, v6, v7, v8)

sync func function(function_name, v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	var array = []
	for i in [v1, v2, v3, v4, v5, v6, v7, v8]:
		if i != null:
			array.append(i)
	for i in functions.size():
		if functions[i] == function_name:
			get_node(Nodes[i]).callv(function_name, array)
