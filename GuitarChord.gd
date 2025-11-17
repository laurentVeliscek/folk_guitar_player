extends Reference
class_name GuitarChord

"""
Represents a guitar chord with its timing and notes.
The interpretation (rhythm pattern) is handled by FolkGuitarPlayer.

Usage:
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0  # Duration of the chord (whole note)
	chord.notes = [40, 45, 50, 55, 59, 64]  # E minor (6 notes)
	# or
	chord.midiNotes = PoolIntArray([64, 67, 71, 76])  # 4-note chord
"""

# Position temporelle en beats (start time of the chord)
var time: float = 0.0

# Durée de l'accord en beats (how long this chord lasts)
var beat_length: float = 4.0

# Tableau des pitchs MIDI (de grave à aiguë)
# Can be 4, 5, or 6 notes
var notes: Array = []

# Alternative: PoolIntArray pour compatibilité avec ton code existant
var midiNotes: PoolIntArray = PoolIntArray()

# Cordes mutées (true = mutée, false = jouée)
# Si vide, toutes les cordes sont jouées
var muted_strings: Array = []


func _init(chord_time: float = 0.0, chord_notes: Array = [], chord_beat_length: float = 4.0):
	time = chord_time
	notes = chord_notes
	beat_length = chord_beat_length


func _to_string() -> String:
	var note_array = notes if not notes.empty() else Array(midiNotes)
	return "GuitarChord(time=%s, beat_length=%s, notes=%s)" % [time, beat_length, note_array]


# Vérifie si une corde est mutée
func is_string_muted(string_index: int) -> bool:
	if muted_strings.empty():
		return false
	if string_index >= muted_strings.size():
		return false
	return muted_strings[string_index]


# Retourne le nombre de cordes actives (non mutées)
func get_active_string_count() -> int:
	var note_count = notes.size() if not notes.empty() else midiNotes.size()

	if muted_strings.empty():
		return note_count

	var count = 0
	for i in range(note_count):
		if not is_string_muted(i):
			count += 1
	return count


# Retourne les notes en Array (gère à la fois notes et midiNotes)
func get_notes() -> Array:
	if not notes.empty():
		return notes
	elif not midiNotes.empty():
		return Array(midiNotes)
	else:
		return []
