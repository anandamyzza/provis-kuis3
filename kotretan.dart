import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

int selectedId = 1; // Menyimpan ID yang dipilih

class JenisPinjaman {
  String id;
  String pinjaman;
  JenisPinjaman({required this.id, required this.pinjaman});
}

class DetailPinjaman {
  String id_detail;
  String nama;
  String bunga;
  String is_syariah;

  DetailPinjaman(
      {required this.id_detail,
      required this.nama,
      required this.bunga,
      required this.is_syariah});
}

class DetailCubit extends Cubit<DetailPinjaman> {
  String url = "http://127.0.0.1:8000/detil_jenis_pinjaman/";

  DetailCubit()
      : super(
            DetailPinjaman(id_detail: "", nama: "", bunga: "", is_syariah: ""));

  void setFromJson(Map<String, dynamic> json) {
    String id_detail = json['id'];
    String nama = json['nama'];
    String bunga = json['bunga'];
    String is_syariah = json['is_syariah'];

    //emit state baru
    emit(DetailPinjaman(
        id_detail: id_detail,
        nama: nama,
        bunga: bunga,
        is_syariah: is_syariah));
  }

  void fetchData(String id) async {
    String dynamicUrl = "http://178.128.17.76:8000/detil_jenis_pinjaman/$id";
    final response = await http.get(Uri.parse(dynamicUrl));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class Pinjaman {
  List<JenisPinjaman> ListPop = <JenisPinjaman>[];

  Pinjaman({required this.ListPop});

  Pinjaman.fromJson(Map<String, dynamic> json) {
    var data = json["data"];
    for (var val in data) {
      var id = val["id"];
      var pinjaman = val["nama"];
      ListPop.add(JenisPinjaman(id: id, pinjaman: pinjaman));
    }
  }
}

class PinjamanCubit extends Cubit<Pinjaman> {
  PinjamanCubit() : super(Pinjaman(ListPop: []));

  Future<void> fetchData(int selectedId) async {
    String dynamicUrl = "http://178.128.17.76:8000/jenis_pinjaman/$selectedId";
    final response = await http.get(Uri.parse(dynamicUrl));

    if (response.statusCode == 200) {
      var pinjaman = Pinjaman.fromJson(jsonDecode(response.body));
      emit(pinjaman);
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My App P2P',
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PinjamanCubit>(
              create: (BuildContext context) => PinjamanCubit()..fetchData(1),
            ),
            BlocProvider<DetailCubit>(
              create: (BuildContext context) => DetailCubit(),
            ),
          ],
          child: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  // int selectedId = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My App P2P'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "2100702, Ananda Myzza Marhelio; 2103842, Dicki Fathurohman; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang",
              ),
            ),
            BlocBuilder<PinjamanCubit, Pinjaman>(
              builder: (context, state) {
                return DropdownButton<int>(
                  value: selectedId,
                  items: [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('Jenis Pinjaman 1'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('Jenis Pinjaman 2'),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text('Jenis Pinjaman 3'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedId = value!;
                    BlocProvider.of<PinjamanCubit>(context).fetchData(value);
                  },
                );
              },
            ),
            Expanded(
              child: BlocBuilder<PinjamanCubit, Pinjaman>(
                builder: (context, state) {
                  if (state.ListPop.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      itemCount: state.ListPop.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return Detil(
                                    id_detail:
                                        state.ListPop[index].id.toString());
                              }));
                            },
                            leading: Image.network(
                              'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                            ),
                            trailing: const Icon(Icons.more_vert),
                            title: Text(state.ListPop[index].pinjaman),
                            subtitle: Text("ID: " + state.ListPop[index].id),
                            tileColor: Colors.white70,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Detil extends StatelessWidget {
  const Detil({Key? key, required this.id_detail}) : super(key: key);
  final String id_detail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Detil'),
        ),
        body: Center(
          child: BlocBuilder<DetailCubit, DetailPinjaman>(
            builder: (context, state) {
              context.read<DetailCubit>().fetchData(id_detail);
              return Center(
                child: Column(children: [
                  Text("ID: " + state.id_detail),
                  Text("Nama: " + state.nama),
                  Text("Bunga: " + state.bunga),
                  Text("Syariah: " + state.is_syariah),
                ]),
              );
              // return Column(
              //   children: [
              //     Text("ID: ${state.id_detail}"),
              //     Text("Nama: ${state.nama}"),
              //     Text("Bunga: ${state.bunga}"),
              //     Text("Syariah: ${state.is_syariah}"),
              //   ],
              // );
            },
          ),
        ));
  }
}
