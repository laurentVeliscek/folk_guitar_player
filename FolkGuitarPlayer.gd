extends Reference
class_name FolkGuitarPlayer

"""
Simulates realistic folk guitar strumming patterns with humanized MIDI output.

The player interprets a chord grid by applying a rhythm pattern that loops
throughout the entire grid. It adapts to chords of different sizes (4, 5, or 6 notes).

Usage:
	var player = FolkGuitarPlayer.new()
	player.rhythm_pattern = "DuDuD Du"  # Pattern to loop
	player.step_beat_length = 0.5       # Each step is an eighth note
	player.set_chord_grid(chords_array) # Array of GuitarChord objects
	var midi_notes = player.generate()  # Returns MIDI note events
"""

# Configuration globale - Paramètres de réalisme
var config = {
	"strum_duration_min": 0.015,  # Durée minimale de balayette (en beats)
	"strum_duration_max": 0.030,  # Durée maximale de balayette (en beats)
	"velocity_curve_shape": "gaussian",  # gaussian, linear, flat
	"velocity_randomization": 0.10,  # Facteur de randomisation (0-1)
	"accent_downbeat_factor": 1.15,  # Multiplication vélocité temps forts
	"mute_duration": 0.05,  # Durée des notes mutées (en beats)
	"humanize_timing": false,  # Micro-décalages temporels
	"timing_variance": 0.005,  # Variance temporelle (en beats)
	"velocity_down_base": 100,  # Vélocité de base pour Down fort
	"velocity_down_light": 75,  # Vélocité de base pour down léger
	"velocity_up_base": 95,  # Vélocité de base pour Up fort
	"velocity_up_light": 70,  # Vélocité de base pour up léger
	"note_overlap": 0.02,  # Léger overlap pour éviter les trous (en beats)
}

# Grille d'accords
var chord_grid: Array = []

# Rhythm pattern to loop (defined at player level, not chord level)
# D = Down fort, d = down léger, U = Up fort, u = up léger
# ' ' = silence, '.' = laisser sonner, 'X' = muté
var rhythm_pattern: String = "Dudu"

# Duration of each pattern step in beats (e.g., 0.5 for eighth notes)
var step_beat_length: float = 0.5

# Notes MIDI en sortie
var output_notes: Array = []

# Notes actuellement actives (pour gérer le '.')
var active_notes: Array = []

# Random number generator
var rng = RandomNumberGenerator.new()


func _init():
	rng.randomize()


# ============================================================================
# API PUBLIQUE
# ============================================================================

func set_chord_grid(chords: Array) -> void:
	"""Définit la grille d'accords à jouer."""
	chord_grid = chords


func set_configuration(params: Dictionary) -> void:
	"""Met à jour la configuration avec des paramètres personnalisés."""
	for key in params:
		if config.has(key):
			config[key] = params[key]


func get_configuration() -> Dictionary:
	"""Retourne la configuration actuelle."""
	return config.duplicate()


func generate() -> Array:
	"""
	Génère toutes les notes MIDI à partir de la grille d'accords.
	Retourne un Array de Dictionary avec: pitch, position, duration, velocity, string_index
	"""
	output_notes.clear()
	active_notes.clear()

	if chord_grid.empty():
		push_warning("FolkGuitarPlayer: Chord grid is empty")
		return output_notes

	if rhythm_pattern.empty():
		push_warning("FolkGuitarPlayer: rhythm_pattern is empty")
		return output_notes

	# Trier les accords par time (au cas où)
	var sorted_chords = chord_grid.duplicate()
	sorted_chords.sort_custom(self, "_sort_by_time")

	# Traiter chaque accord
	for chord in sorted_chords:
		var start_time = chord.time
		var end_time = chord.time + chord.beat_length

		_process_chord(chord, start_time, end_time)

	# Trier les notes par position
	output_notes.sort_custom(self, "_sort_notes_by_position")

	return output_notes


func clear() -> void:
	"""Réinitialise le player."""
	chord_grid.clear()
	output_notes.clear()
	active_notes.clear()


# ============================================================================
# TRAITEMENT DES ACCORDS
# ============================================================================

func _process_chord(chord: GuitarChord, start_time: float, end_time: float) -> void:
	"""Traite un accord et génère toutes ses notes selon le pattern du player."""

	var chord_notes = chord.get_notes()
	if chord_notes.empty():
		push_warning("FolkGuitarPlayer: Chord has no notes at time %s" % start_time)
		return

	var current_time = start_time
	var pattern_index = 0
	var beat_position = start_time  # Position en beats depuis le début du morceau (pour accents)

	# Boucler sur le rhythm_pattern du player jusqu'à la fin de l'accord
	while current_time < end_time:
		var symbol = rhythm_pattern[pattern_index]

		# Traiter le symbole
		match symbol:
			'D':  # Down fort
				_generate_strum(chord, current_time, "down", config.velocity_down_base, beat_position, false)
			'd':  # Down léger
				_generate_strum(chord, current_time, "down", config.velocity_down_light, beat_position, false)
			'U':  # Up fort
				_generate_strum(chord, current_time, "up", config.velocity_up_base, beat_position, false)
			'u':  # Up léger
				_generate_strum(chord, current_time, "up", config.velocity_up_light, beat_position, false)
			'X':  # Muté
				_generate_strum(chord, current_time, "down", config.velocity_down_base, beat_position, true)
			'.':  # Laisser sonner
				_prolong_active_notes(step_beat_length)
			' ':  # Silence (ne rien faire, les notes s'arrêteront naturellement)
				pass
			_:
				push_warning("FolkGuitarPlayer: Unknown pattern symbol '%s' at position %s" % [symbol, current_time])

		# Avancer dans le temps
		current_time += step_beat_length
		beat_position += step_beat_length
		pattern_index = (pattern_index + 1) % rhythm_pattern.length()

		# Sécurité: ne pas dépasser la fin de l'accord
		if current_time >= end_time:
			break


# ============================================================================
# GÉNÉRATION DE STRUM
# ============================================================================

func _generate_strum(chord: GuitarChord, time: float, direction: String, base_velocity: float, beat_pos: float, is_muted: bool) -> void:
	"""
	Génère un strum complet (balayette) avec toutes les cordes.

	Args:
		chord: L'accord à jouer
		time: Position temporelle du strum
		direction: "down" ou "up"
		base_velocity: Vélocité de base
		beat_pos: Position en beats (pour déterminer les accents)
		is_muted: Si true, génère des notes très courtes
	"""

	var chord_notes = chord.get_notes()
	var num_chord_notes = chord_notes.size()

	# Calculer la durée du strum
	var strum_duration = _calculate_strum_duration()

	# Déterminer l'ordre des cordes (adaptation automatique à 4, 5, ou 6 notes)
	var string_order = []
	if direction == "down":
		# Graves vers aiguës (0 -> n)
		for i in range(num_chord_notes):
			if not chord.is_string_muted(i):
				string_order.append(i)
	else:  # "up"
		# Aiguës vers graves (n -> 0)
		for i in range(num_chord_notes - 1, -1, -1):
			if not chord.is_string_muted(i):
				string_order.append(i)

	if string_order.empty():
		return

	# Calculer le délai entre chaque corde
	var num_strings = string_order.size()
	var delay_per_string = strum_duration / max(1, num_strings - 1)

	# Déterminer si on est sur un temps fort (accent)
	var accent_factor = 1.0
	if direction == "down":
		# Temps forts = multiples de 1.0 beat (simplification)
		var beat_mod = fmod(beat_pos, 1.0)
		if beat_mod < 0.01:  # Tolérance pour erreurs de floating point
			accent_factor = config.accent_downbeat_factor

	# Générer chaque note du strum
	active_notes.clear()  # Réinitialiser les notes actives

	for i in range(string_order.size()):
		var string_index = string_order[i]
		var pitch = chord_notes[string_index]

		# Calculer le timing de cette corde
		var note_time = time + (i * delay_per_string)

		# Appliquer humanisation temporelle si activée
		if config.humanize_timing:
			var timing_offset = rng.randf_range(-config.timing_variance, config.timing_variance)
			note_time += timing_offset

		# Calculer la vélocité pour cette corde
		var velocity = _calculate_velocity(i, num_strings, base_velocity, accent_factor)

		# Calculer la durée de la note
		var duration = step_beat_length + config.note_overlap
		if is_muted:
			duration = config.mute_duration

		# Créer la note
		var note = {
			"pitch": pitch,
			"position": note_time,
			"duration": duration,
			"velocity": int(clamp(velocity, 1, 127)),
			"string_index": string_index
		}

		output_notes.append(note)

		# Sauvegarder pour gérer le '.'
		if not is_muted:
			active_notes.append(note)


# ============================================================================
# CALCULS DE RÉALISME
# ============================================================================

func _calculate_strum_duration() -> float:
	"""Calcule une durée de strum aléatoire."""
	var min_dur = config.strum_duration_min
	var max_dur = config.strum_duration_max
	return rng.randf_range(min_dur, max_dur)


func _calculate_velocity(string_pos: int, total_strings: int, base_velocity: float, accent_factor: float) -> float:
	"""
	Calcule la vélocité d'une corde selon sa position dans le strum.

	Args:
		string_pos: Position de la corde dans le strum (0 = première jouée)
		total_strings: Nombre total de cordes jouées
		base_velocity: Vélocité de base
		accent_factor: Facteur d'accent (temps forts)
	"""

	var velocity = base_velocity

	# Appliquer la courbe de vélocité selon la position
	if config.velocity_curve_shape == "gaussian":
		velocity *= _gaussian_curve(string_pos, total_strings)
	elif config.velocity_curve_shape == "linear":
		velocity *= _linear_curve(string_pos, total_strings)
	# "flat" = pas de modification

	# Appliquer l'accent
	velocity *= accent_factor

	# Appliquer la randomisation
	if config.velocity_randomization > 0:
		var random_factor = 1.0 + rng.randf_range(-config.velocity_randomization, config.velocity_randomization)
		velocity *= random_factor

	return velocity


func _gaussian_curve(pos: int, total: int) -> float:
	"""
	Courbe gaussienne centrée sur le milieu du strum.
	Les cordes au milieu sont plus fortes.
	"""
	if total <= 1:
		return 1.0

	# Normaliser la position entre 0 et 1
	var normalized_pos = float(pos) / float(total - 1)

	# Gaussienne centrée sur 0.5
	var center = 0.5
	var sigma = 0.3  # Largeur de la courbe
	var gaussian = exp(-pow(normalized_pos - center, 2) / (2 * sigma * sigma))

	# Mapper entre 0.75 et 1.15 pour éviter de trop diminuer les extrémités
	return 0.75 + (gaussian * 0.4)


func _linear_curve(pos: int, total: int) -> float:
	"""
	Courbe linéaire: augmente jusqu'au milieu puis redescend.
	"""
	if total <= 1:
		return 1.0

	var normalized_pos = float(pos) / float(total - 1)

	# Triangle: monte jusqu'à 0.5, puis descend
	if normalized_pos < 0.5:
		return 0.8 + (normalized_pos * 0.8)  # 0.8 -> 1.2
	else:
		return 1.6 - (normalized_pos * 0.8)  # 1.2 -> 0.8


func _prolong_active_notes(duration: float) -> void:
	"""Prolonge les notes actives de la durée spécifiée (symbole '.')."""
	for note in active_notes:
		note.duration += duration


# ============================================================================
# UTILITAIRES
# ============================================================================

func _sort_by_time(a: GuitarChord, b: GuitarChord) -> bool:
	"""Trie les accords par time croissante."""
	return a.time < b.time


func _sort_notes_by_position(a: Dictionary, b: Dictionary) -> bool:
	"""Trie les notes par position croissante."""
	return a.position < b.position


func print_notes(notes: Array = []) -> void:
	"""Affiche les notes pour debug."""
	var notes_to_print = notes if not notes.empty() else output_notes

	print("\n=== MIDI Notes Output (%d notes) ===" % notes_to_print.size())
	for note in notes_to_print:
		print("  Pitch: %3d | Pos: %6.3f | Dur: %5.3f | Vel: %3d | String: %d" % [
			note.pitch,
			note.position,
			note.duration,
			note.velocity,
			note.string_index
		])
	print("="  * 50)


func get_stats() -> Dictionary:
	"""Retourne des statistiques sur les notes générées."""
	if output_notes.empty():
		return {}

	var velocities = []
	var durations = []

	for note in output_notes:
		velocities.append(note.velocity)
		durations.append(note.duration)

	# Calculer min, max, moyenne
	var vel_min = velocities.min()
	var vel_max = velocities.max()
	var vel_avg = 0.0
	for v in velocities:
		vel_avg += v
	vel_avg /= velocities.size()

	var dur_min = durations.min()
	var dur_max = durations.max()
	var dur_avg = 0.0
	for d in durations:
		dur_avg += d
	dur_avg /= durations.size()

	return {
		"total_notes": output_notes.size(),
		"velocity_min": vel_min,
		"velocity_max": vel_max,
		"velocity_avg": vel_avg,
		"duration_min": dur_min,
		"duration_max": dur_max,
		"duration_avg": dur_avg
	}
