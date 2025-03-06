final Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> exerciseData = {
  'beginner': {
    'underweight': {
      'back': [
        {'name': 'seated lower back stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.75},
        {'name': 'spine stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 4.8}
      ],
      'chest': [
        {'name': 'push-up (wall)', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 8},
      ],
      'cardio': [
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 4.5}
      ],
    },
    'normal': {
      'back': [
        {'name': 'standing lateral stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'baseCalories': 0.77, 'burnCalperSec': 0.051},
        {'name': 'kneeling lat stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'baseCalories': 0.94, 'burnCalperSec': 0.047},
      ],
      'chest': [
        {'name': 'kneeling push-up (male)', 'baseSetsReps': 3, 'baseReps': 12, 'baseCalories': 9, 'burnCalperRep': 0.25},
        {'name': 'dynamic chest stretch (male)', 'baseSetsSecs': 2, 'baseSecs': 15, 'baseCalories': 2.15, 'burnCalperSec': 0.072},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 73, 'burnCalperSec': 0.122},
      ],
    },
    'overweight': {
      'back': [
        {'name': 'side lying floor stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 10},
        {'name': 'standing pelvic tilt', 'baseSetsSecs': 2, 'baseSecs': 15, 'burnCalperSec': 0.27, 'baseCalories': 8},
      ],
      'chest': [
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 3, 'baseSecs': 10, 'burnCalperSec': 0.4, 'baseCalories': 12},
      ],
      'cardio': [
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.22, 'baseCalories': 20},
      ],
    },
    'obese': {
      'back': [
        {'name': 'lower back curl', 'baseSetsReps': 2, 'baseReps': 12, 'burnCalperRep': 0.625, 'baseCalories': 15},
      ],
      'chest': [
        {'name': 'push-up (wall)', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 15},
      ],
      'cardio': [
        {'name': 'march in place', 'baseSetsSecs': 3, 'baseSecs': 60, 'burnCalperSec': 0.17, 'baseCalories': 30},
      ],
    },
    'extreme_obese': {
      'back': [
        {'name': 'sphinx', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 10},
      ],
      'chest': [
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 3, 'baseSecs': 10, 'burnCalperSec': 0.4, 'baseCalories': 12},
      ],
      'cardio': [
        {'name': 'step touch', 'baseSetsSecs': 3, 'baseSecs': 60, 'burnCalperSec': 0.17, 'baseCalories': 30},
      ],
    },
  },
  'intermediate': {
    'underweight': {
      'back': [
        {'name': 'upward facing dog', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.3, 'baseCalories': 12},
      ],
      'chest': [
        {'name': 'incline push-up', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.69, 'baseCalories': 25},
      ],
      'cardio': [
        {'name': 'mountain climber', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.39, 'baseCalories': 35},
      ],
    },
    'normal': {
      'back': [
        {'name': 'two toe touch (male)', 'baseSetsReps': 2, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 15},
      ],
      'chest': [
        {'name': 'decline push-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.67, 'baseCalories': 30},
      ],
      'cardio': [
        {'name': 'burpee', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 1.39, 'baseCalories': 50},
      ],
    },
    // ... (remaining categories follow same pattern)
    'overweight': {
      'back': [
        {'name': 'lower back curl', 'baseSetsReps': 2, 'baseReps': 12, 'baseCalories': 7.92, 'burnCalperRep': 0.33},
      ],
      'chest': [
        {'name': 'shoulder tap push-up', 'baseSetsReps': 1, 'baseReps': 12, 'baseCalories': 10.44, 'burnCalperRep': 0.87},
      ],
      'cardio': [
        {'name': 'push to run','baseSetsSecs': 1, 'baseSecs': 300, 'baseCalories': 58, 'burnCalperSec': 0.194},
      ],
    },
    'obese': {
      'back': [
        {'name': 'upper back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'baseCalories': 1.98, 'burnCalperSec': 0.047},
      ],
      'chest': [
        {'name': 'wide hand push up', 'baseSetsReps': 2, 'baseReps': 12, 'baseCalories': 16.65, 'burnCalperRep': 0.694},
      ],
      'cardio': [
        {'name': 'low impact jumping jack', 'baseSetsSecs': 3, 'baseSecs': 60, 'baseCalories': 18.36, 'burnCalperSec': 0.102},
      ],
    },
    'extreme_obese': {
      'back': [
        {'name': 'sphinx', 'baseSetsSecs': 2, 'baseSecs': 20, 'baseCalories': 2.04, 'burnCalperSec': 0.051},
      ],
      'chest': [
        {'name': 'clock push-up', 'baseSetsReps': 2, 'baseReps': 10, 'baseCalories': 18, 'burnCalperRep': 0.87},
      ],
      'cardio': [],
    },
  },
  'advanced': {
    'underweight': {
      'back': [
        {'name': 'one arm against wall', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.3, 'baseCalories': 12},
      ],
      'chest': [
        {'name': 'archer push up', 'baseSetsReps': 4, 'baseReps': 15, 'burnCalperRep': 0.67, 'baseCalories': 40},
      ],
      'cardio': [
        {'name': 'star jump (male)', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.83, 'baseCalories': 50},
      ],
    },
    ///////
    'normal': {
      'back': [
        {'name': 'one arm against wall', 'baseSetsSecs': 2, 'baseSecs': 20, 'baseCalories': 1.88,'burnCalperSec': 0.047},
      ],
      'chest': [
        {'name': 'push and pull bodyweight', 'baseSetsReps': 3, 'baseReps': 15, 'baseCalories': 27.585,'burnCalperRep': 0.613},
      ],
      'cardio': [
        {'name': 'semi squat jump (male)', 'baseSetsReps': 4, 'baseReps': 12, 'baseCalories': 35.328,'burnCalperRep': 0.736},
      ],
    },
    'overweight': {
      'back': [
        {'name': 'one arm against wall', 'baseSetsSecs': 2, 'baseSecs': 20, 'baseCalories': 1.88,'burnCalperSec': 0.047},
      ],
      'chest': [
        {'name': 'isometric wipers', 'baseSetsReps': 3, 'baseReps': 12, 'baseCalories': 14.724,'burnCalperRep': 0.409},
      ],
      'cardio': [
        {'name': 'high knees', 'baseSetsSecs': 4, 'baseSecs': 30, 'baseCalories': 24.48,'burnCalperSec': 0.204},
      ],
    },
    'obese': {
      'back': [],
      'chest': [
        {'name': 'push-up', 'baseSetsReps': 3, 'baseReps': 15, 'baseCalories': 22.05,'burnCalperRep': 0.49},
      ],
      'cardio': [
        //{'name': 'march in place', 'baseSetsSecs': 3, 'baseSecs': 60, 'baseCalories': 30,'burnCalperSec': 0.39},
      ],
    },
    'extreme_obese': {
      'back': [],
      'chest': [],
      'cardio': [
        //{'name': 'march in place', 'baseSetsSecs': 3, 'baseSecs': 60, 'baseCalories': 30,'burnCalperSec': 0.39},
      ],
    },
  },
};