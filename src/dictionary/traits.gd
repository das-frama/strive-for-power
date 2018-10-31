static func list():
	return global.read_json("res://assets/data/traits.json")

static func get(key):
	var list = list()
	if list.has(key):
		return list[key]
	else:
		return null

static func get_by_tags(tags):
    assert(typeof(tags) == TYPE_ARRAY)

    var result = []
    var traits = global.read_json("res://assets/data/traits.json")
    for key in traits:
        var trait = traits[key]
        if trait.tags.has_all(tags):
            result.append(trait)
    
    return result

static func get_any():
    var result = []
    var traits = global.read_json("res://assets/data/traits.json")
    for key in traits:
        var trait = traits[key]
        # Keep as was before.
        if not trait.tags.has("secondary"):
            result.append(key)

    return result


