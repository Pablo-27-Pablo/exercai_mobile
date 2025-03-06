import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';


class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});

  @override
  State<MainLandingPage> createState() => _MainLandingPageState();
}


class _MainLandingPageState extends State<MainLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundgrey,
        elevation: 0,
        title: const Text(
          'Hi, User',
          style: TextStyle(color: AppColor.purpletext, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColor.purpletext),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColor.purpletext),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: AppColor.purpletext),
            onPressed: () {},
          ),
        ],

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "It's time to challenge your limits.",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureIcon(Icons.fitness_center, 'Workout'),
                  _buildFeatureIcon(Icons.insert_chart, 'Progress Tracking'),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Features',
                style: TextStyle(
                  color: AppColor.yellowtext,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'Exercise Posture Correction',
                'To Know the Basics',
                AppColor.purpletext,
                AppColor.yellowtext,
                'assets/gym8.jpg',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'Exercise Recognition',
                'Recommendation Exercises Especially For You',
                Colors.black,
                AppColor.yellowtext,
                'assets/gym6.jpg',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'Arcade Mode',
                'Challenge Yourself While Enjoying',
                AppColor.purpletext,
                AppColor.yellowtext,
                'assets/gym4.png',
              ),
            ],
          ),
        ),
      ),

      /*
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor.purpletext,
        selectedItemColor: AppColor.yellowtext,
        unselectedItemColor: Colors.white,
        items:  [
          BottomNavigationBarItem(
            icon: IconButton(onPressed: (){}, icon: Icon(Icons.file_copy,size: 20,)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(onPressed: (){}, icon: Icon(Icons.home,size: 25,)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(onPressed: (){}, icon: Icon(Icons.person,size: 25,)),
            label: '',
          ),
        ],
      ),
      */
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: AppColor.yellowtext, size: 30),
          onPressed: () {
            // Add functionality for the icon button here
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }


  Widget _buildFeatureCard(String title, String subtitle, Color bgColor, Color textColor, String imagePath) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
