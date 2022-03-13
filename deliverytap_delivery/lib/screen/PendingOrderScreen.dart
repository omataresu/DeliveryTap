import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:deliverytap_delivery/components/PendingOrderItemWidget.dart';
import 'package:deliverytap_delivery/model/OrderModel.dart';
import 'package:deliverytap_delivery/utils/Colors.dart';
import 'package:deliverytap_delivery/utils/Common.dart';
import 'package:deliverytap_delivery/utils/Constants.dart';
import 'package:deliverytap_delivery/utils/ModelKey.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class PendingOrderScreen extends StatefulWidget {
  static String tag = '/OrderScreen';

  @override
  PendingOrderScreenState createState() => PendingOrderScreenState();
}

class PendingOrderScreenState extends State<PendingOrderScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : white,
      statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
      delayInMilliSeconds: 100,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget('New Orders', showBack: false),
        body: getBoolAsync(AVAILABLE, defaultValue: true)
            ? Stack(
          children: [
            StreamBuilder<List<OrderModel>>(
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Icon(Icons.add_shopping_cart),
                        16.height,
                        Text('You do not have any pending order.', style: boldTextStyle()),
                      ],

                    ).center();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      OrderModel orderData = snapshot.data![index];

                      return PendingOrderItemWidget(
                        orderData: snapshot.data![index],
                      );
                    },
                  );
                } else {
                  return snapWidgetHelper(snapshot);
                }
              },
            ),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        )
            : Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block).center(),
                  32.height,
                  Text('You are currently offline', style: primaryTextStyle(), textAlign: TextAlign.center),
                  16.height,
                  AppButton(
                    text: 'Set to Available',
                    textStyle: boldTextStyle(),
                    onTap: () async {
                      showConfirmDialog(context, 'Are you sure want to go online?',positiveText: 'Yes',negativeText: 'No').then((value) async {
                        if (value ?? false) {
                          appStore.setLoading(true);
                          await userService.updateDocument(getStringAsync(USER_ID), {UserKey.availabilityStatus: true}).then((value) async {
                            await setValue(AVAILABLE, true);
                            setState(() {});
                          }).catchError((error) {
                            toast(error.toString());
                          });
                        }
                        appStore.setLoading(false);
                      });
                    },
                  ).center(),
                ],
              ),
            ),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ).center(),
      ),
    );
  }
}
