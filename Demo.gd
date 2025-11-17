extends Node

"""
Démonstration du FolkGuitarPlayer avec plusieurs exemples de test.
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

	print("\n" + "="*60)
	print("     DEMO TERMINÉE")
	print("="*60 + "\n")


# ============================================================================
# TEST 1: Pattern simple sur un seul accord
# ============================================================================
func test_simple_pattern():
	print("\n--- TEST 1: Pattern Simple (D d u d u ) ---")

	var player = FolkGuitarPlayer.new()

	# Créer un accord de Em (Mi mineur)
	var em_chord = GuitarChord.new()
	em_chord.position = 0.0
	em_chord.notes = [40, 47, 52, 56, 59, 64]  # E B E G B E
	em_chord.pattern = "D d u d u "
	em_chord.step_length = 0.5

	player.set_chord_grid([em_chord])
	var notes = player.generate()

	print("Accord: Em | Pattern: '%s'" % em_chord.pattern)
	print("Notes générées: %d" % notes.size())

	# Afficher quelques notes
	for i in range(min(12, notes.size())):
		var n = notes[i]
		print("  [%2d] Pitch: %3d | Pos: %6.3f | Dur: %5.3f | Vel: %3d" % [
			i, n.pitch, n.position, n.duration, n.velocity
		])

	var stats = player.get_stats()
	print("Vélocité: min=%d, max=%d, avg=%.1f" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])


# ============================================================================
# TEST 2: Progression d'accords
# ============================================================================
func test_chord_progression():
	print("\n--- TEST 2: Progression d'Accords (Em - C - G - D) ---")

	var player = FolkGuitarPlayer.new()

	# Em
	var em = GuitarChord.new()
	em.position = 0.0
	em.notes = [40, 47, 52, 56, 59, 64]
	em.pattern = "D.uDudu"
	em.step_length = 0.5

	# C (Do majeur)
	var c = GuitarChord.new()
	c.position = 4.0
	c.notes = [36, 43, 48, 52, 55, 60]
	c.pattern = "D.uDudu"
	c.step_length = 0.5

	# G (Sol majeur)
	var g = GuitarChord.new()
	g.position = 8.0
	g.notes = [43, 47, 50, 55, 59, 62]
	g.pattern = "D.uDudu"
	g.step_length = 0.5

	# D (Ré majeur)
	var d = GuitarChord.new()
	d.position = 12.0
	d.notes = [50, 57, 62, 66, 69, 74]  # Corde grave mutée
	d.pattern = "D.uDudu"
	d.step_length = 0.5
	d.muted_strings = [true, false, false, false, false, false]

	player.set_chord_grid([em, c, g, d])
	var notes = player.generate()

	print("Progression: Em -> C -> G -> D")
	print("Notes générées: %d" % notes.size())
	print("Durée totale: %.1f beats" % (notes[-1].position + notes[-1].duration if notes.size() > 0 else 0))

	var stats = player.get_stats()
	print("Statistiques:")
	print("  Vélocité: min=%d, max=%d, avg=%.1f" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])
	print("  Durée notes: min=%.3f, max=%.3f, avg=%.3f" % [
		stats.duration_min, stats.duration_max, stats.duration_avg
	])


# ============================================================================
# TEST 3: Pattern avec mutées (X)
# ============================================================================
func test_pattern_with_mutes():
	print("\n--- TEST 3: Pattern avec Mutées (DuXuDuXu) ---")

	var player = FolkGuitarPlayer.new()

	var am = GuitarChord.new()
	am.position = 0.0
	am.notes = [45, 52, 57, 60, 64, 69]  # La mineur
	am.pattern = "DuXuDuXu"
	am.step_length = 0.5

	player.set_chord_grid([am])
	var notes = player.generate()

	print("Accord: Am | Pattern: '%s'" % am.pattern)
	print("Notes générées: %d" % notes.size())

	# Compter les notes mutées (durée très courte)
	var muted_count = 0
	for note in notes:
		if note.duration < 0.1:
			muted_count += 1

	print("Notes mutées détectées: %d" % muted_count)

	# Afficher quelques exemples
	print("Exemples de notes:")
	for i in range(min(18, notes.size())):
		var n = notes[i]
		var type_str = "MUTE" if n.duration < 0.1 else "NORM"
		print("  [%2d] %s | Pitch: %3d | Pos: %6.3f | Dur: %5.3f" % [
			i, type_str, n.pitch, n.position, n.duration
		])


# ============================================================================
# TEST 4: Pattern avec laisser sonner (.)
# ============================================================================
func test_pattern_with_sustain():
	print("\n--- TEST 4: Pattern avec Laisser Sonner (D...d...) ---")

	var player = FolkGuitarPlayer.new()

	var g = GuitarChord.new()
	g.position = 0.0
	g.notes = [43, 47, 50, 55, 59, 62]  # Sol majeur
	g.pattern = "D...d..."
	g.step_length = 0.5

	player.set_chord_grid([g])
	var notes = player.generate()

	print("Accord: G | Pattern: '%s'" % g.pattern)
	print("Notes générées: %d" % notes.size())

	# Les notes devraient avoir des durées prolongées
	print("Durées des premières notes (devraient être longues):")
	for i in range(min(12, notes.size())):
		var n = notes[i]
		print("  Note %2d: position=%.3f, durée=%.3f beats" % [
			i, n.position, n.duration
		])


# ============================================================================
# TEST 5: Rythmique funk (double-croches)
# ============================================================================
func test_funk_rhythm():
	print("\n--- TEST 5: Rythmique Funk (double-croches) ---")

	var player = FolkGuitarPlayer.new()

	var e7 = GuitarChord.new()
	e7.position = 0.0
	e7.notes = [40, 47, 50, 54, 59, 64]  # E7
	e7.pattern = "D.ud.udu .ud.uDu"  # Pattern funk 16 steps
	e7.step_length = 0.25  # Double-croches

	player.set_chord_grid([e7])
	var notes = player.generate()

	print("Accord: E7 | Pattern: '%s'" % e7.pattern)
	print("Step length: %.2f (double-croches)" % e7.step_length)
	print("Notes générées: %d" % notes.size())
	print("Durée totale: %.2f beats" % (e7.pattern.length() * e7.step_length))


# ============================================================================
# TEST 6: Configuration personnalisée
# ============================================================================
func test_custom_configuration():
	print("\n--- TEST 6: Configuration Personnalisée ---")

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
	a.position = 0.0
	a.notes = [45, 52, 57, 60, 64, 69]  # La majeur
	a.pattern = "DuDuDuDu"
	a.step_length = 0.5

	player.set_chord_grid([a])
	var notes = player.generate()

	print("Configuration: Jeu agressif avec humanisation")
	print("Notes générées: %d" % notes.size())

	var stats = player.get_stats()
	print("Vélocité: min=%d, max=%d, avg=%.1f (devrait être élevée)" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])

	# Vérifier la variation temporelle
	if notes.size() >= 2:
		print("\nVariation temporelle détectée:")
		for i in range(min(6, notes.size())):
			var n = notes[i]
			var expected = a.position + (i * player.config.strum_duration_min)
			var deviation = abs(n.position - expected)
			print("  Note %d: position=%.5f (déviation: %.5f)" % [i, n.position, deviation])


# ============================================================================
# TEST 7: Position du médiateur (pick_position)
# ============================================================================
func test_pick_position():
	print("\n--- TEST 7: Position du Médiateur (Pick Position) ---")

	# Créer un accord de test (Em)
	var em = GuitarChord.new()
	em.position = 0.0
	em.notes = [40, 47, 52, 56, 59, 64]  # E2 B2 E3 G3 B3 E4 (grave -> aigu)
	em.pattern = "D"  # Un seul strum down pour simplifier
	em.step_length = 1.0

	# TEST A: Position vers les graves (-1.0)
	print("\n  A) Pick position = -1.0 (GRAVES favorisées)")
	var player_bass = FolkGuitarPlayer.new()
	player_bass.set_configuration({
		"pick_position": -1.0,
		"pick_position_influence": 0.8,
		"velocity_randomization": 0.0,  # Désactiver random pour voir l'effet pur
		"velocity_curve_shape": "flat"  # Courbe plate pour isoler l'effet
	})
	player_bass.set_chord_grid([em])
	var notes_bass = player_bass.generate()

	print("    Corde 0 (E grave): vel=%d" % notes_bass[0].velocity)
	print("    Corde 3 (G):       vel=%d" % notes_bass[3].velocity)
	print("    Corde 5 (E aigu):  vel=%d" % notes_bass[5].velocity)
	print("    => Les graves devraient être plus fortes")

	# TEST B: Position neutre (0.0)
	print("\n  B) Pick position = 0.0 (NEUTRE)")
	var player_neutral = FolkGuitarPlayer.new()
	player_neutral.set_configuration({
		"pick_position": 0.0,
		"pick_position_influence": 0.8,
		"velocity_randomization": 0.0,
		"velocity_curve_shape": "flat"
	})
	player_neutral.set_chord_grid([em.duplicate()])
	var notes_neutral = player_neutral.generate()

	print("    Corde 0 (E grave): vel=%d" % notes_neutral[0].velocity)
	print("    Corde 3 (G):       vel=%d" % notes_neutral[3].velocity)
	print("    Corde 5 (E aigu):  vel=%d" % notes_neutral[5].velocity)
	print("    => Toutes les cordes devraient être proches")

	# TEST C: Position vers les aiguës (1.0)
	print("\n  C) Pick position = 1.0 (AIGUËS favorisées)")
	var player_treble = FolkGuitarPlayer.new()
	player_treble.set_configuration({
		"pick_position": 1.0,
		"pick_position_influence": 0.8,
		"velocity_randomization": 0.0,
		"velocity_curve_shape": "flat"
	})
	player_treble.set_chord_grid([em.duplicate()])
	var notes_treble = player_treble.generate()

	print("    Corde 0 (E grave): vel=%d" % notes_treble[0].velocity)
	print("    Corde 3 (G):       vel=%d" % notes_treble[3].velocity)
	print("    Corde 5 (E aigu):  vel=%d" % notes_treble[5].velocity)
	print("    => Les aiguës devraient être plus fortes")

	# TEST D: Effet de la direction (Down vs Up)
	print("\n  D) Effet de la direction du strum")
	var em_up = em.duplicate()
	em_up.pattern = "U"  # Strum up

	var player_dir = FolkGuitarPlayer.new()
	player_dir.set_configuration({
		"pick_position": 0.0,  # Position neutre pour voir l'effet de la direction seule
		"pick_position_influence": 0.8,
		"velocity_randomization": 0.0,
		"velocity_curve_shape": "flat"
	})

	print("    Down strum:")
	player_dir.set_chord_grid([em])
	var notes_down = player_dir.generate()
	print("      Corde 0 (grave): vel=%d" % notes_down[0].velocity)
	print("      Corde 5 (aigu):  vel=%d" % notes_down[5].velocity)

	print("    Up strum:")
	player_dir.set_chord_grid([em_up])
	var notes_up = player_dir.generate()
	# Avec Up, l'ordre est inversé (aiguë vers grave)
	print("      Corde 5 (aigu):  vel=%d" % notes_up[0].velocity)
	print("      Corde 0 (grave): vel=%d" % notes_up[5].velocity)
	print("    => Down favorise graves, Up favorise aiguës")


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
