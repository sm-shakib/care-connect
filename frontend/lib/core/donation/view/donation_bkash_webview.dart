import 'package:flutter/material.dart';
import 'package:frontend/core/donation/data/donation_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DonationBkashWebView extends StatefulWidget {
  const DonationBkashWebView({
    required this.bkashUrl,
    required this.donationId,
    super.key,
  });

  final String bkashUrl;
  final int donationId;

  @override
  State<DonationBkashWebView> createState() => _DonationBkashWebViewState();
}

class _DonationBkashWebViewState extends State<DonationBkashWebView> {
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
      final repo = DonationRepository();
      await repo.executeDonationBkashPayment(
        widget.donationId,
        paymentId ?? '',
      );
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context, true); // Return success to flow page
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation verification failed: $e')),
        );
        Navigator.pop(context, false);
      }
    }
  }

  void _handlePaymentFailure() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation cancelled or failed')),
      );
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'bKash Donation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD12053),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
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
