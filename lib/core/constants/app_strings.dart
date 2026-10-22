/// Centralised text constants used across the app.
/// Helps avoid hard-coded strings scattered in the UI and
/// makes the app easy to translate/edit later.
class AppStrings {
  AppStrings._();

  static const String appName = 'AgroMarket';
  static const String appTagline = 'Real-Time Agricultural Market Prices';

  // Onboarding
  static const String onboardTitle1 = 'Know Today\'s Market Price';
  static const String onboardBody1 =
      'Get up-to-date prices of farm produce across markets in Nigeria.';

  static const String onboardTitle2 = 'Compare Across States';
  static const String onboardBody2 =
      'Search and filter commodities by state, market, or category.';

  static const String onboardTitle3 = 'Save Your Favourites';
  static const String onboardBody3 =
      'Bookmark commodities you track often and access them offline.';

  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String next = 'Next';

  // Home
  static const String homeTitle = 'AgroMarket';
  static const String categories = 'Categories';
  static const String latestPrices = 'Latest Prices';
  static const String seeAll = 'See All';

  // Categories
  static const String grains = 'Grains';
  static const String tubers = 'Tubers';
  static const String vegetables = 'Vegetables';
  static const String legumes = 'Legumes';
  static const String livestock = 'Livestock';

  // Search & Filter
  static const String searchHint = 'Search commodity e.g. Rice, Yam...';
  static const String filter = 'Filter';
  static const String state = 'State';
  static const String market = 'Market';
  static const String category = 'Category';
  static const String applyFilter = 'Apply Filter';
  static const String clearFilter = 'Clear Filter';

  // Details
  static const String priceTrend = 'Price Trend';
  static const String availableMarkets = 'Available Markets';
  static const String lastUpdated = 'Last Updated';
  static const String description = 'Description';
  static const String currentPrice = 'Current Price';
  static const String previousPrice = 'Previous Price';

  // Price comparison across states
  static const String comparePrices = 'Compare Prices';
  static const String compareAcrossStates = 'Compare Across States';
  static const String compareHint =
      'Find the cheapest state for any commodity';
  static const String bestPrice = 'Best Price';
  static const String sellMode = 'Selling';
  static const String buyMode = 'Buying';
  static const String sellModeHint =
      'Best price = highest price a farmer can get';
  static const String buyModeHint = 'Best price = lowest price a buyer can pay';
  static const String priceByState = 'Price by State';
  static const String chartNote =
      'Bar heights are zoomed in to make the price gap easier to see.';
  static const String stateRanking = 'State Ranking';
  static const String onlyOneState =
      'Only one state has a recorded price for this commodity so far.';
  static const String comparisonNote =
      'Prices are indicative and collected from each state\'s major market. '
      'Transport costs should be considered before travelling to buy.';

  // Favourites
  static const String favourites = 'Favourites';
  static const String noFavourites = 'You have no favourite commodities yet.';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String dontHaveAccount = "Don't have an account? Register";
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String logout = 'Logout';
  static const String loggedInAs = 'Logged in as';
  static const String addMarketPrice = 'Add Market Price';
  static const String editMarketPrice = 'Edit Market Price';
  static const String manageMarketPrices = 'Manage Market Prices';
  static const String delete = 'Delete';
  static const String adminTools = 'Admin Tools';

  // Settings
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String aboutApp = 'About App';
  static const String aboutProject = 'About Project';
  static const String contactDeveloper = 'Contact Developer';

  // Empty / Errors
  static const String noResultsFound = 'No results found';
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternet = 'No internet connection';
}