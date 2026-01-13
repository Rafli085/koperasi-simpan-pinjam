class LoanCalculator {
  // Calculate total amount to be paid including interest
  static Map<String, double> calculateLoanDetails({
    required double principal,
    required int tenor,
    required String productType,
  }) {
    double interestRate;
    double totalInterest;
    double totalAmount;
    double monthlyPayment;

    // Check if product contains "flexi" (case insensitive)
    if (productType.toLowerCase().contains('flexi')) {
      // 5% per month for Pinjaman Flexi
      interestRate = 0.05;
      totalInterest = principal * interestRate * tenor;
      totalAmount = principal + totalInterest;
      monthlyPayment = totalAmount / tenor;
    } else {
      // 12% per year for Pinjaman Tunai and Beli HP
      interestRate = 0.12;
      totalInterest = principal * interestRate * (tenor / 12);
      totalAmount = principal + totalInterest;
      monthlyPayment = totalAmount / tenor;
    }

    return {
      'principal': principal,
      'interest': totalInterest,
      'total': totalAmount,
      'monthlyPayment': monthlyPayment,
      'interestRate': interestRate,
    };
  }

  // Get interest rate display text
  static String getInterestRateText(String productType) {
    if (productType.toLowerCase().contains('flexi')) {
      return '5% per bulan';
    } else {
      return '12% per tahun';
    }
  }
}