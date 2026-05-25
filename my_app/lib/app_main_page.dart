import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stock_scrolling_options.dart';
import 'profile_icon.dart';
import 'package:flutter/gestures.dart';
import 'stock_detail_page.dart';
import 'data_bridge.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math' show min;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'shg.dart';

ValueNotifier<List<Map<String, dynamic>>> orders =
ValueNotifier<List<Map<String, dynamic>>>([]);
ValueNotifier<List<Map<String, dynamic>>> holdings =
ValueNotifier<List<Map<String, dynamic>>>([]);

ValueNotifier<List<String>> notifications =
ValueNotifier<List<String>>([]);
ValueNotifier<List<Stock>> liveStocks = ValueNotifier<List<Stock>>([]);

ValueNotifier<List<String>> watchlistNamesNotifier =
ValueNotifier<List<String>>(["Watchlist 1"]);

ValueNotifier<Map<int, List<Stock>>> watchlistsNotifier =
ValueNotifier<Map<int, List<Stock>>>({0: []});

void addStockToWatchlist(Stock stock, {int watchlistIndex = 0}) {
  final current = Map<int, List<Stock>>.from(watchlistsNotifier.value);
  final list = List<Stock>.from(current[watchlistIndex] ?? []);

  final exists = list.any(
        (s) => (s.symbol.isNotEmpty && s.symbol == stock.symbol) || s.company == stock.company,
  );

  if (!exists) {
    list.add(stock);
    current[watchlistIndex] = list;
    watchlistsNotifier.value = current;
  }
}

void removeStockFromWatchlist(Stock stock, {int watchlistIndex = 0}) {
  final current = Map<int, List<Stock>>.from(watchlistsNotifier.value);
  final list = List<Stock>.from(current[watchlistIndex] ?? []);

  list.removeWhere(
        (s) => (s.symbol.isNotEmpty && s.symbol == stock.symbol) || s.company == stock.company,
  );

  current[watchlistIndex] = list;
  watchlistsNotifier.value = current;
}

void createWatchlist(String name) {
  final names = List<String>.from(watchlistNamesNotifier.value);
  final lists = Map<int, List<Stock>>.from(watchlistsNotifier.value);

  final newIndex = names.length;
  names.add(name);
  lists[newIndex] = [];

  watchlistNamesNotifier.value = names;
  watchlistsNotifier.value = lists;
}

void renameWatchlist(int index, String name) {
  final names = List<String>.from(watchlistNamesNotifier.value);
  if (index >= 0 && index < names.length) {
    names[index] = name;
    watchlistNamesNotifier.value = names;
  }
}

void deleteWatchlist(int index) {
  final names = List<String>.from(watchlistNamesNotifier.value);
  final lists = Map<int, List<Stock>>.from(watchlistsNotifier.value);

  if (names.length == 1 || index < 0 || index >= names.length) return;

  names.removeAt(index);
  lists.remove(index);

  final rebuilt = <int, List<Stock>>{};
  for (int i = 0; i < names.length; i++) {
    rebuilt[i] = List<Stock>.from(lists[i] ?? []);
  }

  watchlistNamesNotifier.value = names;
  watchlistsNotifier.value = rebuilt;
}

class MainPage extends StatefulWidget {
  final String userName;
  const MainPage({Key? key, required this.userName}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ExplorePage(),
    GovtPage(),
    AddPage(),
    StocksPage(),
    WatchlistPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String initial =
    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "U";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Sakhi Sampatti",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(username: "Ramesh Saini")),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text(
                  initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow), label: "Explore"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: "Govt"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: "Stocks"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: "Watchlist"),
          
        ],
      ),
    );
  }
}

// ===================== STOCK MODEL =====================
class Stock {
  final String company;
  final String symbol;
  final double price;
  final double highestPrice;
  final double lowestPrice;
  final double changePercent;

  Stock({
    required this.company,
    required this.symbol,
    required this.price,
    required this.highestPrice,
    required this.lowestPrice,
    required this.changePercent,
  });

  factory Stock.fromApi(Map<String, dynamic> json) {
    return Stock(
      company: json['company'] ?? json['symbol'],
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      highestPrice: (json['dayHigh'] ?? 0).toDouble(),
      lowestPrice: (json['dayLow'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
    );
  }
}

// ===================== FALLBACK DATA =====================
final List<Stock> fallbackStocks = [
  Stock(company: "Reliance", symbol: "RELIANCE", price: 2500.0, highestPrice: 2700.0, lowestPrice: 2300.0, changePercent: 0),
  Stock(company: "TCS", symbol: "TCS", price: 3200.0, highestPrice: 3400.0, lowestPrice: 3000.0, changePercent: 0),
  Stock(company: "Infosys", symbol: "INFY", price: 1500.0, highestPrice: 1650.0, lowestPrice: 1400.0, changePercent: 0),
  Stock(company: "HDFC Bank", symbol: "HDFCBANK", price: 1600.0, highestPrice: 1750.0, lowestPrice: 1500.0, changePercent: 0),
  Stock(company: "ICICI Bank", symbol: "ICICIBANK", price: 950.0, highestPrice: 1050.0, lowestPrice: 900.0, changePercent: 0),
  Stock(company: "Kotak Bank", symbol: "KOTAKBANK", price: 1850.0, highestPrice: 2000.0, lowestPrice: 1700.0, changePercent: 0),
  Stock(company: "Axis Bank", symbol: "AXISBANK", price: 880.0, highestPrice: 950.0, lowestPrice: 820.0, changePercent: 0),
  Stock(company: "SBI", symbol: "SBIN", price: 600.0, highestPrice: 670.0, lowestPrice: 550.0, changePercent: 0),
  Stock(company: "Wipro", symbol: "WIPRO", price: 420.0, highestPrice: 460.0, lowestPrice: 400.0, changePercent: 0),
  Stock(company: "HCL Tech", symbol: "HCLTECH", price: 1200.0, highestPrice: 1300.0, lowestPrice: 1100.0, changePercent: 0),
  Stock(company: "Tech Mahindra", symbol: "TECHM", price: 1050.0, highestPrice: 1150.0, lowestPrice: 980.0, changePercent: 0),
  Stock(company: "Adani Enterprises", symbol: "ADANIENT", price: 2200.0, highestPrice: 2450.0, lowestPrice: 2000.0, changePercent: 0),
  Stock(company: "Adani Ports", symbol: "ADANIPORTS", price: 950.0, highestPrice: 1050.0, lowestPrice: 880.0, changePercent: 0),
  Stock(company: "Bharti Airtel", symbol: "BHARTIARTL", price: 780.0, highestPrice: 850.0, lowestPrice: 730.0, changePercent: 0),
  Stock(company: "Maruti Suzuki", symbol: "MARUTI", price: 9800.0, highestPrice: 10200.0, lowestPrice: 9200.0, changePercent: 0),
  Stock(company: "Mahindra & Mahindra", symbol: "M&M", price: 1600.0, highestPrice: 1750.0, lowestPrice: 1500.0, changePercent: 0),
  Stock(company: "Tata Motors", symbol: "TATAMOTORS", price: 620.0, highestPrice: 700.0, lowestPrice: 580.0, changePercent: 0),
  Stock(company: "Bajaj Auto", symbol: "BAJAJ-AUTO", price: 4200.0, highestPrice: 4500.0, lowestPrice: 3900.0, changePercent: 0),
  Stock(company: "Hero MotoCorp", symbol: "HEROMOTOCO", price: 3200.0, highestPrice: 3450.0, lowestPrice: 3000.0, changePercent: 0),
  Stock(company: "Eicher Motors", symbol: "EICHERMOT", price: 3800.0, highestPrice: 4100.0, lowestPrice: 3500.0, changePercent: 0),
];

// ===================== STOCK SERVICE =====================
class StockService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllStocks() async {
    final symbols = [
      'RELIANCE',
      'TCS',
      'INFY',
      'HDFCBANK',
      'ICICIBANK',
      'KOTAKBANK',
      'AXISBANK',
      'SBIN',
      'WIPRO',
      'HCLTECH',
      'TECHM',
      'ADANIENT',
      'ADANIPORTS',
      'BHARTIARTL',
      'MARUTI',
      'M&M',
      'TATAMOTORS',
      'BAJAJ-AUTO',
      'HEROMOTOCO',
      'EICHERMOT',
    ];

    final uri = Uri.parse('$baseUrl/stocks/bulk');
    debugPrint('Fetching stocks from: $uri');

    final res = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"symbols": symbols}),
    )
        .timeout(const Duration(seconds: 12));

    debugPrint('Stock API status: ${res.statusCode}');
    debugPrint('Stock API body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception(
        "Failed to fetch stocks. Status: ${res.statusCode}, Body: ${res.body}",
      );
    }

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (decoded['error'] != null) {
        throw Exception(decoded['error']);
      }
    }

    throw Exception("Unexpected API response: ${res.body}");
  }
}
// ----------------- Stocks Page -----------------
class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Stock> exploreData = [];
  bool isLoading = true;
  String? errorMsg;
  Timer? _refreshTimer;

  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStocks();

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final data = await StockService.fetchAllStocks();
        if (data.isNotEmpty && mounted) {
          final stocks = data.map((e) => Stock.fromApi(e)).toList();
          setState(() {
            exploreData = stocks;
            isLoading = false;
          });
          liveStocks.value = stocks; // ← outside setState
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStocks() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final data = await StockService.fetchAllStocks();

      if (data.isEmpty) {
        _loadFallback("Backend returned no live stock data");
        return;
      }

      final stocks = data.map((e) => Stock.fromApi(e)).toList(); // ← fixed
      setState(() {
        exploreData = stocks;
        isLoading = false;
      });
      liveStocks.value = stocks; // ← outside setState

    } catch (e) {
      _loadFallback("Offline mode — using cached data");
    }
  }

  void _loadFallback(String message) {
    final fallback = List<Stock>.from(fallbackStocks);

    setState(() {
      exploreData = fallback;
      isLoading = false;
      errorMsg = message;
    });

    liveStocks.value = fallback;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Offline banner
            if (errorMsg != null)
              Container(
                color: Colors.orange.shade100,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(errorMsg!,
                            style: const TextStyle(fontSize: 12))),
                    TextButton(
                        onPressed: _loadStocks,
                        child: const Text("Retry")),
                  ],
                ),
              ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: "Explore"),
                Tab(text: "Holding"),
                Tab(text: "Orders"),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                controller: _tabController,
                children: [
                  ExploreTab(
                      data: exploreData, onRefresh: _loadStocks),
                  const HoldingTab(),
                  const OrderTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Explore Tab -----------------
class ExploreTab extends StatefulWidget {
  final List<Stock> data;
  final VoidCallback? onRefresh;

  const ExploreTab({super.key, required this.data, this.onRefresh});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  int _priceMode = 0; // 0 = Mkt Price, 1 = High, 2 = Low

  String get _headerText {
    switch (_priceMode) {
      case 1:
        return "<52W High>";
      case 2:
        return "<52W Low>";
      default:
        return "<Mkt Price>";
    }
  }

  String _getPrice(Stock stock) {
    double value;
    switch (_priceMode) {
      case 1:
        value = stock.highestPrice;
        break;
      case 2:
        value = stock.lowestPrice;
        break;
      default:
        value = stock.price;
    }
    return '₹${value.toStringAsFixed(2)}';
  }

  double _getPercentage(Stock stock) {
    if (_priceMode == 0) return stock.changePercent;
    return 0;
  }

  void _togglePriceMode() {
    setState(() {
      _priceMode = (_priceMode + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row
        Container(
          color: Colors.white,
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Company",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _togglePriceMode,
                    child: Text(
                      _headerText,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable Data Rows
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onRefresh?.call(),
            child: ListView.separated(
              itemCount: widget.data.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                ),
              ),
              itemBuilder: (context, index) {
                final stock = widget.data[index];
                final perc = _getPercentage(stock);
                final percText = perc >= 0
                    ? '+${perc.toStringAsFixed(2)}%'
                    : '${perc.toStringAsFixed(2)}%';
                final percColor =
                perc >= 0 ? Colors.green : Colors.red;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StockDetailPage(stock: stock),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            stock.company,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: [
                                Text(_getPrice(stock),
                                    style: const TextStyle(
                                        fontSize: 16)),
                                if (_priceMode == 0)
                                  Text(
                                    percText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: percColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuButton<int>(
                          icon: const Icon(Icons.more_vert),
                          offset: const Offset(0, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: Colors.white,
                          elevation: 12,
                          onSelected: (value) {
                            if (value == 1) {
                              addStockToWatchlist(stock);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${stock.company} added to Watchlist 1"),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else if (value == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuyStockPage(stock: stock),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: const [
                                  Icon(Icons.star_border,
                                      size: 18,
                                      color: Colors.black87),
                                  SizedBox(width: 12),
                                  Text(
                                    'Add to Watchlist',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: const [
                                  Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 18,
                                      color: Colors.black87),
                                  SizedBox(width: 12),
                                  Text(
                                    'Add to Buy Stock',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------- Holding Tab -----------------
class HoldingTab extends StatelessWidget {
  const HoldingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: holdings,
      builder: (_, holdingList, __) {
        if (holdingList.isEmpty) {
          return const Center(
            child: Text(
              "No holdings yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.white,
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Company",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Qty",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Avg",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: holdingList.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (_, i) {
                    final holding = holdingList[i];
                    final qty = (holding["quantity"] ?? 0) as int;
                    final avgPrice =
                    ((holding["avgPrice"] ?? 0) as num).toDouble();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              holding["stock"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "$qty",
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "₹${avgPrice.toStringAsFixed(2)}",
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------- Order Tab -----------------
class OrderTab extends StatefulWidget {
  const OrderTab({super.key});

  @override
  State<OrderTab> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrderTab> {
  void _cancelOrder(int index) {
    final list = List<Map<String, dynamic>>.from(orders.value);
    list.removeAt(index);
    orders.value = list;
  }

  void _showDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrdersTab(
          onCancel: _cancelOrder,
          onDetails: _showDetails,
        ),
      ),
    );
  }
}

class OrdersTab extends StatelessWidget {
  final Function(int) onCancel;
  final Function(Map<String, dynamic>) onDetails;

  const OrdersTab({
    super.key,
    required this.onCancel,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: orders,
      builder: (_, orderList, __) {
        if (orderList.isEmpty) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/empty.jpeg",
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "You have no equity open orders",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        "Company",
                        style:
                        TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "Quantity",
                      style:
                      TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: orderList.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final order = orderList[index];

                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              order['stock'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            "${order['quantity']}",
                            style:
                            const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == "Details") {
                                onDetails(order);
                              } else if (value ==
                                  "Cancel Order") {
                                onCancel(index);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: "Details",
                                  child: Text("Details")),
                              PopupMenuItem(
                                  value: "Cancel Order",
                                  child: Text("Cancel Order")),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${order['stock']} Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Text(
          "Stock: ${order['stock']}\nQuantity: ${order['quantity']}",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BuyStockPage extends StatefulWidget {
  final Stock stock;

  const BuyStockPage({super.key, required this.stock});

  @override
  State<BuyStockPage> createState() => _BuyStockPageState();
}

class _BuyStockPageState extends State<BuyStockPage> {
  final TextEditingController _qtyController =
  TextEditingController();
  int quantity = 0;
  late double limitPrice;

  @override
  void initState() {
    super.initState();
    limitPrice = widget.stock.price * 1.02;
  }

  void _placeOrder() {
    final requiredAmount = quantity * limitPrice;

    if (walletBalance.value < requiredAmount || quantity <= 0) return;

    walletBalance.value -= requiredAmount;

    // keep order history
    orders.value = [
      {
        "stock": widget.stock.company,
        "symbol": widget.stock.symbol,
        "quantity": quantity,
        "price": limitPrice,
      },
      ...orders.value,
    ];

    // update holdings
    final currentHoldings = List<Map<String, dynamic>>.from(holdings.value);

    final existingIndex = currentHoldings.indexWhere(
          (h) =>
      (widget.stock.symbol.isNotEmpty &&
          h["symbol"] == widget.stock.symbol) ||
          h["stock"] == widget.stock.company,
    );

    if (existingIndex != -1) {
      final existing = Map<String, dynamic>.from(currentHoldings[existingIndex]);

      final oldQty = (existing["quantity"] ?? 0) as int;
      final oldAvg = ((existing["avgPrice"] ?? 0) as num).toDouble();

      final newQty = oldQty + quantity;
      final newAvg =
          ((oldQty * oldAvg) + (quantity * limitPrice)) / newQty;

      existing["quantity"] = newQty;
      existing["avgPrice"] = newAvg;
      existing["stock"] = widget.stock.company;
      existing["symbol"] = widget.stock.symbol;
      existing["currentPrice"] = widget.stock.price;

      currentHoldings[existingIndex] = existing;
    } else {
      currentHoldings.add({
        "stock": widget.stock.company,
        "symbol": widget.stock.symbol,
        "quantity": quantity,
        "avgPrice": limitPrice,
        "currentPrice": widget.stock.price,
      });
    }

    holdings.value = currentHoldings;

    notifications.value = [
      "Bought $quantity shares of ${widget.stock.company}",
      ...notifications.value,
    ];

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final requiredAmount = quantity * limitPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Text(widget.stock.company),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "NSE ₹${widget.stock.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "(${widget.stock.changePercent.toStringAsFixed(2)}%)",
                  style: TextStyle(
                      color: widget.stock.changePercent >= 0
                          ? Colors.green
                          : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Qty", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                const Text(
                  "NSE",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                SizedBox(
                  width: 140,
                  height: 44,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        quantity = int.tryParse(val) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text("Price",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Text(
                  "Limit",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  limitPrice.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "+2.00% from market",
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            const Spacer(),
            ValueListenableBuilder<double>(
              valueListenable: walletBalance,
              builder: (_, balance, __) {
                final canBuy =
                    balance >= requiredAmount && quantity > 0;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Balance: ₹${balance.toStringAsFixed(0)}"),
                        Text(
                            "Required: ₹${requiredAmount.toStringAsFixed(0)}"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canBuy ? _placeOrder : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canBuy
                              ? Colors.blue
                              : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== WATCHLIST PAGE =====================
class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int selectedWatchlist = 0;
  int priceMode = 0;

  final TextEditingController _searchCtrl = TextEditingController();

  List<Stock> get allStocks =>
      liveStocks.value.isNotEmpty
          ? liveStocks.value
          : List<Stock>.from(fallbackStocks);

  String get header {
    switch (priceMode) {
      case 1:
        return "<52W High>";
      case 2:
        return "<52W Low>";
      default:
        return "<Mkt Price>";
    }
  }

  String priceText(Stock s) {
    switch (priceMode) {
      case 1:
        return "₹${s.highestPrice.toStringAsFixed(2)}";
      case 2:
        return "₹${s.lowestPrice.toStringAsFixed(2)}";
      default:
        return "₹${s.price.toStringAsFixed(2)}";
    }
  }

  double percentage(Stock s) {
    if (priceMode == 0) return s.changePercent;
    double base = s.price;
    double current =
    priceMode == 1 ? s.highestPrice : s.lowestPrice;
    return ((current - base) / base) * 100;
  }

  void _deleteWatchlist() {
    if (watchlistNamesNotifier.value.length == 1) return;

    deleteWatchlist(selectedWatchlist);

    setState(() {
      selectedWatchlist =
      selectedWatchlist == 0 ? 0 : selectedWatchlist - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder<Map<int, List<Stock>>>(
      valueListenable: watchlistsNotifier,
      builder: (_, watchlists, __) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: watchlistNamesNotifier,
          builder: (_, watchlistNames, ___) {
            if (!watchlists.containsKey(selectedWatchlist)) {
              selectedWatchlist = 0;
            }

            final stocks = List<Stock>.from(
              watchlists[selectedWatchlist] ?? [],
            );
            final query = _searchCtrl.text.toLowerCase();

            final searchResults = query.isEmpty
                ? <Stock>[]
                : allStocks.where((s) {
              final alreadyExists = stocks.any(
                    (w) =>
                (w.symbol.isNotEmpty &&
                    s.symbol.isNotEmpty &&
                    w.symbol == s.symbol) ||
                    w.company == s.company,
              );
              return s.company.toLowerCase().contains(query) &&
                  !alreadyExists;
            }).toList();

            return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Watchlists",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                final ctrl = TextEditingController(
                                  text: watchlistNames[selectedWatchlist],
                                );

                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      AlertDialog(
                                        title: const Text("Rename Watchlist"),
                                        content: TextField(controller: ctrl),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              renameWatchlist(
                                                selectedWatchlist,
                                                ctrl.text
                                                    .trim()
                                                    .isEmpty
                                                    ? watchlistNames[selectedWatchlist]
                                                    : ctrl.text.trim(),
                                              );
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Save"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: _deleteWatchlist,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                final i = watchlistNames.length;
                                createWatchlist("Watchlist ${i + 1}");
                                setState(() {
                                  selectedWatchlist = i;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: watchlistNames.length,
                      itemBuilder: (_, i) {
                        final selected = i == selectedWatchlist;
                        return GestureDetector(
                          onTap: () => setState(() => selectedWatchlist = i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.grey.shade300
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              watchlistNames[i],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search stocks",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (_, i) {
                          final s = searchResults[i];
                          return ListTile(
                            title: Text(s.company),
                            trailing: const Icon(Icons.add),
                            onTap: () {
                              addStockToWatchlist(
                                s,
                                watchlistIndex: selectedWatchlist,
                              );
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Company",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              priceMode = (priceMode + 1) % 3;
                            });
                          },
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: stocks.isEmpty
                        ? const Center(
                      child: Text(
                        "No stocks in this watchlist",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : ListView.separated(
                      itemCount: stocks.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey.shade300),
                      itemBuilder: (_, i) {
                        final s = stocks[i];
                        final pct = percentage(s);
                        final positive = pct >= 0;

                        return Dismissible(
                          key: Key("${s.company}$i"),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.grey,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            removeStockFromWatchlist(
                              s,
                              watchlistIndex: selectedWatchlist,
                            );
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.company,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      priceText(s),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${positive ? "+" : ""}${pct
                                          .toStringAsFixed(2)}%",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: positive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// =================== ADD PAGE ===================
class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<BusinessRequest> _approvedBusinesses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApprovedBusinesses();
  }

  Future<void> _loadApprovedBusinesses() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final approved = await DataBridge.getApprovedRequests();
    setState(() {
      _approvedBusinesses = approved;
      _isLoading = false;
    });
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => const AddBusinessDialog(),
    ).then((_) => _loadApprovedBusinesses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Businesses"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApprovedBusinesses,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _approvedBusinesses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No approved businesses yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add your first business to get started",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _openAddDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child:
                    const Text("Add Business"),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount:
              _approvedBusinesses.length,
              itemBuilder: (context, index) {
                final b =
                _approvedBusinesses[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.store,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      b.businessName,
                      style: const TextStyle(
                          fontWeight:
                          FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.category,
                          style: TextStyle(
                              color:
                              Colors.grey[600]),
                        ),
                        Text(
                          b.description,
                          style: const TextStyle(
                              fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.verified,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _openAddDialog,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child:
                  Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =================== ADD BUSINESS DIALOG ===================
class AddBusinessDialog extends StatefulWidget {
  const AddBusinessDialog({super.key});

  @override
  State<AddBusinessDialog> createState() =>
      _AddBusinessDialogState();
}

class _AddBusinessDialogState extends State<AddBusinessDialog> {
  int step = 0;
  final businessName = TextEditingController();
  final stockMarketId = TextEditingController();
  final userName = TextEditingController();
  final userMobile = TextEditingController();
  String selectedCategory = "Retail";
  bool _termsAccepted = false;
  bool _showTerms = false;

  final Map<String, Map<String, dynamic>> documents = {
    "PAN Card": {
      "uploaded": false,
      "filePath": null,
      "fileName": null,
      "fileBytes": null,
    },
    "Address Proof": {
      "uploaded": false,
      "filePath": null,
      "fileName": null,
      "fileBytes": null,
    },
    "Collateral Document": {
      "uploaded": false,
      "filePath": null,
      "fileName": null,
      "fileBytes": null,
    },
  };

  bool get allDocsUploaded =>
      documents.values.every((doc) => doc["uploaded"] == true);

  bool _isValidStockId(String value) {
    return RegExp(r'^\d{8}$').hasMatch(value);
  }

  bool _isValidMobile(String value) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(value);
  }

  Future<void> _pickFile(String documentType) async {
    try {
      FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'doc',
          'docx'
        ],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          documents[documentType] = {
            "uploaded": true,
            "fileName": file.name,
            "fileBytes": file.bytes,
            "fileSize": file.size,
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("✅ ${file.name} uploaded successfully"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildPricingSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.currency_rupee, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Pricing Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFeeRow("Registration Fee", 499.0, true),
          _buildFeeRow("Monthly Listing", 99.0, false),
          _buildFeeRow("Verification Fee", 199.0, true),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total First Payment:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "₹698.00",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Note: ₹99/month will be charged after first 30 days",
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(
      String title, double amount, bool required) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title),
              if (required)
                const Text(
                  " *",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: required ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showTerms = !_showTerms;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _showTerms
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          if (_showTerms) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                MediaQuery.of(context).size.height * 0.3,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermPoint(
                        "1. Registration fee of ₹499 is non-refundable"),
                    _buildTermPoint(
                        "2. Monthly listing fee of ₹99 will be charged after 30 days"),
                    _buildTermPoint(
                        "3. Verification fee of ₹199 is one-time payment"),
                    _buildTermPoint(
                        "4. Business verification takes 3-5 working days"),
                    _buildTermPoint(
                        "5. Sakhi Sampatti reserves the right to reject applications"),
                    _buildTermPoint(
                        "6. All documents must be valid and authentic"),
                    _buildTermPoint(
                        "7. Monthly fee is auto-debited from registered account"),
                    _buildTermPoint(
                        "8. 7-day cooling period for cancellation"),
                    _buildTermPoint(
                        "9. GST and other taxes as applicable"),
                    _buildTermPoint(
                        "10. Platform commission: 2% on all transactions"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _termsAccepted
                    ? Colors.green.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _termsAccepted
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const Expanded(
                    child: Text(
                      "I agree to all terms & conditions and pricing mentioned above",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTermPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please accept the terms & conditions to proceed"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!allDocsUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Please upload all required documents"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (userName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (userMobile.text.isEmpty ||
        !_isValidMobile(userMobile.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please enter a valid 10-digit mobile number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (businessName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a business name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidStockId(stockMarketId.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please enter a valid 8-digit Stock Market ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
      const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 1));

    try {
      final uploadedDocuments = documents.entries
          .where((entry) => entry.value["uploaded"] == true)
          .map(
            (entry) => UploadedDocument(
          documentType: entry.key,
          fileName: entry.value["fileName"] ?? entry.key,
          base64Data: entry.value["fileBytes"] != null
              ? base64Encode(entry.value["fileBytes"] as List<int>)
              : null,
        ),
      )
          .toList();

      final newRequest = BusinessRequest(
        businessName: businessName.text.trim(),
        category: selectedCategory,
        description: "Stock ID: ${stockMarketId.text.trim()}",
        documents: uploadedDocuments,
        userName: userName.text.trim(),
        userMobile: userMobile.text.trim(),
        approved: false,
      );
      await DataBridge.saveRequest(newRequest);

      if (context.mounted) Navigator.pop(context);
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Column(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green, size: 50),
                SizedBox(height: 16),
                Text(
                  "Request Submitted!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your business verification request has been sent to the administrator.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Submitted by: ${userName.text}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Mobile: ${userMobile.text}",
                        style: const TextStyle(
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Documents uploaded:",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      ...uploadedDocuments.map(
                            (doc) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doc.fileName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Please wait for 3-5 working days until your account gets verified.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Thank you for choosing Sakhi Sampatti!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          step == 0
                              ? "Personal & Business Details"
                              : "Upload Documents",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (step == 0) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Personal Information",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: userName,
                                  decoration: InputDecoration(
                                    labelText: "Your Full Name",
                                    hintText:
                                    "Enter your full name",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    prefixIcon: const Icon(
                                        Icons.person_outline,
                                        color: Colors.blue),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: userMobile,
                                  keyboardType:
                                  TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Mobile Number",
                                    hintText:
                                    "10 digit mobile number",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    prefixIcon: const Icon(
                                        Icons.phone_outlined,
                                        color: Colors.blue),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Business Information",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: businessName,
                                  decoration: InputDecoration(
                                    labelText: "Business Name",
                                    hintText:
                                    "Enter your business name",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    prefixIcon: const Icon(
                                        Icons.store,
                                        color: Colors.blue),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: stockMarketId,
                                  keyboardType:
                                  TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText:
                                    "Stock Market ID (8 digits)",
                                    hintText: "Enter 8-digit ID",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    prefixIcon: const Icon(
                                        Icons.numbers,
                                        color: Colors.blue),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Business Type",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildCategoryOption(
                                        "Retail"),
                                    const SizedBox(width: 8),
                                    _buildCategoryOption(
                                        "Services"),
                                    const SizedBox(width: 8),
                                    _buildCategoryOption(
                                        "Technology"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (step == 1) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Required Documents",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...documents.keys.map((doc) {
                                  final docData =
                                  documents[doc]!;
                                  final uploaded =
                                  docData["uploaded"] as bool;
                                  final fileName =
                                  docData["fileName"]
                                  as String?;

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      border: Border.all(
                                        color: uploaded
                                            ? Colors.green
                                            : Colors
                                            .grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                            doc,
                                            style: const TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .w500),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                uploaded
                                                    ? "Uploaded"
                                                    : "Required",
                                                style: TextStyle(
                                                  color: uploaded
                                                      ? Colors
                                                      .green
                                                      : Colors
                                                      .orange,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (uploaded &&
                                                  fileName !=
                                                      null) ...[
                                                const SizedBox(
                                                    height: 4),
                                                Text(
                                                  fileName,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors
                                                        .grey[600],
                                                    fontStyle:
                                                    FontStyle
                                                        .italic,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(
                                              uploaded
                                                  ? Icons
                                                  .check_circle
                                                  : Icons
                                                  .upload_file,
                                              color: uploaded
                                                  ? Colors.green
                                                  : Colors.blue,
                                              size: 28,
                                            ),
                                            onPressed: () =>
                                                _pickFile(doc),
                                          ),
                                        ),
                                        if (uploaded)
                                          Padding(
                                            padding:
                                            const EdgeInsets
                                                .only(
                                                left: 16,
                                                right: 16,
                                                bottom: 8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton
                                                      .icon(
                                                    onPressed: () =>
                                                        _pickFile(
                                                            doc),
                                                    icon: const Icon(
                                                        Icons
                                                            .refresh,
                                                        size: 16),
                                                    label: const Text(
                                                        "Replace"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                      Colors.blue
                                                          .shade50,
                                                      foregroundColor:
                                                      Colors
                                                          .blue,
                                                      elevation: 0,
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            8),
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
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPricingSection(),
                          _buildTermsSection(),
                        ],
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: step == 0
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (userName.text
                                .trim()
                                .isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please enter your name"),
                                  backgroundColor:
                                  Colors.red,
                                ),
                              );
                              return;
                            }
                            if (userMobile.text
                                .trim()
                                .isEmpty ||
                                !_isValidMobile(userMobile
                                    .text
                                    .trim())) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please enter a valid 10-digit mobile number"),
                                  backgroundColor:
                                  Colors.red,
                                ),
                              );
                              return;
                            }
                            if (businessName.text
                                .trim()
                                .isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please enter business name"),
                                  backgroundColor:
                                  Colors.red,
                                ),
                              );
                              return;
                            }
                            if (!_isValidStockId(
                                stockMarketId.text
                                    .trim())) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please enter a valid 8-digit Stock Market ID"),
                                  backgroundColor:
                                  Colors.red,
                                ),
                              );
                              return;
                            }
                            setState(() => step = 1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.blueAccent,
                          ),
                          child: const Text("Next"),
                        ),
                      ],
                    )
                        : Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _termsAccepted
                              ? _submit
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            _termsAccepted
                                ? Colors.blueAccent
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                          child: const Text(
                              "Submit for Verification"),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(
                                  () => step = 0),
                          child:
                          const Text("← Back to Details"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CustomPaint(
              painter: _TrianglePainter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String type) {
    final isSelected = selectedCategory == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = type),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.blueAccent
                  : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.blueAccent
                    : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// TRIANGLE PAINTER
/// --------------------
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/* ------------------ EXPLORE PAGE ------------------ */
// ─── DATA MODELS ────────────────────────────────────────────────────────────

class LocalVideo {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String category;
  final String assetPath;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final String tag;

  const LocalVideo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.category,
    required this.assetPath,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    required this.tag,
  });
}

class YouTubeVideo {
  final String id;
  final String title;
  final String channel;
  final String views;
  final String duration;
  final String youtubeId;
  final String thumbnailUrl;
  final String category;

  const YouTubeVideo({
    required this.id,
    required this.title,
    required this.channel,
    required this.views,
    required this.duration,
    required this.youtubeId,
    required this.thumbnailUrl,
    required this.category,
  });
}

// ─── SAMPLE DATA ────────────────────────────────────────────────────────────

final List<LocalVideo> localVideos = [
  LocalVideo(
    id: '1',
    title: 'Sakhi Sampatti',
    subtitle: 'Manage & grow your personal wealth with smart tools',
    duration: '12:34',
    category: 'App Guide',
    assetPath: 'assets/videos/video1.mp4',
    gradientStart: const Color(0xFF6C3DE8),
    gradientEnd: const Color(0xFFB06AB3),
    icon: Icons.account_balance_wallet_rounded,
    tag: 'FEATURED',
  ),
  LocalVideo(
    id: '2',
    title: 'Stock Market Mastery',
    subtitle: 'Learn to invest in stocks and build long-term wealth',
    duration: '18:20',
    category: 'Stocks',
    assetPath: 'assets/videos/video2.mp4',
    gradientStart: const Color(0xFF0F2027),
    gradientEnd: const Color(0xFF00C9FF),
    icon: Icons.show_chart_rounded,
    tag: 'POPULAR',
  ),
  LocalVideo(
    id: '3',
    title: 'Govt Schemes & Loans',
    subtitle: 'Explore subsidies, loans & schemes for every Indian',
    duration: '21:45',
    category: 'Schemes',
    assetPath: 'assets/videos/video3.mp4',
    gradientStart: const Color(0xFF134E5E),
    gradientEnd: const Color(0xFF71B280),
    icon: Icons.account_balance_rounded,
    tag: 'MUST WATCH',
  ),
];

final List<YouTubeVideo> youtubeVideos = [
  YouTubeVideo(
    id: 'y1',
    title: 'How to Start Investing in 2024 — Complete Guide',
    channel: 'Pranjal Kamra',
    views: '2.4M views',
    duration: '24:11',
    youtubeId: 'gFQNPmLKj1k',
    thumbnailUrl: 'https://img.youtube.com/vi/gFQNPmLKj1k/maxresdefault.jpg',
    category: 'Investing',
  ),
  YouTubeVideo(
    id: 'y2',
    title: 'SIP vs Lump Sum — Which is Better?',
    channel: 'CA Rachana Ranade',
    views: '1.8M views',
    duration: '18:03',
    youtubeId: 'F3FkR0bPMcI',
    thumbnailUrl: 'https://img.youtube.com/vi/F3FkR0bPMcI/maxresdefault.jpg',
    category: 'Mutual Funds',
  ),
  YouTubeVideo(
    id: 'y3',
    title: 'Top 5 Government Schemes You Must Know',
    channel: 'Labour Law Advisor',
    views: '3.1M views',
    duration: '15:47',
    youtubeId: 'dQw4w9WgXcQ',
    thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    category: 'Schemes',
  ),
  YouTubeVideo(
    id: 'y4',
    title: 'Personal Finance Basics — Budget Like a Pro',
    channel: 'Ankur Warikoo',
    views: '5.2M views',
    duration: '31:22',
    youtubeId: '1OAlFKLQJQM',
    thumbnailUrl: 'https://img.youtube.com/vi/1OAlFKLQJQM/maxresdefault.jpg',
    category: 'Finance',
  ),
  YouTubeVideo(
    id: 'y5',
    title: 'Stock Market Basics for Beginners',
    channel: 'Groww',
    views: '4.0M views',
    duration: '22:55',
    youtubeId: 'p7HKvqRI_Bo',
    thumbnailUrl: 'https://img.youtube.com/vi/p7HKvqRI_Bo/maxresdefault.jpg',
    category: 'Stocks',
  ),
  YouTubeVideo(
    id: 'y6',
    title: 'How to Get a Business Loan in India',
    channel: 'Finance With Sharan',
    views: '980K views',
    duration: '19:10',
    youtubeId: 'ZbZSe6N_BXs',
    thumbnailUrl: 'https://img.youtube.com/vi/ZbZSe6N_BXs/maxresdefault.jpg',
    category: 'Loans',
  ),
];

// ─── THEME ───────────────────────────────────────────────────────────────────

class AppTheme {
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color card = Color(0xFF1A1A27);
  static const Color cardBorder = Color(0xFF2A2A3F);
  static const Color accent = Color(0xFF7C5CFC);
  static const Color accentGlow = Color(0x337C5CFC);
  static const Color gold = Color(0xFFFFD166);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color success = Color(0xFF06D6A0);
}

// ─── EXPLORE PAGE ────────────────────────────────────────────────────────────

/* ------------------ EXPLORE PAGE ------------------ */

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'App Guide',
    'Stocks',
    'Schemes',
    'Investing',
    'Mutual Funds',
    'Loans',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryChips(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLocalVideosTab(), _buildYouTubeTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Videos, guides & financial lessons',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 13),
                const SizedBox(width: 4),
                Text(
                  'Learning Hub',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CATEGORY CHIPS ───────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.blueAccent : Colors.grey.shade300,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── TAB BAR ──────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.blueAccent,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.blueAccent,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.play_circle_outline_rounded, size: 16),
                SizedBox(width: 6),
                Text('Our Videos'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.smart_display_rounded, size: 16),
                SizedBox(width: 6),
                Text('YouTube'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── LOCAL VIDEOS TAB ─────────────────────────────────────────────────────

  Widget _buildLocalVideosTab() {
    final filtered = _selectedCategory == 'All'
        ? localVideos
        : localVideos.where((v) => v.category == _selectedCategory).toList();

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          if (_selectedCategory == 'All') ...[
            _buildFeaturedHero(localVideos[0]),
            const SizedBox(height: 24),
            _buildSectionHeader('📚 All Lessons', '${localVideos.length} videos'),
            const SizedBox(height: 12),
            ...localVideos.skip(1).map((v) => _buildVideoCard(v)).toList(),
          ] else ...[
            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ...filtered.map((v) => _buildVideoCard(v)).toList(),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── FEATURED HERO CARD ───────────────────────────────────────────────────

  Widget _buildFeaturedHero(LocalVideo video) {
    return GestureDetector(
      onTap: () => _openLocalVideoPlayer(video),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [video.gradientStart, video.gradientEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: video.gradientStart.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                  ),
                ),
              ),
            ),
            // Icon
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Icon(video.icon, color: Colors.white, size: 32),
              ),
            ),
            // Tag
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  video.tag,
                  style: TextStyle(
                    color: video.gradientStart,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPlayButton(),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 13, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        video.duration,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.play_arrow_rounded, color: Colors.black, size: 16),
          SizedBox(width: 4),
          Text(
            'Play Now',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── VIDEO CARD ───────────────────────────────────────────────────────────

  Widget _buildVideoCard(LocalVideo video) {
    return GestureDetector(
      onTap: () => _openLocalVideoPlayer(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 110,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [video.gradientStart, video.gradientEnd],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(video.icon, color: Colors.white.withOpacity(0.4), size: 28),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        video.tag,
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      video.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.folder_outlined, size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          video.category,
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── YOUTUBE TAB ──────────────────────────────────────────────────────────

  Widget _buildYouTubeTab() {
    final filtered = _selectedCategory == 'All'
        ? youtubeVideos
        : youtubeVideos.where((v) => v.category == _selectedCategory).toList();

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildYTBanner(),
          const SizedBox(height: 20),
          _buildSectionHeader('🎬 Curated For You', '${youtubeVideos.length} videos'),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map((v) => _buildYTCard(v)).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildYTBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_display_rounded,
              color: Color(0xFFFF0000),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YouTube Finance Library',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hand-picked videos by top Indian finance creators',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYTCard(YouTubeVideo video) {
    return GestureDetector(
      onTap: () => _openYouTube(video.youtubeId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    video.thumbnailUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => _buildYTFallbackThumb(video),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                        ),
                      ),
                    ),
                  ),
                ),
                // Play button
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 60),
                    width: 52,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                  ),
                ),
                // Duration
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Category
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      video.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.person, size: 14, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        video.channel,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.visibility_outlined, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        video.views,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYTFallbackThumb(YouTubeVideo video) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_display_rounded, color: Colors.red.shade300, size: 48),
          const SizedBox(height: 8),
          Text(video.channel, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.video_library_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No videos in this category',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── ACTIONS ──────────────────────────────────────────────────────────────

  void _openLocalVideoPlayer(LocalVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
    );
  }

  Future<void> _openYouTube(String youtubeId) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$youtubeId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
      }
    }
  }
}

// ─── VIDEO PLAYER SCREEN ─────────────────────────────────────────────────────

class VideoPlayerScreen extends StatefulWidget {
  final LocalVideo video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.video.assetPath);
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        autoInitialize: true,
        aspectRatio: _videoController!.value.aspectRatio > 0
            ? _videoController!.value.aspectRatio
            : 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blueAccent,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.blueAccent.withOpacity(0.3),
        ),
        placeholder: Container(color: Colors.black),
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Text(
          widget.video.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Video player
          AspectRatio(
            aspectRatio: _videoController?.value.aspectRatio == null ||
                _videoController!.value.aspectRatio <= 0
                ? 16 / 9
                : _videoController!.value.aspectRatio,
            child: _isLoading
                ? Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            )
                : _hasError
                ? _buildErrorWidget()
                : ClipRect(
              child: Chewie(controller: _chewieController!),
            ),
          ),
          // Info below
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      widget.video.category,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.video.subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _infoChip(Icons.access_time, widget.video.duration),
                      const SizedBox(width: 10),
                      _infoChip(Icons.hd_outlined, 'HD Quality'),
                      const SizedBox(width: 10),
                      _infoChip(Icons.volume_up_outlined, 'Audio'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Could not load video',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure ${widget.video.assetPath} exists in assets',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── CUSTOM PAINTER ──────────────────────────────────────────────────────────

class _GridPatternPainter extends CustomPainter {
  final double opacity;
  _GridPatternPainter({this.opacity = 0.08});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 0.5;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* ------------------ GOVT PAGE ------------------ */

class GovtPage extends StatefulWidget {
  const GovtPage({super.key});

  @override
  State<GovtPage> createState() => _GovtPageState();
}

class _GovtPageState extends State<GovtPage> {
  final List<Map<String, String>> schemes = [
    {
      "title": "1) Pradhan Mantri Fasal Bima Yojana (PMFBY)",
      "description":
      "Description:\nCrop insurance scheme to protect farmers from losses due to drought, flood, pests, and natural disasters.\n\n"
          "Launched By & When:\nGovernment of India – February 2016\n\n"
          "Uses & Benefits:\n• Insurance cover for crop loss\n• Low premium\n• Financial protection\n• Quick claim settlement\n\n"
          "Eligibility:\n• All farmers (loanee & non-loanee)\n• Sharecroppers & tenant farmers\n\n"
          "How to Apply:\n1.Visit pmfby.gov.in\n2.Register farmer details\n3.Select crop & season\n4.Upload documents\n5.Pay premium\n\n"
          "Documents Required:\n• Aadhaar card\n• Bank passbook\n• Land records\n• Crop details\n\n"
          "Official link:\nhttps://www.pmfby.gov.in/"
    },
    {
      "title":
      "2) Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
      "description":
      "Description:\nIncome support scheme for farmers.\n\n"
          "Launched By & When:\nGovernment of India – February 2019\n\n"
          "Uses & Benefits:\n• ₹6,000 per year\n• Direct bank transfer\n• Helps farming expenses\n\n"
          "Eligibility:\n• Farmers owning land\n• Indian citizen\n\n"
          "How to Apply:\n1.Visit pmkisan.gov.in\n2.Register farmer details\n3.Submit Aadhaar & bank info\n4.Verification\n\n"
          "Documents Required:\n• Aadhaar\n• Bank details\n• Land ownership proof\n\n"
          "Official Link:\nhttps://pmkisan.gov.in/"
    },
    {
      "title": "3) Agriculture Infrastructure Fund (AIF)",
      "description":
      "Description:\nLoan support for building agri infrastructure.\n\n"
          "Launched By & When:\nGovernment of India – August 2020\n\n"
          "Uses & Benefits:\n• Loan for storage & processing\n• Interest subsidy\n• Credit guarantee\n\n"
          "Eligibility:\n• Farmers\n• FPOs\n• Agri startups\n\n"
          "How to Apply:\n1.Visit agriinfra.dac.gov.in\n2.Register project\n3.Apply for loan\n\n"
          "Documents Required:\n• Aadhaar\n• Project report\n• Bank details\n\n"
          "Official Link:\nhttps://agriinfra.dac.gov.in/"
    },
    {
      "title": "4) National Horticulture Mission (NHM)",
      "description":
      "Description:\nPromotes horticulture crops.\n\n"
          "Launched By & When:\nGovernment of India – 2005\n\n"
          "Uses & Benefits:\n• Subsidy on plants\n• Irrigation support\n• Storage facilities\n\n"
          "Eligibility:\n• Farmers\n• Growers\n\n"
          "How to Apply:\n1.Visit agri office\n2.Fill form\n3.Submit land proof\n\n"
          "Documents Required:\n• Aadhaar\n• Land documents\n\n"
          "Official Link:\nhttps://hortnet.gov.in/"
    },
    {
      "title": "5) Gramin Bhandaran Yojana",
      "description":
      "Description:\nSubsidy for building rural godowns.\n\n"
          "Launched By & When:\nGovernment of India – 2001\n\n"
          "Uses & Benefits:\n• Reduce crop wastage\n• Storage subsidy\n\n"
          "Eligibility:\n• Farmers\n• Entrepreneurs\n\n"
          "How to Apply:\n1.Apply via NABARD\n2.Submit project plan\n\n"
          "Documents Required:\n• Land records\n• Project report\n\n"
          "Official Link:\nhttps://dmi.gov.in/"
    },
    {
      "title": "6) Pradhan Mantri MUDRA Yojana",
      "description":
      "Description:\nLoans for micro businesses.\n\n"
          "Launched By & When:\nGovernment of India – April 2015\n\n"
          "Uses & Benefits:\n• Loans up to ₹10 lakh\n• No collateral\n\n"
          "Eligibility:\n• MSMEs\n• Entrepreneurs\n\n"
          "How to Apply:\n1.Visit bank\n2.Fill Mudra form\n3.Submit documents\n\n"
          "Documents Required:\n• Aadhaar\n• PAN\n• Business details\n\n"
          "Official Link:\nhttps://udyamimitra.in/"
    },
    {
      "title": "7) Stand-Up India",
      "description":
      "Description:\nLoan for women & SC/ST entrepreneurs.\n\n"
          "Launched By & When:\nGovernment of India – April 2016\n\n"
          "Uses & Benefits:\n• Loans ₹10 lakh – ₹1 crore\n• Business support\n\n"
          "Eligibility:\n• Women\n• SC/ST\n\n"
          "How to Apply:\n1.Visit standupmitra.in\n2.Register\nApply\n\n"
          "Documents Required:\n• Aadhaar\n• Business plan\n\n"
          "Official Link:\nhttps://www.standupmitra.in/"
    },
    {
      "title": "8) PMEGP",
      "description":
      "Description:\nSubsidy for micro enterprises.\n\n"
          "Launched By & When:\nGovernment of India – August 2008\n\n"
          "Uses & Benefits:\n• Loan + subsidy\n• Job creation\n\n"
          "Eligibility:\n• Indian citizen 18+\n\n"
          "How to Apply:\n1.Visit kviconline.gov.in\n2.Register\n3.Submit project\n\n"
          "Documents Required:\n• Aadhaar\n• Project report\n\n"
          "Official Link:\nhttps://www.kviconline.gov.in/"
    },
    {
      "title": "9) Startup India",
      "description": "Description:\nSupport for startups.\n\n"
          "Launched By & When:\nGovernment of India – January 2016\n\n"
          "Uses & Benefits:\n• Funding\n• Tax benefits\n• Mentorship\n\n"
          "Eligibility:\n• DPIIT startups\n\n"
          "How to Apply:\n1.Visit startupindia.gov.in\n2.Register\n\n"
          "Documents Required:\n• PAN\n• Registration\n\n"
          "Official Link:\nhttps://www.startupindia.gov.in/"
    },
    {
      "title": "10) CGTMSE",
      "description":
      "Description:\nLoan guarantee for MSMEs.\n\n"
          "Launched By & When:\nGovernment of India – August 2000\n\n"
          "Uses & Benefits:\n• No collateral loans\n\n"
          "Eligibility:\n• MSMEs\n\n"
          "How to Apply:\n1.Apply via bank\n2.Request CGTMSE\n\n"
          "Documents Required:\n• Udyam registration\n• Bank details\n\n"
          "Official Link:\nhttps://www.cgtmse.in/"
    },
    {
      "title": "11) Udyam Registration",
      "description":
      "Description:\nOfficial MSME registration.\n\n"
          "Launched By & When:\nGovernment of India – July 2020\n\n"
          "Uses & Benefits:\n• Access to schemes\n• Loans\n\n"
          "Eligibility:\n• MSMEs\n\n"
          "How to Apply:\n1.Visit udyamregistration.gov.in\n2.Register\n\n"
          "Documents Required:\n• Aadhaar\n• PAN\n\n"
          "Official Link:\nhttps://udyamregistration.gov.in/"
    },
    {
      "title": "12) Mahila Udyam Nidhi",
      "description":
      "Description:\nLoan for women entrepreneurs.\n\n"
          "Launched By & When:\nSIDBI – 1995\n\n"
          "Uses & Benefits:\n• Loan up to ₹10 lakh\n\n"
          "Eligibility:\n• Women entrepreneurs\n\n"
          "How to Apply:\nApply via bank\n\n"
          "Documents Required:\n• Aadhaar\n• Business plan"
    },
    {
      "title": "13) TREAD Scheme",
      "description":
      "Description:\nSupport for women entrepreneurs via NGOs.\n\n"
          "Launched By & When:\nGovernment of India – 1997\n\n"
          "Uses & Benefits:\n• Training\n• Grants\n\n"
          "Eligibility:\n• Women via NGOs\n\n"
          "How to Apply:\nThrough NGOs\n\n"
          "Documents Required:\n• Aadhaar"
    },
    {
      "title": "14) Annapurna Scheme",
      "description":
      "Description:\nLoan for women food businesses.\n\n"
          "Launched By & When:\nSBI – 2000\n\n"
          "Uses & Benefits:\n• Loan up to ₹50,000\n\n"
          "Eligibility:\n• Women entrepreneurs\n\n"
          "How to Apply:\nApply via bank\n\n"
          "Documents Required:\n• Aadhaar"
    },
    {
      "title": "15) Stree Shakti Yojana",
      "description":
      "Description:\nLower interest loans for women.\n\n"
          "Launched By & When:\nGovernment of India – 2003\n\n"
          "Uses & Benefits:\n• Interest subsidy\n\n"
          "Eligibility:\n• Women entrepreneurs\n\n"
          "How to Apply:\nBank application\n\n"
          "Documents Required:\n• Aadhaar"
    },
    {
      "title": "16) Mahila Coir Yojana",
      "description":
      "Description:\nSupport for women in coir industry.\n\n"
          "Launched By & When:\nGovernment of India – 2014\n\n"
          "Uses & Benefits:\n• Machinery subsidy\n\n"
          "Eligibility:\n• Women artisans\n\n"
          "How to Apply:\nCoir Board office\n\n"
          "Documents Required:\n• Aadhaar"
    },
    {
      "title": "17) Women Startup India",
      "description":
      "Description:\nSupport for women startups.\n\n"
          "Launched By & When:\nGovernment of India – 2016\n\n"
          "Uses & Benefits:\n• Mentorship\n• Funding\n\n"
          "Eligibility:\n• Women startups\n\n"
          "How to Apply:\nStartup India portal\n\n"
          "Documents Required:\n• PAN"
    },
    {
      "title": "18) MIDH",
      "description":
      "Description:\nSubsidy for horticulture.\n\n"
          "Launched By & When:\nGovernment of India – 2014\n\n"
          "Uses & Benefits:\n• Tool subsidy\n\n"
          "Eligibility:\n• Farmers\n\n"
          "How to Apply:\nAgriculture office\n\n"
          "Documents Required:\n• Aadhaar"
    },
    {
      "title": "19) ACABC",
      "description":
      "Description:\nTraining for agri graduates.\n\n"
          "Launched By & When:\nGovernment of India – 2002\n\n"
          "Uses & Benefits:\n• Business training\n\n"
          "Eligibility:\n• Agri graduates\n\n"
          "How to Apply:\nApply online\n\n"
          "Documents Required:\n• Degree certificate"
    },
    {
      "title": "20) PMRY",
      "description":
      "Description:\nLoan subsidy for unemployed youth.\n\n"
          "Launched By & When:\nGovernment of India – 1993\n\n"
          "Uses & Benefits:\n• Loan subsidy\n\n"
          "Eligibility:\n• Unemployed youth\n\n"
          "How to Apply:\nEmployment office\n\n"
          "Documents Required:\n• Aadhaar"
    },
  ];

  late List<bool> expanded;

  @override
  void initState() {
    super.initState();
    expanded = List<bool>.filled(schemes.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Government Schemes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              "assets/govt.jpeg",
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                final isExpanded = expanded[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          scheme["title"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                          onPressed: () {
                            setState(() {
                              expanded[index] = !expanded[index];
                            });
                          },
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.black,
                                ),
                                children: _buildTextSpans(
                                    scheme["description"]!),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String text) {
    final RegExp urlRegExp =
    RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);

    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in urlRegExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(
            TextSpan(text: text.substring(start, match.start)));
      }

      final String url = match.group(0)!;
      final Uri uri = Uri.parse(url);

      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
