extends Node

"""
Exemple d'utilisation de generate_ascii_tab()

Cet exemple montre comment générer une tablature ASCII
pour un pattern de guitare folk classique.
"""

func _ready():
	print("\n" + "="*80)
	print("  EXEMPLE: Tablature ASCII d'un pattern folk classique")
	print("="*80 + "\n")

	# Créer le player
	var player = FolkGuitarPlayer.new()

	# Configuration
	player.config.swing_amount = 0.0
	player.config.max_chords_strings = 6

	# Créer une progression G - C - D - G
	var chords = []

	# G (sol majeur)
	var g = GuitarChord.new()
	g.time = 0.0
	g.beat_length = 4.0
	g.notes = [43, 47, 50, 55, 59, 62]  # G: G B D G B G
	chords.append(g)

	# C (do majeur)
	var c = GuitarChord.new()
	c.time = 4.0
	c.beat_length = 4.0
	c.notes = [36, 43, 48, 52, 55, 60]  # C: C G C E G C
	chords.append(c)

	# D (ré majeur)
	var d = GuitarChord.new()
	d.time = 8.0
	d.beat_length = 4.0
	d.notes = [50, 50, 50, 54, 57, 62]  # D: D A D F# A D
	chords.append(d)

	# G (retour)
	var g2 = GuitarChord.new()
	g2.time = 12.0
	g2.beat_length = 4.0
	g2.notes = [43, 47, 50, 55, 59, 62]  # G
	chords.append(g2)

	player.set_chord_grid(chords)

	# Pattern classique: Bass - Down - Up - Down - Up
	# B = basse principale, d/u = strums légers
	var pattern = StrumPattern.create("B...d.u.d.u.....", 0.25)
	player.pattern_sequence = [pattern]

	# Générer les notes MIDI
	var notes = player.generate()
	print("Progression: G - C - D - G")
	print("Pattern: Basse + Down-Up (boom-chick)")
	print("Notes MIDI générées: %d\n" % notes.size())

	# Générer et afficher la tablature ASCII
	# - 4 caractères par beat (résolution standard)
	# - 80 caractères par ligne maximum
	# - Afficher les marqueurs de temps
	var tab = player.generate_ascii_tab(4, 80, true)

	print("TABLATURE ASCII:\n")
	print(tab)

	# Sauvegarder dans un fichier (optionnel)
	save_tab_to_file(tab, "res://output_tab.txt")


func save_tab_to_file(tab_content: String, filepath: String) -> void:
	"""Sauvegarde la tablature dans un fichier texte."""
	var file = File.new()
	if file.open(filepath, File.WRITE) == OK:
		file.store_string(tab_content)
		file.close()
		print("\n✓ Tablature sauvegardée dans: %s" % filepath)
	else:
		print("\n✗ Erreur: impossible de sauvegarder le fichier")
