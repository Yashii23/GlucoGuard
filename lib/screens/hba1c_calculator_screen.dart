import 'package:flutter/material.dart';

class Hba1cCalculatorScreen extends StatefulWidget {
  const Hba1cCalculatorScreen({super.key});

  @override
  State<Hba1cCalculatorScreen> createState() =>
      _Hba1cCalculatorScreenState();
}

class _Hba1cCalculatorScreenState
    extends State<Hba1cCalculatorScreen> {

  final TextEditingController sugarController =
      TextEditingController();

  double? hba1c;
  String result = "";
  Color resultColor = Colors.green;

  void calculate() {

    if (sugarController.text.isEmpty) return;

    final avgSugar =
        double.tryParse(sugarController.text) ?? 0;

    final value = (avgSugar + 46.7) / 28.7;

    setState(() {

      hba1c = value;

      if (value < 5.7) {

        result = "Normal";
        resultColor = Colors.green;

      } else if (value < 6.5) {

        result = "Prediabetes";
        resultColor = Colors.orange;

      } else {

        result = "Diabetes";
        resultColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF4F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "HbA1c Calculator",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(

                gradient: const LinearGradient(

                  colors: [

                    Color(0xff5B67FF),

                    Color(0xff7B61FF),

                  ],
                ),

                borderRadius:
                    BorderRadius.circular(25),
              ),

              child: const Column(

                children: [

                  Icon(
                    Icons.favorite,
                    size: 55,
                    color: Colors.white,
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Estimate your HbA1c",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Enter your average blood sugar level.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
                        Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Average Blood Sugar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: sugarController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter mg/dL",
                        prefixIcon: const Icon(Icons.monitor_heart),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff5B67FF),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: calculate,
                        child: const Text(
                          "Calculate HbA1c",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (hba1c != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    const Text(
                      "Estimated HbA1c",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "${hba1c!.toStringAsFixed(1)} %",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(.15),
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: Text(
                        result,
                        style: TextStyle(
                          color: resultColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                                        const Divider(height: 40),

                    Row(
                      children: [

                        Expanded(
                          child: _InfoTile(
                            title: "Normal",
                            value: "4.0 - 5.6 %",
                            color: Colors.green,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _InfoTile(
                            title: "Prediabetes",
                            value: "5.7 - 6.4 %",
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    _InfoTile(
                      title: "Diabetes",
                      value: "6.5 % or Higher",
                      color: Colors.red,
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xffEEF3FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Row(
                            children: [

                              Icon(
                                Icons.psychology,
                                color: Color(0xff5B67FF),
                              ),

                              SizedBox(width: 10),

                              Text(
                                "AI Health Advice",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Text(
                            result == "Normal"
                                ? "Excellent! Your estimated HbA1c indicates good glucose control. Continue following your healthy lifestyle and monitor regularly."

                                : result == "Prediabetes"
                                    ? "Your HbA1c suggests elevated blood sugar. Regular exercise, balanced meals, and routine monitoring can help improve control."

                                    : "Your estimated HbA1c is in the diabetes range. Please consult your healthcare provider and review your treatment plan.",

                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff5B67FF),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Report Saved Successfully"),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Save Report",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              Icons.favorite,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.check_circle,
            color: color,
          ),
        ],
      ),
    );
  }
}