// import 'package:emp_management_system/modal_class.dart/login_modal.dart';
import 'package:api_call_for_login_screen/dashboard.dart';
import 'package:api_call_for_login_screen/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


// import '../../main.dart';
// import '../common_classes/employee_card.dart';

class admin_dashboard extends StatefulWidget {
  const admin_dashboard({super.key, required  this.data});
  final Data data ;

  @override
  State<admin_dashboard> createState() => _admin_dashboardState();
}

class _admin_dashboardState extends State<admin_dashboard> {
  final usernamecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 141, 151, 156),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          textAlign: TextAlign.center,
          'EMP MGT SYSTEM',
        ),
      ),
      body: Padding(
      
        padding: const EdgeInsets.only(top: 4.0, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card.outlined(
              color: const Color.fromARGB(255, 61, 52, 70),
              shadowColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: 40,
                width: 120,
                child: const Center(
                  child: Text(
                    'DASHBOARD',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
           EmployeeCard(
              avatarUrl: widget.data.img ?? '',
              employeeName: widget.data.userid??'',
              designation: widget.data.deg??'',
              employeeID: widget.data.eid??'',
              type: widget.data.type??'',
              dateofJoining: widget.data.doj?? '',
              salary: widget.data.salary?? '',
            ),
          ],
        ),
      ),
    );
  }
}