// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class GestionMenu extends StatefulWidget {
  const GestionMenu({super.key});
  @override
  State<GestionMenu> createState() => _GestionMenuState();
}

class _GestionMenuState extends State<GestionMenu>{
  final supabase = Supabase.instance.client;
  final TextEditingController platilloController = TextEditingController();
  List<Map<String, dynamic>> platillos = [];
  List<Map<String, dynamic>> principios = [];
  List<Map<String, dynamic>> complementos = [];

  @override
  void initState() {
    super.initState();
    cargarPlatillos();
  }

  Future<void> cargarPlatillos() async {
    final dataPlatos = await supabase
                  .from('Platillo')
                  .select()
                  .eq('categoria_alimenticia', 'Seco');

    final dataPrinc = await supabase
                  .from('Platillo')
                  .select()
                  .or('categoria_alimenticia.eq.Principio, categoria_alimenticia.eq.Complemento');

    final dataComp = await supabase
                  .from('Platillo')
                  .select()
                  .or('categoria_alimenticia.eq.Bebida, categoria_alimenticia.eq.Sopa');
    
    setState(() {
      platillos = dataPlatos;
      principios = dataPrinc;
      complementos = dataComp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: EsquemaDeColores.backgroundSecondary,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0), // Eliminar espacio adicional
            child: Container(
              color: EsquemaDeColores.backgroundSecondary,
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.rice_bowl)),
                  Tab(icon: Icon(Icons.local_dining)),
                  Tab(icon: Icon(Icons.local_drink)),
                ],
              ),
            ),
          ),
        ),
      body: TabBarView(
          children: [
            _buildTabContent(principios, 'principios'),
            _buildTabContent(platillos, 'seco'),
            _buildTabContent(complementos, 'bebidas')
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> platos, String filtro) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 15.0, top: 10),
          child: 
          Row(
            children: [
              Expanded(child: 
                TextField(
                    controller: platilloController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.abc),
                      hintText: "Buscar Platillo",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 3),
                    ),
                    onChanged: (value) {},
                  ),
              ),
              Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ElevatedButton(
                onPressed: () async {
                  final String nombre = platilloController.text.trim();
                  if (nombre == '') {
                    showCustomErrorDialog(context, '¡Digite una palabra clave en el buscador!');
                    cargarPlatillos();
                    return;
                  }
                  List<Map<String, dynamic>> platillosFiltrados;
                   switch (filtro) {
                     case 'principios':
                        platillosFiltrados = await supabase
                          .from('Platillo')
                          .select()
                          .or('categoria_alimenticia.eq.Principio, categoria_alimenticia.eq.Complemento')
                          .ilike('nombre', '%$nombre%');
                        
                        if(platillosFiltrados.isEmpty){
                          showCustomErrorDialog(context, "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                          cargarPlatillos();
                          platilloController.clear();
                          return;
                        }

                        setState(() {
                           principios = platillosFiltrados;
                        });
                        break;

                      case 'seco':
                        platillosFiltrados = await supabase
                          .from('Platillo')
                          .select()
                          .eq('categoria_alimenticia', 'Seco')
                          .ilike('nombre', '%$nombre%');
                        
                        if(platillosFiltrados.isEmpty){
                          showCustomErrorDialog(context, "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                          cargarPlatillos();
                          platilloController.clear();
                          return;
                        }

                        setState(() {
                           platillos = platillosFiltrados; 
                        });
                        break; 

                     case 'bebidas':
                        platillosFiltrados = await supabase
                          .from('Platillo')
                          .select()
                          .or('categoria_alimenticia.eq.Bebida, categoria_alimenticia.eq.Sopa')
                          .ilike('nombre', '%$nombre%');
                        
                        if(platillosFiltrados.isEmpty){
                          showCustomErrorDialog(context, "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                          cargarPlatillos();
                          platilloController.clear();
                          return;
                        }

                        setState(() {
                           complementos = platillosFiltrados; // Actualizar la lista de platillos
                        });  
                        break; 
                     default:
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: EsquemaDeColores.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.search, color: Colors.black),
              ),
            ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    crearPlatillo();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildPlatillosList(platos),
        ),
      ],
    );
  }

  Widget _buildPlatillosList(List<Map<String, dynamic>> platillos) {
    return ListView.builder(
      itemCount: platillos.length,
      itemBuilder: (context, index) {
        final platillo = platillos[index];
        return buildPlatilloCard(platillo); // Construye la tarjeta de cada platillo
      },
    );
  }

  Card buildPlatilloCard(Map<String, dynamic> platillo) {
    final idPlatillo = platillo['id'];
    final path = 'IDPlatillo/$idPlatillo/imagenPlatillo';
    String imageRoute = supabase.storage.from('platillos').getPublicUrl(path); 
    imageRoute = Uri.parse(imageRoute).replace(queryParameters: {
      't': DateTime.now().millisecond.toString()
      }).toString();
    //print(imageRoute);
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Row(
        children: [
          Padding(
            padding:const EdgeInsets.only(left: 8.0, right: 4.0, top: 5.0),
            child: SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  imageRoute,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 15.0, top: 10.0, bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Flexible( 
                          child: Text(
                            platillo['nombre'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true, // Esto permite que el texto se envuelva
                          ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    platillo['descripcion'],
                    style: const TextStyle(fontSize: 17),
                    textAlign: TextAlign.justify
                  ),
                  const SizedBox(height: 5),
                  RichText(
                  text: TextSpan(
                    text: 'Precio: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: EsquemaDeColores.onSecondary,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\$${platillo['precio_unitario']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.green 
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          actualizarPlatillo(platillo);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EsquemaDeColores.secondary,
                        ),
                        child: const Icon(Icons.update, color: Colors.white, size: 35,)
                      ),
                    ),
                    const SizedBox(width: 20), 
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          eliminarPlatillo(platillo);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Icon(Icons.delete_forever, color: Colors.white, size: 35,)
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> crearPlatillo() async {
    String nombre = '';
    String descripcion = '';
    String precio = '';
    List<String> listaCategorias = ['Seco', 'Principio', 'Bebida', 'Sopa', 'Complemento'];
    String categoria = listaCategorias.first; // Categoría por defecto
    XFile? image ;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Crear Platillo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.green,
              ),
              textAlign: TextAlign.center
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height:8),
                    SizedBox(
                      width:150,
                      height:150,
                      child:  image!=null 
                      ? Image.file(File(image!.path))
                      : Container(
                        color: EsquemaDeColores.primary,
                        child: const Center(
                          child: Text('Sin imagen',
                            style: TextStyle(
                              color: EsquemaDeColores.onPrimary,
                              fontSize: 18
                            ),
                          )
                        ),
                      )
                    ),
                    const SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? pickedImage =
                          await picker.pickImage(source: ImageSource.gallery);
                        if(pickedImage != null){
                          setState(() {
                            image = pickedImage;
                            }
                          );
                        }
                        else{
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cargar Imagen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      onChanged: (value) {
                        nombre = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: null, // Para permitir múltiples líneas
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      onChanged: (value) {
                        descripcion = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        precio = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Categoría:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: EsquemaDeColores.primary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        DropdownButton<String>(
                          value: categoria,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 20,
                          elevation: 16,
                          style: const TextStyle(
                              color: Colors.deepPurple, fontSize: 18),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              categoria = newValue!;
                            });
                          },
                          items: listaCategorias
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: EsquemaDeColores.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                )
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if(nombre == '' || descripcion == '' || precio == ''){
                      showCustomErrorDialog(context, '¡Llene toda la información del platillo!');
                      return;
                    }

                    try {
                      int.parse(precio);
                    } catch (e) {
                      showCustomErrorDialog(context, '¡El precio del platillo debe ser un número entero!');
                      return;
                    }

                    try {
                      final List<Map<String, dynamic>> nuevoPlatillo = await supabase.from('Platillo').insert({
                        'nombre': nombre,
                        'descripcion': descripcion,
                        'precio_unitario':
                            int.parse(precio), // Convertir a entero
                        'categoria_alimenticia': categoria,
                      }).select();

                      final idNuevoPlatillo = nuevoPlatillo[0]['id'];
                      final imagePath = '/IDPlatillo/$idNuevoPlatillo/imagenPlatillo';

                      if(image != null){
                        final imageExtension = image!.path.split('.').last.toLowerCase();
                        final imageBytes = await image!.readAsBytes();
                        await supabase.storage.from('platillos').uploadBinary(
                          imagePath, imageBytes, fileOptions:  FileOptions(upsert:true, contentType: 'image/$imageExtension'),
                        );
                      }
                      else{
                        const defaultRoute = 'https://lh3.googleusercontent.com/fife/ALs6j_EcQD7GAXpgxohKMGrzoFv0_hncOPsPHd4n_XbM6koMI3I5z6FoJB5pzwJu0maY9xNsb1EEX4XqRus9p_NYp9lUx84Gvyy7ZDsMOR7rmMRdMhg7__8N5JUowUGZJrYa1LDrnIlPnpSspKLFumJIw41iMOOoGKJbP5V2vFTu7TrwPhhG2s16jNPqkW-ujqGPq-9a8gf-VSqhKPcM8dyTz8lKKPQllLe3hQpkGUTPPiR_DtkRhm1Y6FhXFwENS3oICrDupZcecUarWv0QP-js5bR0aNQg-vnS2V6MeF5Wct7tKBAYGZEi4uv8l4Nb9-j7hu20avGpdAXE7ftGth-qLhE-XRebmBLpMJDkFdkeZ9f5YmFZarxSkLoRj4tTf65-HSp16yvLwy7ys4-e8hIKUpdwQd3pNMMzXvBVoWsftx9LUVvo9OCwNAOhWNlJ7fFZBASebCLWdR2oz0gZ3PmgEFUcFm_tX972SANN-RtHmgAjxuHj2cEWFvFiWXwl-rIUKlYsa-Zr96450ni5PIMscZaLBKHNVoz7aK0tvXhSR6tOyd7nTfFoucnRBaheSyAMoV9xS5tUx_1xHdeF6uBmpvmw8WXk1KR2YAA_7C0RxV_UrJJufWvURnpySDrCIOVcrnaX5scApS0XexhA_kzmU6J7Z7XbOC3HzrT8FrQ0yP1_PsHb9TlO2C06ql3rFJ5FtrSY4-O2yRTdiVTkkz6_9ze__tlDdAw-81JSvQcDujyWpsQbtOrEDiAaymJRicFM7Bjo0al-aUT5vUpubySmbzDRWEkQc5lSjk9XXF5V-c0qRGfCtUsUtcKybODHdIFu49O_V11tpanwq3GwQrJikcVlF_eb1zMIiPvXX5b-TYmys44nKaksnQyaFQWx7DPSnUdfgUuL0V5nhWF1Yjd71CqO648apfN8BtEMxlCG0l7iFpxmNA-Nu2VUvCsD11HH1l1nHK3A-PVSl1zhsj0s1TTFA11tpNeNYxAM1Rtdonbq3GFR6tu4TAMFDwbBM_rYfZWU4_VRo-noKXtdiyzPAnkw-EEtSEhHpJkwZLO4jriSrP0jDMW87a5XWwYfEQR_QQqkjjTjJhaLvZT9uIdUslMjpauUfosXkdQZZ0YyX27WFt6jIUR2ofFwLGz-MICiQfznw_Lne7yBZAk5cFzKruGOXtsfMYxr0iq_9lQxidNYAJJUTrzj6tey3U-pln4hfDZMwNsIstRJS1EB-fkoiy9KRycu8m9iFiz0G28pH-EomL8DtGeQ0mlOYluvhQ-dcjyj6EDgd_DHLSxf_P6LPZ0Cky0oZLrg859AUQc5zXYUvD30F3sxDTj_ZUiDxX1Wg4TBmbAhZERdNKywLTqxTLliXCviQ75QasU2h84c1oEKmbOn-ccPp4sJXqHHxSfLBQvxZ5dsCWC3wAP07LEnrH6Yd60S_u77hL4n_C4xmyaNmQ5Q32s1cC0sTYC2xyEV2WtzA6q7msrq6YJBC5O7eIGY4uRxSrAPggZETjxpH_wGtXuw_5pdx5iDvvkMhbnPWOIflb9PVdDyzcJGjcqt15dJ8UxSPZ8YhOFDNtQ8eNfR3kfaIw2ivzCdjylSnolZBugfVgb0sFZmtEblDh0bP8ACxoza8VJk38rZ_Sg1iaOKOGN8Lo_yZhbv3ORPCPfc5UYx555M1G4VX1yLYdaqsRYfBUMXlIIjA4KnDBvBW7QZVECdFeR1nQHRNJA=w1325-h619';
                        final defaultImage = await http.get(Uri.parse(defaultRoute)); 
                        final defaultImageBytes = defaultImage.bodyBytes;
                        await supabase.storage.from('platillos').uploadBinary(
                          imagePath, defaultImageBytes, fileOptions:  const FileOptions(upsert:true, contentType: 'image/.jpeg'),
                        );
                      }

                      Navigator.of(context).pop();
                      cargarPlatillos();
                    } catch (e) {
                      showCustomErrorDialog(context, e.toString());
                      return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Crear',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> actualizarPlatillo(Map<String, dynamic> platillo) async {
    //Controladores - Obtener la información del platillo
    final nombreController = TextEditingController();
    nombreController.text = platillo['nombre'];
    final descripcionController = TextEditingController();
    descripcionController.text = platillo['descripcion'];
    final precioController = TextEditingController();
    precioController.text = platillo['precio_unitario'].toString();
    //Dropdownbutton - Iniciar en el correcto:
    List<String> listaCategorias = ['Seco', 'Principio', 'Bebida', 'Sopa', 'Complemento'];
    String categoria = listaCategorias.first;
    for (var i = 0; i < listaCategorias.length; i++) {
      if(listaCategorias[i]==platillo['categoria_alimenticia']){
        categoria = listaCategorias[i];
      }
    }
    //Cargar imagen por defecto
    final idPlatillo = platillo['id'];
    final path = 'IDPlatillo/$idPlatillo/imagenPlatillo';
    String rutaImagen = supabase.storage.from('platillos').getPublicUrl(path);
    rutaImagen = Uri.parse(rutaImagen).replace(queryParameters: {
      't': DateTime.now().millisecond.toString()
      }).toString();
    //nueva imagen
    XFile? newImage;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Actualizar Plato",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.green,
              ),
              textAlign: TextAlign.center
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height:8),
                    SizedBox(
                      width:150,
                      height:150,
                      child: newImage!=null 
                      ? Image.file(File(newImage!.path))
                      :Image.network(
                        rutaImagen,
                        fit: BoxFit.cover,
                      )
                    ),
                    const SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? pickedImage =
                          await picker.pickImage(source: ImageSource.gallery);
                        if(pickedImage != null){
                          setState(() {
                            newImage = pickedImage;
                            }
                          );
                        }
                        else{
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cargar Imagen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    TextField(
                      controller: nombreController,
                      decoration: const  InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descripcionController,
                      maxLines: null, // Para permitir múltiples líneas
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: precioController,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Categoría:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: EsquemaDeColores.primary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        DropdownButton<String>(
                          value: categoria,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 20,
                          elevation: 16,
                          style: const TextStyle(
                              color: Colors.deepPurple, fontSize: 18),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              categoria = newValue!;
                            });
                          },
                          items: listaCategorias
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: EsquemaDeColores.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                )
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'cerrar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    if(nombreController.text.trim() == '' || descripcionController.text.trim() == '' || precioController.text.trim() == ''){
                      showCustomErrorDialog(context, '¡Llene toda la información del platillo!');
                      return;
                    }

                    try {
                      int.parse(precioController.text.trim());
                    } catch (e) {
                      showCustomErrorDialog(context, '¡El precio del platillo debe ser un número entero!');
                      return;
                    }

                    try {
                      await supabase.from('Platillo').update({
                        'nombre': nombreController.text.trim(),
                        'descripcion': descripcionController.text.trim(),
                        'precio_unitario':
                            int.parse(precioController.text.trim()), // Convertir a entero
                        'categoria_alimenticia': categoria,
                      })
                      .match({'id':'$idPlatillo'});
                      
                      //'Update' de la imagen del platillo
                      if (newImage != null) {
                        final imageExtension = newImage!.path.split('.').last.toLowerCase();
                        final imageBytes = await newImage!.readAsBytes();
                        //eliminamos la imagen anterior:
                        try {
                          await supabase.storage.from('platillos').remove(['IDPlatillo/$idPlatillo/imagenPlatillo']);
                        } catch (e) {
                          showCustomErrorDialog(context, e.toString());
                          return;
                        }
                        //Subimos la nueva:
                        await supabase.storage.from('platillos').uploadBinary(
                          'IDPlatillo/$idPlatillo/imagenPlatillo', 
                          imageBytes, 
                          fileOptions:  FileOptions(
                            upsert:true,
                            contentType: 'image/$imageExtension'
                          ),
                        );
                      }
                      
                      Navigator.of(context).pop();
                      cargarPlatillos();
                    } catch (e) {
                      showCustomErrorDialog(context, e.toString());
                      return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Actualizar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarPlatillo(Map<String, dynamic> platillo) async {
    await showDialog(
      context:context,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿Esta Seguro?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.red,
                ),
              ),     
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Text(
              "Eliminar este platillo es irreversible y su información no podrá ser recuperada.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
                color: EsquemaDeColores.onSecondary,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10), 
            ElevatedButton(
              onPressed: () async {
                final idPlatillo = platillo['id'];
                //Eliminamos el platillo
                try {
                  await supabase
                    .from('Platillo')
                    .delete()
                    .match({ 'id': platillo['id'] });
                } catch (e) {
                  showCustomErrorDialog(context, e.toString());
                  return;
                }

                //Eliminamos su correspondiente imagen
                try {
                  await supabase.storage.from('platillos').remove(['IDPlatillo/$idPlatillo/imagenPlatillo']);
                  Navigator.of(context).pop();
                  setState(() {
                    cargarPlatillos();
                  });
                } catch (e) {
                  showCustomErrorDialog(context, e.toString());
                  return;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), 
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EsquemaDeColores.onPrimary
                ),
              ),
            ),
          ],
        ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}