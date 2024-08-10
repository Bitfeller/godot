class_name StorageObject extends Node

# STORAGE VARIABLES
var SLOTS = 50
var storage = {}

# STORAGE FUNCTIONS
func get_storage() -> Dictionary:
	return storage
func clear_storage() -> bool:
	for slot in storage.keys():
		storage[slot] = null
	return true
func add_to_storage(item, num, slotnum = null) -> bool:
	if Resources.Items[item]:
		# slotnum
		if slotnum:
			if storage[slotnum] and storage[slotnum].name == item:
				storage[slotnum].num += num
			elif storage[slotnum] == null:
				storage[slotnum] = {
					"name": item,
					"num": num
				}
			# overflow
			var overflow = storage[slotnum].num - Resources.Items[item].max_stack
			if overflow > 0:
				return add_to_storage(item, overflow)
			return true
		var idx
		var firstNull
		for slot in storage.keys():
			if storage[slot] == null:
				firstNull = slot
			if storage[slot].name == item:
				idx = slot
				storage[slot].num += num
				break
		if not idx:
			if not firstNull:
				return false # full
			idx = firstNull
			storage[firstNull] = {
				"name": item,
				"num": num
			}
		# overflow
		var overflow = storage[idx].num - Resources.Items[item].max_stack
		if overflow > 0:
			return add_to_storage(item, overflow)
	else:
		return false
	return true
func remove_from_storage(item, num, slotnum = null) -> bool:
	# slotnum handle
	if slotnum:
		if storage[slotnum] and storage[slotnum].name == item:
			if num == "all":
				storage[slotnum] = null
			else:
				storage[slotnum].num -= num
				if storage[slotnum].num <= 0:
					storage[slotnum] = null
			return true
		else:
			return false
	for slot in storage:
		if storage[slot].name == item:
			if num == "all":
				storage[slot] = null
			else:
				storage[slot].num -= num
				if storage[slot].num <= 0:
					storage[slot] = null
			return true
	return false

func _init_storage():
	# init storage
	for i in range(SLOTS):
		storage[str(i)] = null
