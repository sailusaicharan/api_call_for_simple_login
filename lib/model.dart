class loginmodel {
  int? status;
  List<String>? error;
  List<Data>? data;

  loginmodel({this.status, this.error, this.data});

  loginmodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'].cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? eid;
  String? userid;
  String? img;
  String? type;
  String? doj;
  String? deg;
  String? salary;
  String? url;

  Data(
      {this.eid,
      this.userid,
      this.img,
      this.type,
      this.doj,
      this.deg,
      this.salary,
      this.url});

  Data.fromJson(Map<String, dynamic> json) {
    eid = json['eid'];
    userid = json['userid'];
    img = json['img'];
    type = json['type'];
    doj = json['doj'];
    deg = json['deg'];
    salary = json['salary'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eid'] = this.eid;
    data['userid'] = this.userid;
    data['img'] = this.img;
    data['type'] = this.type;
    data['doj'] = this.doj;
    data['deg'] = this.deg;
    data['salary'] = this.salary;
    data['url'] = this.url;
    return data;
  }
}