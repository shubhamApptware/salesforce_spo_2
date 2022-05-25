import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common_widgets/customer_details_card.dart';
import '../../design_system/design_system.dart';
import '../../models/customer.dart';
import '../../services/networking/endpoints.dart';
import '../../services/networking/networking_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String name = '';

  int offset = 0;
  bool isLoadingData = false;

  ScrollController scrollController = ScrollController();

  List<Customer> customers = [];

  Future<void>? futureCustomers;

  Future<void> getCustomer(int offset) async {
    isLoadingData = true;
    if (offset == 0) {
      customers.clear();
    }

    var data = await HttpService().doGet(
      path: Endpoints.getCustomerSearchByName(name, offset),
      tokenRequired: true,
    );
    isLoadingData = false;
    try {
      for (var record in data.data['records']) {
        customers.add(Customer.fromJson(json: record));
      }
    } catch (error) {
      print(error);
    }
  }

  double aovCalculator(double? ltv, double? lnt) {
    if (ltv != null && lnt != null) {
      return ltv / lnt;
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: SizeSystem.size20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: Navigator.of(context).pop,
                  child: SvgPicture.asset(
                    IconSystem.back,
                    width: 20,
                    height: 20,
                  ),
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                const SizedBox(
                  width: SizeSystem.size20,
                ),
                Expanded(
                  child: TextFormField(
                    onChanged: (name) {
                      offset = 0;
                      this.name = name;
                      EasyDebounce.cancelAll();
                      if (this.name.length >= 3) {
                        EasyDebounce.debounce(
                            'search_name_debounce',
                            Duration(seconds: 1),
                            () {
                          setState(() {
                            futureCustomers = getCustomer(offset);
                          });
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search Name',
                      hintStyle: TextStyle(
                        color: ColorSystem.secondary,
                        fontSize: SizeSystem.size18,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorSystem.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: futureCustomers,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                  case ConnectionState.none:
                  case ConnectionState.done:
                  if (isLoadingData && customers.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorSystem.primary,
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CustomerDetailsCard(
                        customerId: customers[index].id,
                        name: customers[index].name ?? '--',
                        email: customers[index].email,
                        phone: customers[index].phone,
                        preferredInstrument:
                        customers[index].primaryInstrument,
                        lastTransactionDate:
                        customers[index].lastTransactionDate,
                        ltv: customers[index].lifeTimeNetSalesAmount ?? 0,
                        averageProductValue: aovCalculator(
                            customers[index]
                                .lifeTimeNetSalesAmount,
                            customers[index]
                                .lifetimeNetTransactions),
                        customerLevel: customers[index].medianLTVNet,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void scrollListener() {
    var maxExtent = scrollController.position.maxScrollExtent;
    var loadingPosition = maxExtent - (maxExtent * 0.4);
    if (scrollController.position.extentAfter < loadingPosition &&
        !isLoadingData) {
      offset = offset + 10;
      setState(() {
        futureCustomers = getCustomer(offset);
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }
}
