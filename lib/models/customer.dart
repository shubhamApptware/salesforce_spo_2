import 'package:salesforce_spo/models/app_user.dart';

class Customer extends AppUser {
  @override
  String id;

  @override
  String? email;

  @override
  late String firstName;

  @override
  late String lastName;

  @override
  String? phone;

  final String? name;
  final String? lastTransactionDate;
  final double? lifeTimeNetSalesAmount;
  final String? primaryInstrument;
  final double? lifetimeNetTransactions;
  final String? maxLTVNet;
  final String? medianLTVNet;
  final String? averageLTVNet;
  final double? lastPurchaseValue;

  Customer._({
    this.email,
    this.name,
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.lastTransactionDate,
    this.lifeTimeNetSalesAmount,
    this.primaryInstrument,
    this.lifetimeNetTransactions,
    this.maxLTVNet,
    this.medianLTVNet,
    this.averageLTVNet,
    this.lastPurchaseValue,
  });

  factory Customer.fromJson({required Map<String, dynamic> json}) {
    return Customer._(
      id: json['Id'],
      name: json['Name'],
      firstName: json['FirstName'] ?? '--',
      lastName: json['LastName'] ?? '--',
      email: json['accountEmail__c'],
      phone: json['accountPhone__c'],
      lastTransactionDate: json['Last_Transaction_Date__c'],
      lifeTimeNetSalesAmount: json['Lifetime_Net_Sales_Amount__c'],
      primaryInstrument: json['Primary_Instrument_Category__c'],
      lifetimeNetTransactions: json['Lifetime_Net_Sales_Transactions__c'],
      maxLTVNet: json['Max_ltv_net_dlrs_Formula__c'],
      medianLTVNet: json['Median_ltv_net_dlrs_Formula__c'],
      averageLTVNet: json['Avg_ltv_net_dlrs_Formula__c'],
      lastPurchaseValue: json['GC_Orders__r']?['records']?[0]?['Total_Amount__c']
    );
  }
}
