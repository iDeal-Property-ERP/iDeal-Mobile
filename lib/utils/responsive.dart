/// Uses two columns below 600 px for mobile phones, three below 1024 px for
/// tablets, and four columns for wide screens.
int listingColumns(double width) => width < 600 ? 2 : (width < 1024 ? 3 : 4);
