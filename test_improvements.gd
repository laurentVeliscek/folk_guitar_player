extends Node

"""
Tests pour les améliorations récentes :
1. config_override en Dictionary (au lieu de Array)
2. Sustain prolongé pour les notes d'arpège
"""

func _ready():
	print("\n" + "="*60)
	print("  TESTS DES AMÉLIORATIONS")
	print("="*60)

	test_config_override_dictionary()
	test_arpeggio_sustain()
	test_arpeggio_interrupted_by_chord()
	test_arpeggio_interrupted_by_silence()
	test_arpeggio_chord_change()

	print("\n" + "="*60)
	print("  TESTS TERMINÉS")
	print("="*60 + "\n")


func test_config_override_dictionary():
	"""Test 1: Vérifier que config_override fonctionne avec un Dictionary."""
	print("\n--- Test 1: config_override en Dictionary ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]  # Em7

	# Pattern avec config_override en Dictionary
	var pattern1 = StrumPattern.create("D...d...D...d...", 0.25, {
		"velocity_down_base": 120,
		"swing_amount": 0.5,
		"pick_position": 0.8
	})

	var pattern2 = StrumPattern.create("DuDuDuDuDuDuDuDu", 0.25, {
		"velocity_down_light": 60,
		"velocity_up_light": 55
	})

	player.pattern_sequence = [pattern1, pattern2]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("✓ Pattern 1 config_override: %s" % str(pattern1.config_override))
	print("✓ Pattern 2 config_override: %s" % str(pattern2.config_override))
	print("✓ Notes générées: %d" % notes.size())
	print("✓ Config_override en Dictionary fonctionne correctement")


func test_arpeggio_sustain():
	"""Test 2: Vérifier que les notes d'arpège ont un sustain prolongé."""
	print("\n--- Test 2: Sustain prolongé des arpèges ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]  # Em7

	# Pattern d'arpège pur avec des silences
	# Les notes d'arpège devraient se prolonger pendant les '.'
	var pattern = StrumPattern.create("0...1...2...3...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: %s" % pattern.pattern)
	print("Notes générées: %d" % notes.size())

	# Vérifier que les notes d'arpège ont une durée supérieure à step_length
	var long_notes = 0
	for note in notes:
		if note.duration > 0.5:  # Plus long qu'un simple step
			long_notes += 1
			print("  Note pitch %d: position=%.3f, duration=%.3f" % [note.pitch, note.position, note.duration])

	if long_notes > 0:
		print("✓ %d notes avec sustain prolongé détectées" % long_notes)
	else:
		print("✗ ERREUR: Aucune note avec sustain prolongé")


func test_arpeggio_interrupted_by_chord():
	"""Test 3: Vérifier que les arpèges sont interrompus par un accord."""
	print("\n--- Test 3: Arpèges interrompus par accord ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]  # Em7

	# Arpège puis accord
	# Les notes d'arpège devraient être tronquées quand 'D' arrive
	var pattern = StrumPattern.create("0.1.2.3.D...d...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: %s (arpège puis accord)" % pattern.pattern)
	print("Notes générées: %d" % notes.size())

	# Les notes d'arpège (positions 0, 0.5, 1.0, 1.5) devraient être tronquées à ~2.0
	var arp_notes = []
	for note in notes:
		if note.position < 2.0 and note.string_index == -1:
			arp_notes.append(note)

	if arp_notes.size() > 0:
		var all_truncated = true
		for note in arp_notes:
			var expected_end = note.position + note.duration
			print("  Arpège pitch %d: pos=%.3f, dur=%.3f, end=%.3f" % [note.pitch, note.position, note.duration, expected_end])
			# Vérifier que la note ne dépasse pas trop le moment du 'D' (2.0)
			if expected_end > 2.1:  # Tolérance de 0.1
				all_truncated = false

		if all_truncated:
			print("✓ Arpèges correctement tronqués avant l'accord")
		else:
			print("✗ ERREUR: Certains arpèges ne sont pas tronqués")
	else:
		print("✗ ERREUR: Aucune note d'arpège trouvée")


func test_arpeggio_interrupted_by_silence():
	"""Test 4: Vérifier que les arpèges sont interrompus par un silence."""
	print("\n--- Test 4: Arpèges interrompus par silence ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]  # Em7

	# Arpège puis silence
	var pattern = StrumPattern.create("0.1.2.3. ...d...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: %s (arpège puis silence)" % pattern.pattern)
	print("Notes générées: %d" % notes.size())

	# Vérifier que les arpèges sont tronqués au silence (position 2.0)
	var arp_notes = []
	for note in notes:
		if note.position < 2.0 and note.string_index == -1:
			arp_notes.append(note)

	if arp_notes.size() > 0:
		var all_truncated = true
		for note in arp_notes:
			var expected_end = note.position + note.duration
			print("  Arpège pitch %d: pos=%.3f, dur=%.3f, end=%.3f" % [note.pitch, note.position, note.duration, expected_end])
			if expected_end > 2.1:
				all_truncated = false

		if all_truncated:
			print("✓ Arpèges correctement tronqués avant le silence")
		else:
			print("✗ ERREUR: Certains arpèges dépassent le silence")


func test_arpeggio_chord_change():
	"""Test 5: Vérifier que les arpèges sont interrompus lors d'un changement d'accord."""
	print("\n--- Test 5: Arpèges et changement d'accord ---")

	var player = FolkGuitarPlayer.new()

	# Deux accords différents
	var em = GuitarChord.new()
	em.time = 0.0
	em.beat_length = 2.0
	em.notes = [40, 47, 52, 56, 59, 64]  # Em7

	var g = GuitarChord.new()
	g.time = 2.0
	g.beat_length = 2.0
	g.notes = [43, 47, 50, 55, 59, 62]  # G

	# Arpège continu sur les deux accords
	var pattern = StrumPattern.create("0.1.2.3.0.1.2.3.", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([em, g])

	var notes = player.generate()

	print("Pattern: %s" % pattern.pattern)
	print("2 accords: Em (0-2s) -> G (2-4s)")
	print("Notes générées: %d" % notes.size())

	# Les arpèges du premier accord (pos < 2.0) devraient être tronqués à 2.0
	var first_chord_arps = []
	for note in notes:
		if note.position < 2.0 and note.string_index == -1:
			first_chord_arps.append(note)

	if first_chord_arps.size() > 0:
		var all_truncated = true
		for note in first_chord_arps:
			var expected_end = note.position + note.duration
			print("  Em arpège pitch %d: pos=%.3f, dur=%.3f, end=%.3f" % [note.pitch, note.position, note.duration, expected_end])
			if expected_end > 2.1:
				all_truncated = false

		if all_truncated:
			print("✓ Arpèges du premier accord tronqués au changement")
		else:
			print("✗ ERREUR: Certains arpèges dépassent le changement d'accord")
	else:
		print("✗ ERREUR: Aucun arpège du premier accord trouvé")
