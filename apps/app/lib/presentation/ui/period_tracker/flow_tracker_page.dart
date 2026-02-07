import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/ui/common/app_colors.dart';
import 'package:flutter_app/presentation/ui/period_tracker/widgets/calendar_strip.dart';
import 'package:flutter_app/presentation/ui/period_tracker/widgets/circular_tracker.dart';
import 'package:flutter_app/composition_root/repositories/flow_repository.dart';

class FlowTrackerPage extends ConsumerStatefulWidget {
  const FlowTrackerPage({super.key});

  static const routeName = '/flow-tracker';

  @override
  ConsumerState<FlowTrackerPage> createState() => _FlowTrackerPageState();
}

class _FlowTrackerPageState extends ConsumerState<FlowTrackerPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final now = DateTime.now();
    await ref.read(flowRepositoryProvider).getCalendarData(now.month, now.year);
    // TODO: Store this data in a provider or use FutureProvider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Flow Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.rose.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Calendar Strip
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: CalendarStrip(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Circular Tracker
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: CircularTracker(
                          dayOfCycle: 1, // Mock
                          isPeriodDay: false,
                        ),
                      ),
                      
                      SizedBox(height: 32),

                      // Placeholder for Daily Logs
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Daily Log", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                Text("No symptoms logged for today."),
                                SizedBox(height: 10),
                                // TextButton(onPressed: () {}, child: Text("Log Symptoms"))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
            // Demo: Log Period Start
            try {
                await ref.read(flowRepositoryProvider).logPeriodStart(DateTime.now());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Period Started!")));
            } catch(e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
        },
        label: const Text("Log Period"),
        icon: const Icon(Icons.water_drop),
        backgroundColor: AppColors.rose,
      ),
    );
  }
}
