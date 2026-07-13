// lib/screens/talk_to_doctor_screen.dart
// STEP 9 — Talk to Doctor Screen
// Paste this file in: lib/screens/talk_to_doctor_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TalkToDoctorScreen extends StatelessWidget {
  const TalkToDoctorScreen({super.key});

  // NOTE: Add url_launcher: ^6.3.0 to pubspec.yaml for this screen

  Future<void> _launchPhone(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make call on this device')),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Diabetes%20Consultation&body=Hello%20Doctor%2C%20I%20need%20a%20consultation.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎥 Talk to Doctor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video call placeholder
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'Video call not active',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a button below to connect',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  // Simulated "self" preview
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white54, size: 32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Connect with Your Doctor',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Action buttons
            _ActionButton(
              icon: Icons.call,
              label: 'Call Doctor',
              subtitle: 'Direct phone call',
              color: Colors.green,
              onTap: () => _launchPhone(context, '+911234567890'),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.video_call,
              label: 'Video Consultation',
              subtitle: 'Online video call (opens app)',
              color: Colors.blue,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Integrate with Zoom, Google Meet, or Practo API here'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.chat,
              label: 'Chat / Message',
              subtitle: 'Send a message to your doctor',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connect messaging service here'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.email,
              label: 'Email Doctor',
              subtitle: 'Send medical report by email',
              color: Colors.orange,
              onTap: () => _launchEmail(context, 'doctor@hospital.com'),
            ),
            const SizedBox(height: 24),

            // Emergency numbers
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emergency, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text('Emergency Numbers',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _EmergencyRow('Ambulance (India)', '108',
                        () => _launchPhone(context, '108')),
                    _EmergencyRow('Emergency', '112',
                        () => _launchPhone(context, '112')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyRow extends StatelessWidget {
  final String label;
  final String number;
  final VoidCallback onTap;

  const _EmergencyRow(this.label, this.number, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.call, size: 16),
            label: Text(number,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
