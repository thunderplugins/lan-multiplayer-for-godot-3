extends Control

# Info
var info: String
var ip: String
var port: int

# Signals
signal chose()

# Management
func _on_Button_pressed():
	emit_signal("chose", ip, port)
