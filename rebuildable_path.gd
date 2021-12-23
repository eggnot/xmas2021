extends Path
tool

export(bool) var update_followers = false setget _update_followers

func _update_followers(_value):
	update_followers = false
	
	for node in get_children():
		if node is PathFollow:
			node.offset = node.offset
