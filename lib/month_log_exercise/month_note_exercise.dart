import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MonthExercisePage extends StatefulWidget {
  @override
  _MonthExercisePageState createState() => _MonthExercisePageState();
}

class _MonthExercisePageState extends State<MonthExercisePage> {
  // List to store the logged exercise dates.
  List<DateTime> loggedDates = [];
  // Currently selected date (for logging or canceling).
  DateTime? selectedDate;

  // For swiping between months. Using a high initialPage to allow backward/forward navigation.
  late PageController _pageController;
  int initialPage = 500;
  int currentPage = 500;
  // The month corresponding to initialPage is the current month.
  late DateTime initialMonth;

  late String userEmail;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initialMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _pageController = PageController(initialPage: initialPage);
    userEmail = FirebaseAuth.instance.currentUser!.email!;
    // Load locally saved data first, then update from Firestore.
    _loadLocalData().then((_) => _loadFirebaseData());
  }

  // Converts a page index into a DateTime representing the first day of that month.
  DateTime getMonthForPage(int pageIndex) {
    int monthOffset = pageIndex - initialPage;
    return DateTime(initialMonth.year, initialMonth.month + monthOffset, 1);
  }

  // Helper to check if two dates are on the same calendar day.
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Load locally stored logged dates (stored as ISO8601 strings).
  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? datesStr = prefs.getStringList('monthExercise');
    if (datesStr != null) {
      setState(() {
        loggedDates = datesStr.map((s) => DateTime.parse(s)).toList();
      });
    }
  }

  // Save logged dates locally.
  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> datesStr = loggedDates.map((d) => d.toIso8601String()).toList();
    await prefs.setStringList('monthExercise', datesStr);
  }

  // Load logged dates from Firestore (and create the field if necessary).
  Future<void> _loadFirebaseData() async {
    DocumentReference userDoc = _firestore.collection("Users").doc(userEmail);
    DocumentSnapshot docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create a new document with an empty monthExercise array if it doesn't exist.
      await userDoc.set({'monthExercise': []});
      setState(() {
        loggedDates = [];
      });
    } else {
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('monthExercise')) {
        List<dynamic> firebaseDates = data['monthExercise'];
        setState(() {
          // Convert each Timestamp to DateTime.
          loggedDates = firebaseDates.map((ts) => (ts as Timestamp).toDate()).toList();
        });
      } else {
        // If the field is missing, create it.
        await userDoc.update({'monthExercise': []});
        setState(() {
          loggedDates = [];
        });
      }
    }
    // Update local storage.
    await _saveLocalData();
  }

  // This method handles both logging and canceling a log.
  Future<void> _handleLog() async {
    if (selectedDate == null) return;

    DocumentReference userDoc = _firestore.collection("Users").doc(userEmail);
    bool alreadyLogged = loggedDates.any((d) => isSameDate(d, selectedDate!));

    setState(() {
      if (alreadyLogged) {
        // Cancel the log by removing the selected date.
        loggedDates.removeWhere((d) => isSameDate(d, selectedDate!));
      } else {
        // Log exercise by adding the selected date.
        loggedDates.add(selectedDate!);
      }
    });

    // Update Firestore with the new list (as Timestamps).
    await userDoc.update({
      'monthExercise': loggedDates.map((d) => Timestamp.fromDate(d)).toList(),
    });
    await _saveLocalData();

    // Clear the selection after operation.
    setState(() {
      selectedDate = null;
    });
  }

  // Navigate to the previous month.
  void _previousMonth() {
    int newPage = currentPage - 1;
    _pageController.animateToPage(
      newPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Navigate to the next month.
  void _nextMonth() {
    int newPage = currentPage + 1;
    _pageController.animateToPage(
      newPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the month currently shown in the PageView.
    DateTime displayedMonth = getMonthForPage(currentPage);
    String monthLabel = DateFormat('MMMM yyyy').format(displayedMonth);
    // Calculate total days in the displayed month.
    int totalDays = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;

    // Check if the selected date is already logged.
    bool isCancelMode = selectedDate != null &&
        loggedDates.any((d) => isSameDate(d, selectedDate!));
    // Set button color: red for cancel mode, blue for log mode.
    final Color buttonColor = isCancelMode ? Colors.red.shade400 : AppColor.moresolidPrimary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: AppColor.backgroundWhite)),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Exercise Tracker",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColor.backgroundWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Row with IconButtons for previous and next month, plus the month label.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColor.supersolidPrimary),
                  onPressed: _previousMonth,
                ),
                Text(
                  monthLabel,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: AppColor.supersolidPrimary),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // New row for day representations (letters for Monday to Sunday).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              children: ["M", "T", "W", "T", "F", "S", "S"].map((dayLetter) {
                return Expanded(
                  child: Center(
                    child: Text(
                      dayLetter,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Expanded PageView for swiping between months.
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                  // Clear the selection when the month changes.
                  selectedDate = null;
                });
              },
              itemBuilder: (context, index) {
                DateTime month = getMonthForPage(index);
                int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    padding: EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      int day = index + 1;
                      DateTime date = DateTime(month.year, month.month, day);
                      // A date is considered future if it is after today.
                      bool isFuture = date.isAfter(DateTime.now());
                      // Check if this date has been logged.
                      bool isLogged = loggedDates.any((d) => isSameDate(d, date));
                      bool isSelected = selectedDate != null && isSameDate(selectedDate!, date);

                      return GestureDetector(
                        onTap: () {
                          // Ignore if the date is in the future.
                          if (isFuture) return;
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isFuture
                                ? Colors.grey[200]
                                : (isSelected ? Colors.lightBlueAccent.withOpacity(0.3) : Colors.white),
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.grey,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Display the day number.
                              Text(
                                "$day",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: isLogged ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: isFuture ? Colors.grey : Colors.black87,
                                ),
                              ),
                              // If logged, overlay an icon.
                              if (isLogged)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Icon(
                                    Icons.run_circle_outlined,
                                    color: AppColor.supersolidPrimary,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Elevated button that either logs or cancels based on the selected date.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (selectedDate != null) ? _handleLog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonColor.withOpacity(0.5),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                isCancelMode ? "Cancel Log" : "Log Exercise",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
