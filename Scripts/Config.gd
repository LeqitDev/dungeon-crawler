class_name Config

const conf_path = "res://Data/Config.json"
var data


# Called when the node enters the scene tree for the first time.
func _init():
	getConfigData()

func getConfigData():
	var json_data
	var file_data = File.new()
	
	file_data.open(conf_path, File.READ)
	json_data = JSON.parse(file_data.get_as_text())
	file_data.close()
	data = json_data.result

func setConfigData():
	var file_data = File.new()
	
	file_data.open(conf_path, File.WRITE)
	file_data.store_string(JSON.print(data))
	file_data.close()

func getProp(key: String):
	return data[key]

func setProp(key: String, val):
	data[key] = val
