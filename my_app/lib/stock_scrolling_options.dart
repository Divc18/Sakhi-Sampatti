import 'package:flutter/material.dart';

class Stock {
  final String company;
  final int price;
  final int highestPrice;
  final int lowestPrice;

  Stock({
    required this.company,
    required this.price,
    required this.highestPrice,
    required this.lowestPrice,
  });
}

// ----------------- TabBar Example -----------------
class TabBarExample extends StatefulWidget {
  const TabBarExample({super.key});

  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<List<dynamic>> rawStockData = [
    ["Reliance", 2500, 2700, 2300],
    ["TCS", 3200, 3400, 3000],
    ["Infosys", 1500, 1650, 1400],
    ["HDFC Bank", 1600, 1750, 1500],
    ["ICICI Bank", 950, 1050, 900],
    ["Kotak Bank", 1850, 2000, 1700],
    ["Axis Bank", 880, 950, 820],
    ["SBI", 600, 670, 550],
    ["Wipro", 420, 460, 400],
    ["HCL Tech", 1200, 1300, 1100],
    ["Tech Mahindra", 1050, 1150, 980],
    ["Adani Enterprises", 2200, 2450, 2000],
    ["Adani Ports", 950, 1050, 880],
    ["Bharti Airtel", 780, 850, 730],
    ["Maruti Suzuki", 9800, 10200, 9200],
    ["Mahindra & Mahindra", 1600, 1750, 1500],
    ["Tata Motors", 620, 700, 580],
    ["Bajaj Auto", 4200, 4500, 3900],
    ["Hero MotoCorp", 3200, 3450, 3000],
    ["Eicher Motors", 3800, 4100, 3500],
  ];

  late final List<Stock> exploreData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    exploreData = rawStockData
        .map((e) => Stock(
      company: e[0],
      price: e[1],
      highestPrice: e[2],
      lowestPrice: e[3],
    ))
        .toList();
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
      appBar: AppBar(
        title: const Text("Mentorship Sessions"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ExploreTab(data: exploreData),
          const HoldingTab(),
          const OrderTab(),
        ],
      ),
    );
  }
}

// ----------------- Explore Tab -----------------
class ExploreTab extends StatefulWidget {
  final List<Stock> data;

  const ExploreTab({super.key, required this.data});

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

  String formatIndianNumber(int number) {
    String numStr = number.toString();
    if (numStr.length <= 3) return numStr;

    String lastThree = numStr.substring(numStr.length - 3);
    String otherNumbers = numStr.substring(0, numStr.length - 3);
    String result = '';

    while (otherNumbers.length > 2) {
      result = ',' + otherNumbers.substring(otherNumbers.length - 2) + result;
      otherNumbers = otherNumbers.substring(0, otherNumbers.length - 2);
    }

    if (otherNumbers.isNotEmpty) {
      result = otherNumbers + result;
    }

    return result + ',' + lastThree;
  }

  String _getPrice(Stock stock) {
    int value;
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
    return '₹' + formatIndianNumber(value);
  }

  double _getPercentage(Stock stock) {
    if (_priceMode == 0) {
      double perc =
          ((stock.price - stock.lowestPrice) / (stock.highestPrice)) * 100;
      return perc;
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      _headerText, // Full text shown in rightmost
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13
                          ,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Data Rows
        Expanded(
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
              final percColor = perc >= 0 ? Colors.green : Colors.red;

              return Container(
                color: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(stock.company,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black))),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_getPrice(stock),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 16)),
                            if (_priceMode == 0)
                              Text(
                                percText,
                                style:
                                TextStyle(fontSize: 12, color: percColor),
                                textAlign: TextAlign.right,
                              )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(stock.company),
                            content: const Text("More options here..."),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"))
                            ],
                          ),
                        );
                      },
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              );
            },
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
    return const Center(
      child: Text("Here you will show all scheduled 1:1 sessions."),
    );
  }
}

// ----------------- Order Tab -----------------
class OrderTab extends StatelessWidget {
  const OrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Here you will show live sessions."),
    );
  }
}
