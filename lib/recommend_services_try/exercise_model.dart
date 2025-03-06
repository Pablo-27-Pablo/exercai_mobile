class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String target;
  final List<String> secondaryMuscles;
  final String gifUrl;
  final List<String> instructions;
  final String difficulty;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.target,
    required this.secondaryMuscles,
    required this.gifUrl,
    required this.instructions,
    required this.difficulty,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Exercise',
      bodyPart: json['bodyPart']?.toString().toLowerCase() ?? '',
      equipment: json['equipment']?.toString().toLowerCase() ?? '',
      target: json['target']?.toString().toLowerCase() ?? '',
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      gifUrl: json['gifUrl']?.toString() ?? '',
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      difficulty: json['difficulty']?.toString().toLowerCase() ?? 'medium',
    );
  }

  // Add toJson method INSIDE the class
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'equipment': equipment,
      'target': target,
      'difficulty': difficulty,
      'gifUrl': gifUrl,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
    };
  }
}