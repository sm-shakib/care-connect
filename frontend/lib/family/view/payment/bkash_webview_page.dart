import 'package:flutter/material.dart';
import 'package:frontend/caregiver/data/repositories/booking_repository.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BkashWebViewPage extends StatefulWidget {
  const BkashWebViewPage({
    required this.bkashUrl,
    required this.bookingId,
    super.key,
  });

  final String bkashUrl;
  final int bookingId;

  @override
  State<BkashWebViewPage> createState() => _BkashWebViewPageState();
}

class _BkashWebViewPageState extends State<BkashWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            if (url.contains('success')) {
              _handlePaymentSuccess(request.url);
              return NavigationDecision.prevent;
            }
            if (url.contains('cancel') || url.contains('failure')) {
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.bkashUrl));
  }

  Future<void> _handlePaymentSuccess(String url) async {
    final uri = Uri.parse(url);
    final paymentId = uri.queryParameters['paymentID'];

    // Show loading
    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFD12053)),
        ),
      );
    }

    try {
      final repo = BookingRepository();
      // Even if paymentId is null, we call executeBkashPayment 
      // if our backend expects the booking ID to verify status.
      // Adjusting based on standard bKash flow.
      final updatedBooking = await repo.executeBkashPayment(
        widget.bookingId,
        paymentId ?? '',
      );
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context, updatedBooking); // Return updated booking to details page
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
        Navigator.pop(context); // Return failure
      }
    }
  }

  void _handlePaymentFailure() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment cancelled or failed')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'bKash Payment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD12053),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFD12053)),
            ),
        ],
      ),
    );
  }
}
