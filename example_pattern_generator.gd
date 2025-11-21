extends Node

"""
Exemple d'utilisation de GuitarPatternGenerator

Montre comment générer dynamiquement des patterns aléatoires
pour créer des progressions variées et intéressantes.
"""

func _ready():
	print("\n" + "="*80)
	print("  EXEMPLE: Génération dynamique de patterns")
	print("="*80 + "\n")

	example_random_progression()
	example_multi_style_mix()
	example_evolving_pattern()


func example_random_progression():
	"""Exemple 1: Progression avec patterns aléatoires par accord."""
	print("\n--- Exemple 1: Progression G-C-Am-D avec patterns aléatoires ---\n")

	var generator = GuitarPatternGenerator.new()
	var player = FolkGuitarPlayer.new()

	# Progression d'accords
	var chords = []

	var g = GuitarChord.new()
	g.time = 0.0
	g.beat_length = 4.0
	g.notes = [43, 47, 50, 55, 59, 62]  # G
	chords.append(g)

	var c = GuitarChord.new()
	c.time = 4.0
	c.beat_length = 4.0
	c.notes = [36, 43, 48, 52, 55, 60]  # C
	chords.append(c)

	var am = GuitarChord.new()
	am.time = 8.0
	am.beat_length = 4.0
	am.notes = [40, 47, 52, 57, 60, 64]  # Am
	chords.append(am)

	var d = GuitarChord.new()
	d.time = 12.0
	d.beat_length = 4.0
	d.notes = [50, 50, 50, 54, 57, 62]  # D
	chords.append(d)

	player.set_chord_grid(chords)

	# Générer un pattern Folk différent pour chaque accord
	var patterns = []
	for i in range(4):
		var result = generator.generate("Folk")
		var pattern = StrumPattern.create(result.pattern, result.step_beat_length)
		patterns.append(pattern)
		print("Accord #%d: [%s]" % [i + 1, result.pattern])

	player.pattern_sequence = patterns

	# Générer et afficher
	var notes = player.generate()
	print("\nNotes MIDI générées: %d" % notes.size())

	var tab = player.generate_ascii_tab(4, 80, true)
	print("\nTablature:\n")
	print(tab)


func example_multi_style_mix():
	"""Exemple 2: Mélange de styles (intro folk, couplet funky, refrain R'n B)."""
	print("\n--- Exemple 2: Mélange de styles ---\n")

	var generator = GuitarPatternGenerator.new()

	# Intro (4 beats) : Folk calme
	var intro = generator.generate("Folk")
	print("Intro (Folk):    [%s] @ %.3f" % [intro.pattern, intro.step_beat_length])

	# Couplet (4 beats) : Funky énergique
	var verse = generator.generate("Funky")
	print("Couplet (Funky): [%s] @ %.3f" % [verse.pattern, verse.step_beat_length])

	# Refrain (4 beats) : R'n B mélodique
	var chorus = generator.generate("R'n B")
	print("Refrain (R'n B): [%s] @ %.3f" % [chorus.pattern, chorus.step_beat_length])

	# Outro (4 beats) : Bossa doux
	var outro = generator.generate("Bossa")
	print("Outro (Bossa):   [%s] @ %.3f" % [outro.pattern, outro.step_beat_length])

	print("\nStructure de chanson créée avec 4 styles différents !")


func example_evolving_pattern():
	"""Exemple 3: Pattern qui évolue progressivement."""
	print("\n--- Exemple 3: Pattern évolutif (Folk → Funky) ---\n")

	var generator = GuitarPatternGenerator.new(999)  # Seed fixe
	var player = FolkGuitarPlayer.new()

	# Accord unique pour se concentrer sur l'évolution du pattern
	var em = GuitarChord.new()
	em.time = 0.0
	em.beat_length = 32.0  # 32 beats
	em.notes = [40, 47, 52, 56, 59, 64]  # Em

	player.set_chord_grid([em])

	# Générer 8 patterns qui évoluent du Folk au Funky
	var patterns = []

	print("Évolution du pattern:\n")

	# 4 patterns Folk (beats 0-16)
	for i in range(4):
		var result = generator.generate("Folk")
		var pattern = StrumPattern.create(result.pattern, result.step_beat_length)
		patterns.append(pattern)
		print("  %2d. Folk:  [%s]" % [i + 1, result.pattern])

	# 4 patterns Funky (beats 16-32)
	for i in range(4):
		var result = generator.generate("Funky")
		var pattern = StrumPattern.create(result.pattern, result.step_beat_length)
		patterns.append(pattern)
		print("  %2d. Funky: [%s]" % [i + 5, result.pattern])

	player.pattern_sequence = patterns

	# Générer
	var notes = player.generate()
	print("\nTransition fluide de Folk vers Funky sur 32 beats")
	print("Notes générées: %d" % notes.size())


func example_with_config_override():
	"""Exemple 4: Patterns avec config_override pour variation dynamique."""
	print("\n--- Exemple 4: Patterns avec variation de vélocité ---\n")

	var generator = GuitarPatternGenerator.new()
	var player = FolkGuitarPlayer.new()

	# Accord simple
	var c = GuitarChord.new()
	c.time = 0.0
	c.beat_length = 16.0
	c.notes = [36, 43, 48, 52, 55, 60]  # C

	player.set_chord_grid([c])

	# Générer 4 patterns avec vélocité croissante
	var patterns = []

	for i in range(4):
		var result = generator.generate("Folk")

		# Augmenter progressivement la vélocité
		var velocity = 60 + (i * 15)  # 60, 75, 90, 105

		var pattern = StrumPattern.create(
			result.pattern,
			result.step_beat_length,
			{
				"velocity_down_base": velocity,
				"velocity_up_base": velocity - 5
			}
		)

		patterns.append(pattern)
		print("Pattern #%d: [%s] @ vélocité %d" % [i + 1, result.pattern, velocity])

	player.pattern_sequence = patterns

	var notes = player.generate()
	print("\nCrescendo créé avec 4 patterns et config_override")
	print("Notes générées: %d" % notes.size())

	# Vérifier que les vélocités augmentent
	print("\nVélocités par section:")
	for i in range(4):
		var section_notes = []
		var start_time = i * 4.0
		var end_time = (i + 1) * 4.0

		for note in notes:
			if note.position >= start_time and note.position < end_time:
				section_notes.append(note)

		if section_notes.size() > 0:
			var avg_vel = 0.0
			for note in section_notes:
				avg_vel += note.velocity
			avg_vel /= section_notes.size()

			print("  Section %d: vélocité moyenne = %.1f" % [i + 1, avg_vel])
