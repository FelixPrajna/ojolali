import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About This App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ojolali App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Menggunakan HtmlWidget untuk justify teks
            HtmlWidget(
              '''<p style="text-align: justify;">
                Ojolali adalah aplikasi layanan ojek online yang memudahkan pengguna untuk memesan ojek atau transportasi lain dengan mudah. 
                Dengan Ojolali, pengguna dapat mencari tujuan, melihat rute, dan memesan transportasi langsung dari aplikasi. 
                Aplikasi ini juga menyediakan berbagai fitur untuk memastikan kenyamanan dan keamanan pengguna dalam menggunakan layanan.
              </p>
              <p style="text-align: justify;">
                <b>Fitur Utama:</b><br>
                - Pemesanan ojek online secara real-time<br>
                - Pencarian tujuan secara cepat<br>
                - Tracking lokasi pengguna<br>
                - Informasi blokir akun untuk keamanan
              </p>
              ''',
              textStyle: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
