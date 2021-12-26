extends Node
class_name ScoreManager

const big_asteroid_pts: int = 20
const medium_asteroid_pts: int = 50
const small_asteroid_pts: int = 100
const ufo_large_pts: int = 200
const ufo_small_pts: int = 1000
var score: int
const max_high_scores := 10
const high_scores_filepath = "res://high_scores.json"
var high_scores_file: File
var high_scores

func _ready():
	high_scores = get_high_scores()

func reset():
	score = 0

func update_score(node: Node) -> void:
	if node is Satellite:
		score += big_asteroid_pts
	elif node is SatelliteComponent:
		score += medium_asteroid_pts
	elif node is SatelliteShard:
		score += small_asteroid_pts
	elif node is UFO:
		if node.ufo_type == UFO.ufo_type_enum.LARGE:
			score += ufo_large_pts
		else:
			score += ufo_small_pts

func get_high_scores() -> Array:
	high_scores_file = File.new()
	if not high_scores_file.file_exists(high_scores_filepath):
		print('high scores file not found, creating new file')
		high_scores_file.open(high_scores_filepath, File.WRITE)
		high_scores_file.seek(0)
		high_scores_file.store_line("[]")
		high_scores_file.close()
		return []
	high_scores_file.open(high_scores_filepath, File.READ)
	var scores = parse_json(high_scores_file.get_as_text())
	#print('high scores = %s' % str(scores))
	high_scores_file.close()
	return scores

static func compare_scores(a,b) -> bool:
	return a["score"] > b["score"]

func sort_high_scores() -> void:
	high_scores.sort_custom(self, "compare_scores")

func check_high_score() -> bool:
	if len(high_scores) < max_high_scores:
		return true
	# return true if any of the saved high scores are lower than score
	for i in range(len(high_scores)):
		var saved_score = high_scores[i]["score"]
		if score > saved_score:
			return true
	return false

func save_high_score(name_entry: String) -> void:
	var score_entry = {"name": name_entry, "score":score}
	if len(high_scores) < max_high_scores:
		high_scores.append(score_entry)
		sort_high_scores()
	else:
		sort_high_scores()
		high_scores.pop_back()
		var is_inserted := false
		for i in range(len(high_scores)):
			if high_scores[i]["score"] < score:
				high_scores.insert(i, score_entry)
				is_inserted = true
				break
		if not is_inserted:
			high_scores.push_back(score_entry)
	high_scores_file.open(high_scores_filepath, File.WRITE)
	high_scores_file.seek(0)
	high_scores_file.store_line(JSON.print(high_scores))
	high_scores_file.close()
