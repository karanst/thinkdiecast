import 'package:flutter/material.dart';
import 'package:thinkdiecast/utils/colors.dart';
import 'package:thinkdiecast/views/membership_screen.dart';
import 'package:thinkdiecast/views/search_list_screen.dart';

class SearchDialogWidget extends StatefulWidget {
  const SearchDialogWidget({Key? key}) : super(key: key);

  @override
  State<SearchDialogWidget> createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends State<SearchDialogWidget> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setStat) {
      return Dialog(
        backgroundColor: Colors.transparent,
        // backgroundColor: AppColors.black.withOpacity(0.7),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Text(
                      'Search titles, category, colour, scale..',
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 6, bottom: 30, left: 15, right: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10)),
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                                // onChanged: (value) {
                                //   if (value.length == 10) {
                                //     // controller.loginUser();
                                //   } else {}
                                // },
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Please enter valid email';
                                  }
                                  return null;
                                },
                                // maxLength: 10,
                                keyboardType: TextInputType.name,
                                controller: searchController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 10),
                                  // counterText: '',
                                  // hintText: "Email",
                                  // hintStyle: hintTextStyle(14, FontWeight.w500),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchListScreen(
                                          searchKeyword:
                                              searchController.text)));
                            },
                            child: Container(
                              width: 60,
                              decoration: const BoxDecoration(
                                  color: AppColors.bright,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              child: const Center(
                                child: Icon(
                                  Icons.search,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 48.0),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.dark.withOpacity(0.7)),
                        child: const ImageIcon(
                          AssetImage('assets/icons/search.png'),
                          color: Colors.white,
                        )),
                  ) // Replace with your image asset
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.33)),
                    child: const Icon(Icons.close, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    });
  }
}
