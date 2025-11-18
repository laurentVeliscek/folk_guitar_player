extends Node

"""
Démonstration du FolkGuitarPlayer avec le nouveau système de patterns.
Exécutez ce script pour voir les sorties MIDI générées.
"""

func _ready():
	print("\n" + "="*60)
	print("     FOLK GUITAR PLAYER - DEMO")
	print("="*60)

	# Exécuter tous les tests
	test_simple_pattern()
	test_chord_progression()
	test_pattern_with_mutes()
	test_pattern_with_sustain()
	test_funk_rhythm()
	test_custom_configuration()
	test_pick_position()
	test_flam_symbols()

	print("\n" + "="*60)
	print("     DEMO TERMINEE")
	print("="*60 + "\n")


# ============================================================================
# TEST 1: Pattern simple sur un seul accord
# ============================================================================
func test_simple_pattern():
	print("\n--- TEST 1: Pattern Simple (D.d.u.d.u.......) ---")

	var player = FolkGuitarPlayer.new()

	# Créer un accord de Em (Mi mineur)
	var em_chord = GuitarChord.new()
	em_chord.time = 0.0
	em_chord.beat_length = 4.0
	em_chord.notes = [40, 47, 52, 56, 59, 64]  # E B E G B E

	# Pattern de 16 pas
	var pattern = StrumPattern.create("D.d.u.d.u.......", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([em_chord])

	var notes = player.generate()

	print("Accord: Em | Pattern: '%s'" % pattern.pattern)
	print("Notes generees: %d" % notes.size())

	# Afficher quelques notes
	for i in range(min(12, notes.size())):
		var n = notes[i]
		print("  [%2d] Pitch: %3d | Pos: %6.3f | Dur: %5.3f | Vel: %3d" % [
			i, n.pitch, n.position, n.duration, n.velocity
		])

	var stats = player.get_stats()
	print("Velocite: min=%d, max=%d, avg=%.1f" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])


# ============================================================================
# TEST 2: Progression d'accords
# ============================================================================
func test_chord_progression():
	print("\n--- TEST 2: Progression d'Accords (Em - C - G - D) ---")

	var player = FolkGuitarPlayer.new()

	# Pattern commun pour tous les accords
	var pattern = StrumPattern.create("D.uDudu D.uDudu ", 0.25)
	player.pattern_sequence = [pattern]

	# Em
	var em = GuitarChord.new()
	em.time = 0.0
	em.beat_length = 4.0
	em.notes = [40, 47, 52, 56, 59, 64]

	# C (Do majeur)
	var c = GuitarChord.new()
	c.time = 4.0
	c.beat_length = 4.0
	c.notes = [36, 43, 48, 52, 55, 60]

	# G (Sol majeur)
	var g = GuitarChord.new()
	g.time = 8.0
	g.beat_length = 4.0
	g.notes = [43, 47, 50, 55, 59, 62]

	# D (Ré majeur) - corde grave mutée
	var d = GuitarChord.new()
	d.time = 12.0
	d.beat_length = 4.0
	d.notes = [50, 57, 62, 66, 69, 74]
	d.muted_strings = [true, false, false, false, false, false]

	player.set_chord_grid([em, c, g, d])
	var notes = player.generate()

	print("Progression: Em -> C -> G -> D")
	print("Notes generees: %d" % notes.size())
	print("Duree totale: %.1f beats" % (notes[-1].position + notes[-1].duration if notes.size() > 0 else 0))

	var stats = player.get_stats()
	print("Statistiques:")
	print("  Velocite: min=%d, max=%d, avg=%.1f" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])


# ============================================================================
# TEST 3: Pattern avec mutées (X et x)
# ============================================================================
func test_pattern_with_mutes():
	print("\n--- TEST 3: Pattern avec Mutees (D.uXu.dxu.D.uXu.) ---")

	var player = FolkGuitarPlayer.new()

	var am = GuitarChord.new()
	am.time = 0.0
	am.beat_length = 4.0
	am.notes = [45, 52, 57, 60, 64, 69]  # La mineur

	# Pattern avec X (mute fort) et x (mute leger)
	var pattern = StrumPattern.create("D.uXu.dxu.D.uXu.", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([am])

	var notes = player.generate()

	print("Accord: Am | Pattern: '%s'" % pattern.pattern)
	print("Notes generees: %d" % notes.size())

	# Compter les notes mutées (durée très courte)
	var muted_count = 0
	for note in notes:
		if note.duration < 0.1:
			muted_count += 1

	print("Notes mutees detectees: %d" % muted_count)


# ============================================================================
# TEST 4: Pattern avec laisser sonner (.)
# ============================================================================
func test_pattern_with_sustain():
	print("\n--- TEST 4: Pattern avec Laisser Sonner (D...d...D...d...) ---")

	var player = FolkGuitarPlayer.new()

	var g = GuitarChord.new()
	g.time = 0.0
	g.beat_length = 8.0
	g.notes = [43, 47, 50, 55, 59, 62]  # Sol majeur

	# Pattern avec beaucoup de sustain
	var pattern = StrumPattern.create("D...d...D...d...", 0.5)  # 8th notes
	player.pattern_sequence = [pattern]
	player.set_chord_grid([g])

	var notes = player.generate()

	print("Accord: G | Pattern: '%s'" % pattern.pattern)
	print("Notes generees: %d" % notes.size())

	# Les notes devraient avoir des durées prolongées
	print("Durees des premieres notes (devraient etre longues):")
	for i in range(min(6, notes.size())):
		var n = notes[i]
		print("  Note %2d: position=%.3f, duree=%.3f beats" % [
			i, n.position, n.duration
		])


# ============================================================================
# TEST 5: Rythmique funk (double-croches)
# ============================================================================
func test_funk_rhythm():
	print("\n--- TEST 5: Rythmique Funk (double-croches) ---")

	var player = FolkGuitarPlayer.new()

	var e7 = GuitarChord.new()
	e7.time = 0.0
	e7.beat_length = 4.0
	e7.notes = [40, 47, 50, 54, 59, 64]  # E7

	# Pattern funk 16 steps en double-croches
	var pattern = StrumPattern.create("D.ud.udu.ud.uDu.", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([e7])

	var notes = player.generate()

	print("Accord: E7 | Pattern: '%s'" % pattern.pattern)
	print("Step length: %.2f (double-croches)" % pattern.step_beat_length)
	print("Notes generees: %d" % notes.size())
	print("Duree totale: %.2f beats" % pattern.get_duration())


# ============================================================================
# TEST 6: Configuration personnalisée
# ============================================================================
func test_custom_configuration():
	print("\n--- TEST 6: Configuration Personnalisee ---")

	var player = FolkGuitarPlayer.new()

	# Modifier la configuration pour un jeu plus agressif
	player.set_configuration({
		"velocity_down_base": 115,  # Plus fort
		"velocity_randomization": 0.20,  # Plus de variation
		"strum_duration_min": 0.010,  # Plus rapide
		"strum_duration_max": 0.020,
		"accent_downbeat_factor": 1.30,  # Accents très marqués
		"humanize_timing": true,  # Activer l'humanisation temporelle
		"timing_variance": 0.008
	})

	var a = GuitarChord.new()
	a.time = 0.0
	a.beat_length = 4.0
	a.notes = [45, 52, 57, 60, 64, 69]  # La majeur

	var pattern = StrumPattern.create("DuDuDuDuDuDuDuDu", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([a])

	var notes = player.generate()

	print("Configuration: Jeu agressif avec humanisation")
	print("Notes generees: %d" % notes.size())

	var stats = player.get_stats()
	print("Velocite: min=%d, max=%d, avg=%.1f (devrait etre elevee)" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])


# ============================================================================
# TEST 7: Position du médiateur (pick_position)
# ============================================================================
func test_pick_position():
	print("\n--- TEST 7: Position du Mediateur (Pick Position) ---")

	# Créer un accord de test (Em)
	var em = GuitarChord.new()
	em.time = 0.0
	em.beat_length = 4.0
	em.notes = [40, 47, 52, 56, 59, 64]  # E2 B2 E3 G3 B3 E4 (grave -> aigu)

	var pattern = StrumPattern.create("D...............", 0.25)

	# TEST A: Position vers les graves (-1.0)
	print("\n  A) Pick position = -1.0 (GRAVES favorisees)")
	var player_bass = FolkGuitarPlayer.new()
	player_bass.set_configuration({
		"pick_position": -1.0,
		"pick_position_influence": 0.8,
		"velocity_randomization": 0.0,
		"velocity_curve_shape": "flat"
	})
	player_bass.pattern_sequence = [pattern]
	player_bass.set_chord_grid([em])
	var notes_bass = player_bass.generate()

	print("    Corde 0 (E grave): vel=%d" % notes_bass[0].velocity)
	print("    Corde 3 (G):       vel=%d" % notes_bass[3].velocity)
	print("    Corde 5 (E aigu):  vel=%d" % notes_bass[5].velocity)

	# TEST B: Position vers les aiguës (1.0)
	print("\n  B) Pick position = 1.0 (AIGUES favorisees)")
	var player_treble = FolkGuitarPlayer.new()
	player_treble.set_configuration({
		"pick_position": 1.0,
		"pick_position_influence": 0.8,
		"velocity_randomization": 0.0,
		"velocity_curve_shape": "flat"
	})
	player_treble.pattern_sequence = [pattern]
	player_treble.set_chord_grid([em])
	var notes_treble = player_treble.generate()

	print("    Corde 0 (E grave): vel=%d" % notes_treble[0].velocity)
	print("    Corde 3 (G):       vel=%d" % notes_treble[3].velocity)
	print("    Corde 5 (E aigu):  vel=%d" % notes_treble[5].velocity)


# ============================================================================
# TEST 8: Symboles Flam (F et f)
# ============================================================================
func test_flam_symbols():
	print("\n--- TEST 8: Symboles Flam (F et f) ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]

	# Pattern avec F (flam fort) et f (flam leger)
	var pattern = StrumPattern.create("F...f...F...f...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: '%s'" % pattern.pattern)
	print("F = Down-Up fort (DU)")
	print("f = down-up leger (du)")
	print("Notes generees: %d" % notes.size())

	# 4 flams * 2 strums * 6 cordes = 48 notes
	print("Attendu: 48 notes (4 flams x 2 strums x 6 cordes)")

	# Vérifier les positions temporelles
	print("\nPositions temporelles des strums:")
	var unique_times = {}
	for note in notes:
		var time_key = "%.3f" % note.position
		if not unique_times.has(time_key):
			unique_times[time_key] = true

	var times = unique_times.keys()
	times.sort()
	for i in range(min(8, times.size())):
		print("  Strum %d: time = %s" % [i, times[i]])


# ============================================================================
# EXPORT DES NOTES (exemple de fonction utilitaire)
# ============================================================================
func export_to_midi_events(notes: Array) -> Array:
	"""
	Convertit les notes en événements MIDI (Note On / Note Off).
	Utile pour intégration avec votre système MIDI existant.
	"""
	var events = []

	for note in notes:
		# Note On
		events.append({
			"type": "note_on",
			"time": note.position,
			"pitch": note.pitch,
			"velocity": note.velocity,
			"channel": 0
		})

		# Note Off
		events.append({
			"type": "note_off",
			"time": note.position + note.duration,
			"pitch": note.pitch,
			"velocity": 0,
			"channel": 0
		})

	# Trier par temps
	events.sort_custom(self, "_sort_events_by_time")

	return events


func _sort_events_by_time(a: Dictionary, b: Dictionary) -> bool:
	return a.time < b.time
