final Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> exerciseData = {
  'beginner': {
    'underweight': {
      'back': [
        {'name': 'seated lower back stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        //added new edit nalang
        {'name': 'standing lateral stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'kneeling lat stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'side lying floor stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'push-up (wall)', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'clock push-up', 'baseSetsReps': 1, 'baseReps': 10, 'burnCalperRep': 0.3, 'baseCalories': 0.00},
        {'name': 'decline push-up', 'baseSetsReps': 1, 'baseReps': 10, 'burnCalperRep': 0.35, 'baseCalories': 0.00},
        {'name': 'incline push-up', 'baseSetsReps': 1, 'baseReps': 10, 'burnCalperRep': 0.35, 'baseCalories': 0.00},
        {'name': 'isometric wipers', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.02, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        //new added edit
        {'name': 'half knee bends (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'push to run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'mountain climber', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'normal': {
      'back': [
        {'name': 'standing lateral stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'baseCalories': 0.00, 'burnCalperSec': 0.051},
        {'name': 'kneeling lat stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'baseCalories': 0.00, 'burnCalperSec': 0.047},
        {'name': 'one arm against wall', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'upper back stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.045, 'baseCalories': 0.00},
        {'name': 'two toe touch (male)', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.048, 'baseCalories': 0.00},
        {'name': 'upward facing dog', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'kneeling push-up (male)', 'baseSetsReps': 3, 'baseReps': 12, 'baseCalories': 0.00, 'burnCalperRep': 0.25},
        {'name': 'dynamic chest stretch (male)', 'baseSetsSecs': 2, 'baseSecs': 15, 'baseCalories': 0.00, 'burnCalperSec': 0.072},
        {'name': 'push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'shoulder tap push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.45, 'baseCalories': 0.00},
        {'name': 'dynamic chest stretch (male)', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.03, 'baseCalories': 0.00},
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.02, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 0.00, 'burnCalperSec': 0.122},
        //new added edit
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'push to run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'mountain climber', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'astride jumps (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'overweight': {
      'back': [
        {'name': 'side lying floor stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 0.00},
        {'name': 'standing pelvic tilt', 'baseSetsSecs': 2, 'baseSecs': 15, 'burnCalperSec': 0.27, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.26, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 3, 'baseSecs': 10, 'burnCalperSec': 0.4, 'baseCalories': 0.00},
        {'name': 'push and pull bodyweight', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'kneeling push-up (male)', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.45, 'baseCalories': 0.00},
        {'name': 'archer push up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 0.00, 'burnCalperSec': 0.122},
        //new added edit
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'push to run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'mountain climber', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'astride jumps (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'obese': {
      'back': [
        {'name': 'lower back curl', 'baseSetsReps': 2, 'baseReps': 12, 'burnCalperRep': 0.625, 'baseCalories': 0.00},
        {'name': 'seated lower back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.23, 'baseCalories': 0.00},
        {'name': 'standing lateral stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.22, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'push-up (wall)', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'push-up (wall)', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'shoulder tap push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'extreme obese': {
      'back': [
        {'name': 'sphinx', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.24, 'baseCalories': 0.00},
        {'name': 'upper back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.23, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'wall push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'incline push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.55, 'baseCalories': 0.00},
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.03, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 0.00, 'burnCalperSec': 0.122},
        {'name': 'step touch', 'baseSetsSecs': 3, 'baseSecs': 60, 'burnCalperSec': 0.17, 'baseCalories': 0.00},
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.04, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
  },



  'intermediate': {
    'underweight': {
      'back': [
        {'name': 'upward facing dog', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.3, 'baseCalories': 0.00},
        //added new edit nalang
        {'name': 'seated lower back stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'standing lateral stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'kneeling lat stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'side lying floor stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'upward facing dog', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'two toe touch (male)', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},

      ],
      'chest': [
        {'name': 'push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'shoulder tap push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.45, 'baseCalories': 0.00},
        {'name': 'dynamic chest stretch (male)', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.03, 'baseCalories': 0.00},
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.02, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'push to run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'mountain climber', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'normal': {
      'back': [
        {'name': 'standing lateral stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'baseCalories': 0.00, 'burnCalperSec': 0.051},
        {'name': 'kneeling lat stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'baseCalories': 0.00, 'burnCalperSec': 0.047},
        {'name': 'one arm against wall', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'upper back stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.045, 'baseCalories': 0.00},
        {'name': 'two toe touch (male)', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.048, 'baseCalories': 0.00},
        {'name': 'upward facing dog', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'shoulder tap push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.45, 'baseCalories': 0.00},
        {'name': 'dynamic chest stretch (male)', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.03, 'baseCalories': 0.00},
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.02, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 0.00, 'burnCalperSec': 0.122},
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'push to run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'mountain climber', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'astride jumps (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'overweight': {
      'back': [
        {'name': 'side lying floor stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 0.00},
        {'name': 'standing pelvic tilt', 'baseSetsSecs': 2, 'baseSecs': 15, 'burnCalperSec': 0.27, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.26, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'shoulder tap push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.45, 'baseCalories': 0.00},
        {'name': 'dynamic chest stretch (male)', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.03, 'baseCalories': 0.00},
        {'name': 'isometric chest squeeze', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.02, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 0.00, 'burnCalperSec': 0.122},
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'push to run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'mountain climber', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'astride jumps (male)', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'obese': {
      'back': [
        {'name': 'lower back curl', 'baseSetsReps': 2, 'baseReps': 12, 'burnCalperRep': 0.625, 'baseCalories': 0.00},
        {'name': 'seated lower back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.23, 'baseCalories': 0.00},
        {'name': 'standing lateral stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.22, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'shoulder tap push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.45, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 0.00, 'burnCalperSec': 0.122},
        {'name': 'skater hops', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.08, 'baseCalories': 0.00},
        {'name': 'push to run', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'extreme_obese': {
      'back': [
        {'name': 'sphinx', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.24, 'baseCalories': 0.00},
        {'name': 'upper back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.23, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'shoulder tap push-up', 'baseSetsReps': 2, 'baseReps': 8, 'burnCalperRep': 0.45, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 2, 'baseReps': 10, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 600, 'baseCalories': 0.00, 'burnCalperSec': 0.122},
        {'name': 'step touch', 'baseSetsSecs': 3, 'baseSecs': 60, 'burnCalperSec': 0.17, 'baseCalories': 0.00},
        {'name': 'high knee against wall', 'baseSetsSecs': 3, 'baseSecs': 30, 'burnCalperSec': 0.04, 'baseCalories': 0.00},
      ],
      'lower arms':[
        {'name': 'side wrist pull stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'modified push up to lower arms', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'wrist circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
  },





  'advanced': {
    'underweight': {
      'back': [
        {'name': 'upward facing dog', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.3, 'baseCalories': 0.00},
        //added new edit nalang
        {'name': 'seated lower back stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'standing lateral stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'kneeling lat stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'side lying floor stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'upward facing dog', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'two toe touch (male)', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': ' lower back curl', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': ' upper back stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'clock push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'decline push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'incline push-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'archer push up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'mountain climber', 'baseSetsReps': 3, 'baseReps': 30, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 120, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'burpee', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.9, 'baseCalories': 0.00},
        {'name': 'skater hops', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'normal': {
      'back': [
        {'name': 'kneeling lat stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'side lying floor stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'upward facing dog', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'two toe touch (male)', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': ' lower back curl', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': ' upper back stretch', 'baseSetsReps': 1, 'baseReps': 12, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'clock push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'decline push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'incline push-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'archer push up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'wide hand push-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'run', 'baseSetsSecs': 1, 'baseSecs': 300, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'burpee', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.9, 'baseCalories': 0.00},
        {'name': 'skater hops', 'baseSetsReps': 3, 'baseReps': 25, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'astride jumps (male)', 'baseSetsReps': 3, 'baseReps': 30, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'star jump (male)', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'overweight': {
      'back': [
        {'name': 'sphinx', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.24, 'baseCalories': 0.00},
        {'name': 'upper back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.23, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'clock push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'decline push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'incline push-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'burpee', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.9, 'baseCalories': 0.00},
        {'name': 'skater hops', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'obese': {
      'back': [
        {'name': 'sphinx', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.24, 'baseCalories': 0.00},
        {'name': 'upper back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.23, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'clock push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'decline push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'incline push-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'burpee', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.9, 'baseCalories': 0.00},
        {'name': 'skater hops', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
    'extreme_obese': {
      'back': [
        {'name': 'sphinx', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.25, 'baseCalories': 0.00},
        {'name': 'spine stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.24, 'baseCalories': 0.00},
        {'name': 'upper back stretch', 'baseSetsSecs': 2, 'baseSecs': 20, 'burnCalperSec': 0.23, 'baseCalories': 0.00},
      ],
      'chest': [
        {'name': 'clock push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'decline push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'incline push-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'cardio': [
        {'name': 'burpee', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.9, 'baseCalories': 0.00},
        {'name': 'skater hops', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'half knee bends (male)', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'lower legs': [
        {'name': 'circles knee stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'ankle circles', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.4, 'baseCalories': 0.00},
        {'name': 'bodyweight standing calf raise', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
        {'name': 'calf stretch with hands against wall', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'standing calf raise (on a staircase)', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.5, 'baseCalories': 0.00},
      ],
      'neck': [
        {'name': 'side push neck stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'neck side stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
      ],
      'shoulders': [
        {'name': 'rear deltoid stretch', 'baseSetsSecs': 1, 'baseSecs': 15, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'left hook. boxing', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
      ],
      'upper arms': [
        {'name': 'body-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'close-grip push-up', 'baseSetsReps': 3, 'baseReps': 8, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'diamond push-up', 'baseSetsReps': 3, 'baseReps': 6, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'reverse dip', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'triceps dips floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'biceps leg concentration curl', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'bench dip (knees bent)', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
      ],
      'upper legs': [
        {'name': 'jump squat', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.8, 'baseCalories': 0.00},
        {'name': 'march sit (wall)', 'baseSetsSecs': 1, 'baseSecs': 30, 'burnCalperSec': 0.1, 'baseCalories': 0.00},
        {'name': 'side hip abduction', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'walking lunge', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'hamstring stretch', 'baseSetsSecs': 1, 'baseSecs': 20, 'burnCalperSec': 0.05, 'baseCalories': 0.00},
        {'name': 'split squats', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'lunge with jump', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.85, 'baseCalories': 0.00}
      ],
      'waist': [
        {'name': '3/4 sit-up', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'air bike', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'cross body crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.65, 'baseCalories': 0.00},
        {'name': 'crunch floor', 'baseSetsReps': 3, 'baseReps': 15, 'burnCalperRep': 0.6, 'baseCalories': 0.00},
        {'name': 'jackknife sit-up', 'baseSetsReps': 3, 'baseReps': 10, 'burnCalperRep': 0.75, 'baseCalories': 0.00},
        {'name': 'russian twist', 'baseSetsReps': 3, 'baseReps': 20, 'burnCalperRep': 0.7, 'baseCalories': 0.00},
        {'name': 'reverse crunch', 'baseSetsReps': 3, 'baseReps': 12, 'burnCalperRep': 0.7, 'baseCalories': 0.00}
      ]
    },
  },
};
