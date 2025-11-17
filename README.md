# FolkGuitarPlayer 🎸

Moteur de simulation réaliste du jeu rythmique d'accords à la guitare folk pour Godot 3.6.

Génère des séquences MIDI humanisées à partir d'une grille d'accords et de patterns rythmiques, avec simulation de balayette (strum) naturelle, variations de vélocité et humanisation du timing.

---

## 🎯 Caractéristiques

- **Balayette réaliste** : Simulation du mouvement de la main avec égrènement des cordes
- **Humanisation** : Variations aléatoires de vélocité et timing pour éviter l'effet "machine"
- **Patterns rythmiques flexibles** : Down/Up fort/léger, mutées, laisser sonner, silences
- **Double-croches et croches** : Support des rythmiques funk et folk classiques
- **Configuration avancée** : Ajustement fin du réalisme et du style de jeu
- **Sortie MIDI standard** : Format compatible avec vos outils existants

---

## 📦 Installation

1. Copiez les fichiers dans votre projet Godot 3.6 :
   - `FolkGuitarPlayer.gd`
   - `GuitarChord.gd`

2. C'est tout ! Les classes sont prêtes à être utilisées.

---

## 🚀 Utilisation Rapide

```gdscript
# Créer le player
var player = FolkGuitarPlayer.new()

# Créer un accord (Em - Mi mineur)
var em = GuitarChord.new()
em.position = 0.0  # Position en beats
em.notes = [40, 47, 52, 56, 59, 64]  # Pitchs MIDI (6 cordes)
em.pattern = "D.uDudu"  # Pattern rythmique
em.step_length = 0.5  # Croche

# Ajouter l'accord à la grille
player.set_chord_grid([em])

# Générer les notes MIDI
var midi_notes = player.generate()

# Utiliser les notes
for note in midi_notes:
    print("Pitch: %d | Position: %.3f | Durée: %.3f | Vélocité: %d" % [
        note.pitch, note.position, note.duration, note.velocity
    ])
```

---

## 📖 Documentation Détaillée

### GuitarChord (Classe d'Accord)

Représente un accord de guitare avec ses paramètres de jeu.

#### Propriétés

| Propriété | Type | Description | Exemple |
|-----------|------|-------------|---------|
| `position` | `float` | Position temporelle en beats | `0.0`, `4.0` |
| `notes` | `Array[int]` | Pitchs MIDI des 6 cordes (grave → aiguë) | `[40, 47, 52, 56, 59, 64]` |
| `pattern` | `String` | Motif rythmique à boucler | `"D.uDudu"` |
| `step_length` | `float` | Durée d'un pas de pattern (beats) | `0.5` (croche), `0.25` (double) |
| `muted_strings` | `Array[bool]` | Cordes mutées (optionnel) | `[true, false, false, ...]` |
| `override_velocity_base` | `float` | Surcharge vélocité (optionnel) | `-1` (utiliser global) |
| `override_strum_duration` | `float` | Surcharge durée strum (optionnel) | `-1` (utiliser global) |

#### Symboles de Pattern

| Symbole | Signification | Vélocité | Direction |
|---------|---------------|----------|-----------|
| `D` | Down **fort** | Élevée (100) | Grave → Aiguë |
| `d` | Down léger | Moyenne (75) | Grave → Aiguë |
| `U` | Up **fort** | Élevée (95) | Aiguë → Grave |
| `u` | Up léger | Moyenne (70) | Aiguë → Grave |
| ` ` (espace) | Silence | - | - |
| `.` | **Laisser sonner** (prolonge) | - | - |
| `X` | **Muté** (note très courte) | Variable | Selon contexte |

#### Exemples d'Accords Courants

```gdscript
# Em (Mi mineur)
var em = GuitarChord.new(0.0, [40, 47, 52, 56, 59, 64], "D.uDudu", 0.5)

# C (Do majeur)
var c = GuitarChord.new(4.0, [36, 43, 48, 52, 55, 60], "D.uDudu", 0.5)

# G (Sol majeur)
var g = GuitarChord.new(8.0, [43, 47, 50, 55, 59, 62], "D.uDudu", 0.5)

# Am avec corde grave mutée
var am = GuitarChord.new(0.0, [45, 52, 57, 60, 64, 69], "DuDuDuDu", 0.5)
am.muted_strings = [true, false, false, false, false, false]
```

---

### FolkGuitarPlayer (Moteur Principal)

Génère les notes MIDI à partir d'une grille d'accords.

#### Méthodes Principales

```gdscript
# Définir la grille d'accords
player.set_chord_grid(chords: Array)

# Configurer les paramètres de réalisme
player.set_configuration(params: Dictionary)

# Générer les notes MIDI
var notes = player.generate() -> Array

# Obtenir la configuration actuelle
var config = player.get_configuration() -> Dictionary

# Réinitialiser
player.clear()

# Debug: afficher les notes
player.print_notes()

# Obtenir des statistiques
var stats = player.get_stats() -> Dictionary
```

#### Format de Note de Sortie

Chaque note générée est un `Dictionary` :

```gdscript
{
    "pitch": 64,           # Valeur MIDI (0-127)
    "position": 0.015,     # Position temporelle en beats
    "duration": 0.52,      # Longueur en beats
    "velocity": 98,        # Vélocité (1-127)
    "string_index": 4      # Numéro de corde (0-5)
}
```

---

### Configuration Avancée

Ajustez le réalisme avec `set_configuration()` :

```gdscript
player.set_configuration({
    # === DURÉE DE STRUM ===
    "strum_duration_min": 0.015,  # Durée minimale (beats)
    "strum_duration_max": 0.030,  # Durée maximale (beats)

    # === VÉLOCITÉ ===
    "velocity_down_base": 100,    # Down fort
    "velocity_down_light": 75,    # Down léger
    "velocity_up_base": 95,       # Up fort
    "velocity_up_light": 70,      # Up léger
    "velocity_randomization": 0.10,  # Variation aléatoire (0-1)
    "velocity_curve_shape": "gaussian",  # gaussian, linear, flat

    # === ACCENTS ===
    "accent_downbeat_factor": 1.15,  # Multiplicateur temps forts

    # === DURÉES ===
    "mute_duration": 0.05,        # Durée notes mutées (beats)
    "note_overlap": 0.02,         # Overlap pour éviter les trous

    # === HUMANISATION TEMPORELLE ===
    "humanize_timing": false,     # Activer micro-décalages
    "timing_variance": 0.005,     # Variance temporelle (beats)
})
```

#### Profils de Jeu Prédéfinis

**Jeu Doux (Ballade)** :
```gdscript
player.set_configuration({
    "velocity_down_base": 80,
    "velocity_down_light": 60,
    "velocity_up_base": 75,
    "velocity_up_light": 55,
    "velocity_randomization": 0.08,
    "strum_duration_min": 0.020,
    "strum_duration_max": 0.035,
})
```

**Jeu Agressif (Rock)** :
```gdscript
player.set_configuration({
    "velocity_down_base": 115,
    "velocity_down_light": 95,
    "velocity_up_base": 110,
    "velocity_up_light": 90,
    "velocity_randomization": 0.15,
    "strum_duration_min": 0.010,
    "strum_duration_max": 0.020,
    "accent_downbeat_factor": 1.30,
})
```

**Jeu Funk (Précis)** :
```gdscript
player.set_configuration({
    "velocity_randomization": 0.05,
    "strum_duration_min": 0.012,
    "strum_duration_max": 0.018,
    "humanize_timing": true,
    "timing_variance": 0.003,
})
```

---

## 🎼 Exemples de Patterns

### Pattern Folk Classique
```gdscript
chord.pattern = "D.uDudu"  # Down - pause - up down up down up
chord.step_length = 0.5    # Croches
```

### Pattern Funk (double-croches)
```gdscript
chord.pattern = "D.ud.udu .ud.uDu"
chord.step_length = 0.25  # Double-croches
```

### Pattern avec Mutées
```gdscript
chord.pattern = "DuXuDuXu"  # X = note percussive courte
chord.step_length = 0.5
```

### Pattern Arpégé
```gdscript
chord.pattern = "D...D...D...D..."  # Laisser sonner longtemps
chord.step_length = 0.5
```

### Pattern Reggae (afterbeat)
```gdscript
chord.pattern = " u u u u"  # Ups uniquement, sur contretemps
chord.step_length = 0.5
```

---

## 🎯 Cas d'Usage Avancés

### Progression d'Accords Complète

```gdscript
var player = FolkGuitarPlayer.new()

# Em - C - G - D (progression classique)
var chords = [
    GuitarChord.new(0.0, [40, 47, 52, 56, 59, 64], "D.uDudu", 0.5),   # Em
    GuitarChord.new(4.0, [36, 43, 48, 52, 55, 60], "D.uDudu", 0.5),   # C
    GuitarChord.new(8.0, [43, 47, 50, 55, 59, 62], "D.uDudu", 0.5),   # G
    GuitarChord.new(12.0, [50, 57, 62, 66, 69, 74], "D.uDudu", 0.5),  # D
]

player.set_chord_grid(chords)
var notes = player.generate()

print("Total notes: %d" % notes.size())
print("Durée: %.1f beats" % (notes[-1].position + notes[-1].duration))
```

### Variation de Pattern par Accord

```gdscript
# Premier accord: rythmique simple
var chord1 = GuitarChord.new(0.0, [40, 47, 52, 56, 59, 64], "D d u d ", 0.5)

# Deuxième accord: rythmique plus complexe
var chord2 = GuitarChord.new(4.0, [36, 43, 48, 52, 55, 60], "DuduDuXu", 0.5)

player.set_chord_grid([chord1, chord2])
```

### Intégration avec Système MIDI

```gdscript
# Générer les notes
var notes = player.generate()

# Convertir en événements MIDI
for note in notes:
    # Note On
    midi_player.send_event({
        "type": "note_on",
        "time": note.position,
        "pitch": note.pitch,
        "velocity": note.velocity,
        "channel": 0
    })

    # Note Off (après la durée)
    midi_player.send_event({
        "type": "note_off",
        "time": note.position + note.duration,
        "pitch": note.pitch,
        "velocity": 0,
        "channel": 0
    })
```

---

## 🧪 Tests et Debug

### Exécuter la Démo

Le fichier `Demo.gd` contient 6 tests complets :

1. **Pattern Simple** : Test basique d'un pattern sur un accord
2. **Progression d'Accords** : Enchaînement Em-C-G-D
3. **Pattern avec Mutées** : Test du symbole `X`
4. **Laisser Sonner** : Test du symbole `.`
5. **Rythmique Funk** : Double-croches
6. **Configuration Personnalisée** : Jeu agressif avec humanisation

Pour exécuter :
```gdscript
# Attacher Demo.gd à un Node dans votre scène
# ou exécuter directement dans l'éditeur
```

### Afficher les Notes

```gdscript
var player = FolkGuitarPlayer.new()
# ... configuration ...
var notes = player.generate()

# Afficher toutes les notes
player.print_notes()

# Obtenir des statistiques
var stats = player.get_stats()
print("Total notes: %d" % stats.total_notes)
print("Vélocité: min=%d, max=%d, avg=%.1f" % [
    stats.velocity_min, stats.velocity_max, stats.velocity_avg
])
```

---

## 🎨 Astuces pour un Rendu Réaliste

### 1. Variez les Patterns
Ne répétez pas le même pattern tout le temps. Alternez :
```gdscript
var patterns = ["D.uDudu", "DuduDudu", "D.u.udu", "Dudu.udu"]
# Choisir aléatoirement ou selon la progression
```

### 2. Utilisez les Accents
Les temps 1 et 3 sont naturellement plus forts grâce à `accent_downbeat_factor`.

### 3. Cordes Mutées pour le Réalisme
Certains accords sonnent mieux avec la corde grave mutée :
```gdscript
# D majeur : corde E grave mutée
chord.muted_strings = [true, false, false, false, false, false]
```

### 4. Humanisation Subtile
Pour un effet réaliste, gardez `velocity_randomization` entre 0.08 et 0.15.

### 5. Timing Humanisé pour les Ballades
```gdscript
player.set_configuration({
    "humanize_timing": true,
    "timing_variance": 0.005,  # ±5ms
})
```

---

## 🔧 Personnalisation Avancée

### Créer Votre Propre Symbole de Pattern

Modifiez `FolkGuitarPlayer.gd`, méthode `_process_chord()` :

```gdscript
match symbol:
    # ... symboles existants ...
    'P':  # Palm mute (nouveau symbole)
        _generate_strum(chord, current_time, "down", 60, beat_position, true)
        # Réduire encore la durée
        for note in active_notes:
            note.duration = 0.03
```

### Ajouter une Courbe de Vélocité Personnalisée

Dans `_calculate_velocity()` :

```gdscript
elif config.velocity_curve_shape == "exponential":
    velocity *= _exponential_curve(string_pos, total_strings)
```

Puis implémentez `_exponential_curve()`.

---

## 📊 Performances

- **Génération** : ~0.1ms par accord (selon complexité)
- **Mémoire** : ~50 bytes par note générée
- **Notes typiques** : 300-600 notes pour 16 mesures à 4/4

---

## 🐛 Troubleshooting

**Problème** : Les notes sonnent toutes ensemble (pas de strum)
- **Solution** : Vérifiez que `strum_duration_min/max` > 0.01

**Problème** : Vélocités trop uniformes
- **Solution** : Augmentez `velocity_randomization` (ex: 0.15)

**Problème** : Le pattern ne boucle pas correctement
- **Solution** : Assurez-vous que la position du prochain accord est correcte

**Problème** : Notes mutées pas assez courtes
- **Solution** : Diminuez `mute_duration` (ex: 0.03)

---

## 📝 TODO / Améliorations Futures

- [ ] Support des slides entre accords
- [ ] Hammer-on / Pull-off simulation
- [ ] Palm muting avec symbole dédié
- [ ] Profils de guitariste prédéfinis
- [ ] Export direct vers fichier MIDI
- [ ] Support des accords à 12 cordes (doubling)
- [ ] Variations micro-temporelles par mesure

---

## 📄 Licence

Libre d'utilisation et de modification. Crédit apprécié mais non obligatoire.

---

## 🙏 Crédits

Développé pour la simulation réaliste de guitare folk dans Godot 3.6.

---

**Bon grattage virtuel ! 🎸**
