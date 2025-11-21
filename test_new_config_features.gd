extends Node

"""
Tests pour les nouvelles fonctionnalités de configuration :
1. max_chords_strings - Limiter le nombre de cordes jouées
2. accent_downbeat_factor pour arpèges et basses
3. get_strum_pattern_at_pos() - Obtenir le pattern à une position donnée
"""

func _ready():
	print("\n" + "="*60)
	print("  TESTS DES NOUVELLES FONCTIONNALITÉS")
	print("="*60)

	test_max_chords_strings()
	test_accent_on_arpeggios_and_bass()
	test_get_strum_pattern_at_pos()

	print("\n" + "="*60)
	print("  TESTS TERMINÉS")
	print("="*60 + "\n")


func test_max_chords_strings():
	"""Test 1: Vérifier que max_chords_strings filtre les cordes graves."""
	print("\n--- Test 1: max_chords_strings (limiter les cordes jouées) ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50, 55, 59, 64]  # 6 notes (Mi grave à Mi aigu)

	# Test avec max_chords_strings = 3 (doit jouer seulement les 3 notes les plus aiguës)
	player.config.max_chords_strings = 3

	var pattern = StrumPattern.create("D...............    ", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Accord avec 6 notes: %s" % str(chord.notes))
	print("max_chords_strings = 3")
	print("Notes générées: %d" % notes.size())

	# Vérifier que seules les 3 notes les plus aiguës sont jouées (55, 59, 64)
	var expected_pitches = [55, 59, 64]
	var all_correct = true

	for note in notes:
		if note.pitch in expected_pitches:
			print("  ✓ Note pitch %d (dans les 3 plus aiguës)" % note.pitch)
		else:
			print("  ✗ Note pitch %d (devrait être filtrée)" % note.pitch)
			all_correct = false

	if all_correct and notes.size() == 3:
		print("✓ Test réussi: Seules les 3 cordes les plus aiguës ont été jouées")
	else:
		print("✗ Test échoué")


func test_accent_on_arpeggios_and_bass():
	"""Test 2: Vérifier que accent_downbeat_factor s'applique aux arpèges et basses."""
	print("\n--- Test 2: accent_downbeat_factor sur arpèges et basses ---")

	var player = FolkGuitarPlayer.new()

	# Configurer un accent plus fort pour les tests
	player.config.accent_downbeat_factor = 1.5
	player.config.single_note_velocity = 80

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]  # Em7

	# Pattern avec basse et arpège sur temps forts (0.0, 1.0, 2.0, 3.0)
	# et sur temps faibles (0.5, 1.5, 2.5, 3.5)
	var pattern = StrumPattern.create("B.0.B.0.B.0.B.0.", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: %s (B et 0 alternés)" % pattern.pattern)
	print("accent_downbeat_factor: %.1f" % player.config.accent_downbeat_factor)
	print("single_note_velocity: %d" % player.config.single_note_velocity)
	print("Vélocité attendue sur temps fort: %d" % int(80 * 1.5))
	print("Vélocité attendue sur temps faible: 80")
	print("\nNotes générées:")

	var found_accented = false
	var found_normal = false

	for note in notes:
		var on_downbeat = (fmod(note.position, 1.0) < 0.01)
		var expected_vel = 80 if not on_downbeat else int(80 * 1.5)
		var symbol = "B" if note.pitch == chord.get_bass_notes()[0] else "0"

		if on_downbeat:
			print("  Pos %.2f (temps fort): %s pitch=%d vel=%d (attendu: %d)" % [
				note.position, symbol, note.pitch, note.velocity, expected_vel
			])
			if note.velocity >= 115:  # 80 * 1.5 = 120, avec clamp à 127
				found_accented = true
		else:
			print("  Pos %.2f (temps faible): %s pitch=%d vel=%d (attendu: %d)" % [
				note.position, symbol, note.pitch, note.velocity, expected_vel
			])
			if note.velocity == 80:
				found_normal = true

	if found_accented and found_normal:
		print("✓ Test réussi: Accents détectés sur temps forts pour arpèges et basses")
	else:
		print("✗ Test échoué: Accents non détectés correctement")
		print("  found_accented=%s, found_normal=%s" % [found_accented, found_normal])


func test_get_strum_pattern_at_pos():
	"""Test 3: Vérifier get_strum_pattern_at_pos()."""
	print("\n--- Test 3: get_strum_pattern_at_pos() ---")

	var player = FolkGuitarPlayer.new()

	# Créer 3 patterns de 4 beats chacun (total = 12 beats)
	var pattern1 = StrumPattern.create("D...d...D...d...", 0.25)  # 4 beats
	var pattern2 = StrumPattern.create("U...u...U...u...", 0.25)  # 4 beats
	var pattern3 = StrumPattern.create("X...x...X...x...", 0.25)  # 4 beats

	player.pattern_sequence = [pattern1, pattern2, pattern3]

	# Créer une chord_grid de 16 beats
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 16.0
	chord.notes = [40, 47, 52, 56, 59, 64]

	player.set_chord_grid([chord])

	print("3 patterns de 4 beats chacun (total patterns: 12 beats)")
	print("Chord_grid durée: 16 beats")
	print("")

	# Tester différentes positions
	var tests = [
		{"pos": 0.0, "expected": "pattern1 (D)", "pattern_ref": pattern1},
		{"pos": 2.0, "expected": "pattern1 (D)", "pattern_ref": pattern1},
		{"pos": 4.0, "expected": "pattern2 (U)", "pattern_ref": pattern2},
		{"pos": 6.0, "expected": "pattern2 (U)", "pattern_ref": pattern2},
		{"pos": 8.0, "expected": "pattern3 (X)", "pattern_ref": pattern3},
		{"pos": 10.0, "expected": "pattern3 (X)", "pattern_ref": pattern3},
		{"pos": 12.0, "expected": "pattern1 (bouclé)", "pattern_ref": pattern1},  # Boucle
		{"pos": 14.0, "expected": "pattern1 (bouclé)", "pattern_ref": pattern1},
		{"pos": -1.0, "expected": "null (hors plage)", "pattern_ref": null},
		{"pos": 20.0, "expected": "null (hors plage)", "pattern_ref": null},
	]

	var all_passed = true

	for test in tests:
		var result = player.get_strum_pattern_at_pos(test.pos)
		var success = (result == test.pattern_ref)

		var symbol = "✓" if success else "✗"
		var result_name = "null" if result == null else ("pattern " + result.pattern[0])

		print("%s Pos %.1f: %s (attendu: %s)" % [
			symbol, test.pos, result_name, test.expected
		])

		if not success:
			all_passed = false

	print("")
	if all_passed:
		print("✓ Test réussi: get_strum_pattern_at_pos() fonctionne correctement")
	else:
		print("✗ Test échoué: Certaines positions ne retournent pas le bon pattern")
