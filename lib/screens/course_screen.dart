import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/screens/new_user_dashboard.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/course_model.dart';
import 'course_detail_screen.dart';

class CourseScreen extends StatefulWidget {
  static const routeName = '/courses';
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _filteredCourses = [];
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _filteredCourses = courses;
    _searchController.addListener(_filterCourses);
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses =
          courses.where((course) {
            final matchesSearch =
                course['title'].toLowerCase().contains(query) ||
                course['instructor'].toLowerCase().contains(query);
            final matchesCategory =
                _selectedCategory == 'All' ||
                course['category'] == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Handle both back button cases
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const NewUserDashboardScreen(loginEmail: ''),
      ),
      (route) => false,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final categories = [
      'All',
      ...courses.map((course) => course['category'] as String).toSet(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              themeProvider.isDarkMode
                  ? Colors.teal.shade900
                  : Colors.teal.shade700,
          title: Text(
            'Cybersecurity Courses',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewUserDashboardScreen(loginEmail: ''),
                ),
                (route) => false,
              );
            },
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  themeProvider.isDarkMode
                      ? [Colors.grey.shade900, Colors.black87]
                      : [Colors.white, Colors.grey.shade100],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Enhanced Search Field with visible container
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[850]
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          _isSearchFocused
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.teal.shade200
                                  : Colors.teal,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterCourses();
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      style: GoogleFonts.poppins(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                ),

                // Custom Dropdown Container
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[850]
                              : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        underline: const SizedBox(),
                        dropdownColor:
                            themeProvider.isDarkMode
                                ? Colors.grey[850]
                                : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        items:
                            categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _filterCourses();
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // Course List with Scrollbar
                Expanded(
                  child:
                      _filteredCourses.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color:
                                      themeProvider.isDarkMode
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _selectedCategory = 'All';
                                        _filteredCourses = courses;
                                      });
                                    },
                                    child: Text(
                                      'Clear search',
                                      style: GoogleFonts.poppins(
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                          : Scrollbar(
                            thumbVisibility: true,
                            thickness: 4,
                            radius: const Radius.circular(8),
                            child: ListView.builder(
                              itemCount: _filteredCourses.length,
                              itemBuilder: (context, index) {
                                final course = _filteredCourses[index];
                                return FadeInUp(
                                  duration: Duration(
                                    milliseconds: 700 + (index * 100),
                                  ),
                                  child: CourseCard(course: course),
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap:
          () => Navigator.pushNamed(
            context,
            CourseDetailScreen.routeName,
            arguments: course,
          ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.isDarkMode
                    ? Colors.teal.shade900
                    : Colors.teal.shade600,
                themeProvider.isDarkMode
                    ? Colors.teal.shade700
                    : Colors.teal.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/computing1.jpg',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Image.asset(
                        'assets/images/default_course.png',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Instructor: ${course['instructor']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${course['category']} • Duration: ${course['duration']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: ${((course['progress'] as double?) ?? 0.0 * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                CourseDetailScreen.routeName,
                                arguments: course,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (course['progress'] as double?) ?? 0.0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.teal.shade200,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
