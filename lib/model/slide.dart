class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
      imageUrl: 'assets/images/DashBoard_Pic2.jpg',
      title: 'A Cool Way to Manage Bills',
      description:
          'Business Transction Receipts, Supplier Invoices, Customer Bills, Credit and Cash details could be stored in his Google Accounts. DashBoard shows entire business data. Purchases and Sales transaction details can be displayed by the filter based on daily or date range. Sales Price List, Purchase Orders List and Sales Orders List.'),
  Slide(
      imageUrl: 'assets/images/DashBoard_Pic3.jpg',
      title: 'Customers Dashboard',
      description:
          'Customers Transction Bills could be Managed. Suppliers Credit and Cash GUI Dashboard. Suppliers Photos, Contacts and Its Transaction Invoices could be Manged. Display the details with Filter based on the Name, Type and Daterange.'),
  Slide(
      imageUrl: 'assets/images/DashBoard_Pic1.jpg',
      title: 'Suppliers Dashboard',
      description:
          'Suppliers Transction Bills could be Managed. Suppliers Credit and Cash GUI Dashboard. Suppliers Photos, Contacts and Its Transaction Invoices could be Manged. Display the details with Filter based on the Name, Type and Daterange.'),
];
