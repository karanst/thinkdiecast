//////******* Do not make any change in this file **********/////////

class NetworkConstantsUtil {
  static String baseUrl =
      // 'http://192.168.45.150:3000/v1';
      'https://stageapi.fincooper.in/v1/';

  // *************** Login and profile *************//
  static String loginUrl = 'login/employe';
  static String attendanceCheckUrl = 'adminMaster/employe/attendance';
  static String employeePunchUrl = 'adminMaster/employe/punch';
  static String ownerDataUrl = '/owner/';

  static String shopsListUrl = '/shop';
  static String petCategoryUrl = '/pet-category/all';
  static String servicesCategoryUrl = '/admin/service';
  static String addShopUrl = '/shop/add';

  static String shopCategoryUrl = '/inventory/category/';
  static String addProductUrl = '/inventory/product/';
  static String categoryProductsUrl = '/inventory/product/';

  static String shopOrdersUrls = '/order/shop/';
}
