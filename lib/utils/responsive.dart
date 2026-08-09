/// Uses one column below 600 px for phones, two below 1024 px for tablets,
/// and three columns for wide screens.
int listingColumns(double width) => width < 600 ? 1 : (width < 1024 ? 2 : 3);
