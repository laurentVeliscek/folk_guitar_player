extends Reference
class_name GuitarChord

"""
Represents a guitar chord with its timing, notes, and strumming pattern.

Usage:
	var chord = GuitarChord.new()
	chord.position = 0.0
	chord.notes = [40, 45, 50, 55, 59, 64]  # E minor
	chord.pattern = "D.uDudu"
	chord.step_length = 0.5
"""

# Position temporelle en beats
var position: float = 0.0

# Tableau des pitchs MIDI (6 cordes max, de grave à aiguë)
# Exemple: [40, 45, 50, 55, 59, 64] pour Em
var notes: Array = []

# Pattern rythmique à boucler
# D = Down fort, d = down léger, U = Up fort, u = up léger
# ' ' = silence, '.' = laisser sonner, 'X' = muté
var pattern: String = "Dudu"

# Durée d'un pas de pattern en beats
# 0.5 = croche (défaut), 0.25 = double-croche
var step_length: float = 0.5

# Cordes mutées (true = mutée, false = jouée)
# Si vide, toutes les cordes sont jouées
var muted_strings: Array = []

# Paramètres optionnels pour surcharger les réglages globaux
var override_velocity_base: float = -1.0  # -1 = utiliser global
var override_strum_duration: float = -1.0  # -1 = utiliser global


func _init(pos: float = 0.0, chord_notes: Array = [], chord_pattern: String = "Dudu", step: float = 0.5):
	position = pos
	notes = chord_notes
	pattern = chord_pattern
	step_length = step


func _to_string() -> String:
	return "GuitarChord(pos=%s, notes=%s, pattern='%s', step=%s)" % [position, notes, pattern, step_length]


# Vérifie si une corde est mutée
func is_string_muted(string_index: int) -> bool:
	if muted_strings.empty():
		return false
	if string_index >= muted_strings.size():
		return false
	return muted_strings[string_index]


# Retourne le nombre de cordes actives (non mutées)
func get_active_string_count() -> int:
	if muted_strings.empty():
		return notes.size()

	var count = 0
	for i in range(notes.size()):
		if not is_string_muted(i):
			count += 1
	return count
