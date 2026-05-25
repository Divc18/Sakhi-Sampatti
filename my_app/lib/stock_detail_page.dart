import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_main_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockDetailPage extends StatefulWidget {
  final Stock stock;

  const StockDetailPage({super.key, required this.stock});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  String selectedPeriod = '1D';
  Offset? touchPosition;
  Map<String, dynamic>? touchedData;
  List<Map<String, dynamic>> historicalData = [];
  double? chartWidth;
  bool isLoadingHistory = true;
  String? historyError;
  double? liveChange;
  double? liveChangePct;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Generate unique historical data for each stock
  List<Map<String, dynamic>> _generateHistoricalData() {
    final random = math.Random(widget.stock.company.hashCode);
    final List<Map<String, dynamic>> data = [];

    final basePrice = widget.stock.price.toDouble();
    final highPrice = widget.stock.highestPrice.toDouble();
    final lowPrice = widget.stock.lowestPrice.toDouble();

    // Generate 50 data points
    double currentPrice = lowPrice;

    for (int i = 0; i < 50; i++) {
      // Gradually move from low to current price with realistic variations
      final progress = i / 50.0;
      final targetPrice = lowPrice + (basePrice - lowPrice) * progress;

      // Add some randomness
      final variation = (random.nextDouble() - 0.5) * (highPrice - lowPrice) * 0.1;
      currentPrice = (targetPrice + variation).clamp(lowPrice * 0.9, highPrice * 1.1);

      final open = currentPrice + (random.nextDouble() - 0.5) * 20;
      final close = currentPrice + (random.nextDouble() - 0.5) * 20;
      final high = math.max(open, close) + random.nextDouble() * 15;
      final low = math.min(open, close) - random.nextDouble() * 15;

      data.add({
        'open': open.clamp(lowPrice * 0.9, highPrice * 1.1),
        'high': high.clamp(lowPrice * 0.9, highPrice * 1.1),
        'low': low.clamp(lowPrice * 0.9, highPrice * 1.1),
        'close': close.clamp(lowPrice * 0.9, highPrice * 1.1),
        'timestamp': DateTime.now().subtract(Duration(hours: 50 - i)),
      });
    }

    return data;
  }
  String _historySymbol() {
    if (widget.stock.symbol.isNotEmpty) {
      return widget.stock.symbol;
    }

    final company = widget.stock.company.toUpperCase().trim();

    const mapping = {
      'RELIANCE': 'RELIANCE',
      'TCS': 'TCS',
      'INFOSYS': 'INFY',
      'HDFC BANK': 'HDFCBANK',
      'ICICI BANK': 'ICICIBANK',
      'KOTAK BANK': 'KOTAKBANK',
      'AXIS BANK': 'AXISBANK',
      'SBI': 'SBIN',
      'WIPRO': 'WIPRO',
      'HCL TECH': 'HCLTECH',
    };

    return mapping[company] ?? company.replaceAll(' ', '');
  }

  String _apiPeriod(String period) {
    switch (period) {
      case 'All':
        return 'ALL';
      default:
        return period;
    }
  }
  Future<void> _loadHistory() async {
    setState(() {
      isLoadingHistory = true;
      historyError = null;
    });

    try {
      final res = await http.get(
        Uri.parse(
          '${StockService.baseUrl}/stock/${_historySymbol()}/history?period=${_apiPeriod(selectedPeriod)}',
        ),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception("History API failed");
      }

      final decoded = jsonDecode(res.body);
      if (decoded is List && decoded.isNotEmpty) {
        final parsed = decoded.map<Map<String, dynamic>>((e) {
          return {
            'open': (e['open'] ?? 0).toDouble(),
            'high': (e['high'] ?? 0).toDouble(),
            'low': (e['low'] ?? 0).toDouble(),
            'close': (e['close'] ?? 0).toDouble(),
            'timestamp': DateTime.tryParse(e['timestamp'] ?? '') ?? DateTime.now(),
          };
        }).toList();

        double change = 0;
        double changePct = 0;

        if (parsed.length >= 2) {
          final first = parsed.first['close'] as double;
          final last = parsed.last['close'] as double;
          change = last - first;
          changePct = first == 0 ? 0 : (change / first) * 100;
        }

        setState(() {
          historicalData = parsed;
          liveChange = change;
          liveChangePct = changePct;
          isLoadingHistory = false;
        });
      } else {
        throw Exception("No history data");
      }
    } catch (e) {
      setState(() {
        historicalData = _generateHistoricalData();
        liveChange = 0;
        liveChangePct = widget.stock.changePercent;
        historyError = "Using fallback chart data";
        isLoadingHistory = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final double change = liveChange ?? 0;
    final double changePct = liveChangePct ?? widget.stock.changePercent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stock.company,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            const Text(
              "NSE",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // PRICE SECTION
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  touchedData != null
                      ? "₹${touchedData!['close'].toStringAsFixed(2)}"
                      : "₹${widget.stock.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${change.toStringAsFixed(2)} (${changePct.toStringAsFixed(2)}%)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: change >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedPeriod,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Show OHLC data when touching
                if (touchedData != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOHLCItem('Open', touchedData!['open']),
                        _buildOHLCItem('High', touchedData!['high']),
                        _buildOHLCItem('Low', touchedData!['low']),
                        _buildOHLCItem('Close', touchedData!['close']),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // CHART WITH TOUCH INTERACTION
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  _handleTouch(details.localPosition);
                },
                onPanUpdate: (details) {
                  _handleTouch(details.localPosition);
                },
                onPanEnd: (details) {
                  // Don't clear immediately - use a delay
                  Future.delayed(const Duration(seconds: 15), () {
                    if (mounted) {
                      setState(() {
                        touchPosition = null;
                        touchedData = null;
                      });
                    }
                  });
                },
                onTapDown: (details) {
                  _handleTouch(details.localPosition);
                  // Keep it visible for 2 seconds after tap
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        touchPosition = null;
                        touchedData = null;
                      });
                    }
                  });
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    chartWidth = constraints.maxWidth;
                    return CustomPaint(
                      painter: StockChartPainter(
                        color: change >= 0 ? Colors.green : Colors.red,
                        touchPosition: touchPosition,
                        historicalData: historicalData,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    );
                  },
                ),
              ),
            ),
          ),

          // TIME PERIOD SELECTOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodButton('1D'),
                  _buildPeriodButton('1W'),
                  _buildPeriodButton('1M'),
                  _buildPeriodButton('3M'),
                  _buildPeriodButton('6M'),
                  _buildPeriodButton('1Y'),
                  _buildPeriodButton('5Y'),
                  _buildPeriodButton('All'),
                ],
              ),
            ),
          ),

          // BUY BUTTON ONLY
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      addStockToWatchlist(widget.stock);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${widget.stock.company} added to Watchlist 1"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add to Watchlist",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyStockPage(stock: widget.stock),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Buy",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset position) {
    if (chartWidth == null) return;

    // Calculate which data point was touched
    final index = ((position.dx / chartWidth!) * historicalData.length)
        .clamp(0, historicalData.length - 1)
        .toInt();

    setState(() {
      touchPosition = position;
      touchedData = historicalData[index];
    });
  }

  Widget _buildOHLCItem(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
        _loadHistory();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[800] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class StockChartPainter extends CustomPainter {
  final Color color;
  final Offset? touchPosition;
  final List<Map<String, dynamic>> historicalData;

  StockChartPainter({
    required this.color,
    this.touchPosition,
    required this.historicalData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historicalData.isEmpty || size.width == 0 || size.height == 0) return;

    // Extract close prices for the line chart
    final List<double> dataPoints = historicalData.map((d) => d['close'] as double).toList();

    double minY = dataPoints.reduce(math.min);
    double maxY = dataPoints.reduce(math.max);
    double range = maxY - minY;
    if (range == 0) range = 1;

    final path = Path();
    final gradientPath = Path();
    final List<Offset> points = [];

    for (int i = 0; i < dataPoints.length; i++) {
      double x = (i / (dataPoints.length - 1)) * size.width;
      double normalizedY = (dataPoints[i] - minY) / range;
      double y = size.height - (normalizedY * size.height * 0.85) - (size.height * 0.075);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    // Draw gradient
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.1),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(gradientPath, gradientPaint);

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Handle touch interaction
    if (touchPosition != null) {
      // Find closest point
      int closestIndex = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < points.length; i++) {
        double distance = (points[i].dx - touchPosition!.dx).abs();
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }

      final touchedPoint = points[closestIndex];

      // Draw vertical line at touch point
      final verticalLinePaint = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(touchedPoint.dx, 0),
        Offset(touchedPoint.dx, size.height),
        verticalLinePaint,
      );

      // Draw circle at intersection
      final circlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final circleOutlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(touchedPoint, 6, circleOutlinePaint);
      canvas.drawCircle(touchedPoint, 6, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant StockChartPainter oldDelegate) {
    return oldDelegate.touchPosition != touchPosition;
  }
}
