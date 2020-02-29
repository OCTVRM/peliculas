
import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/actores_model.dart';
import 'package:peliculas/src/models/pelicula_model.dart';
import 'dart:convert';
import 'dart:async';

class PeliculasProvider{
  String _apikey    = 'b4772cfd55ae2d73cc781bc046a54574';
  String _url       = 'api.themoviedb.org';
  String _language  = 'es-ES';

  int _popularesPage = 0;
  bool _cargando    = false;

  List<Pelicula> _populares = new List();

//
final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

//abro flujo de datos de ingreso
Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;
//Salida stream de peliculas
Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;

  //método obligatorio para cerrar los stream.
  void disposeStreams(){
    _popularesStreamController?.close();
  }




  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get( url );
    final decodedData = json.decode(resp.body);

    final peliculas = new Peliculas.fromJsonList(decodedData['results']);

    return peliculas.items;
}


  Future<List<Pelicula>> getEnCines() async {

    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key'   : _apikey,
      'languaje'  : _language,
    });

    return await _procesarRespuesta(url);

  }


Future<List<Pelicula>> getPopulares() async {

  if (_cargando ) return [];

  _cargando = true;

  _popularesPage++;

  final url = Uri.https(_url, '3/movie/popular',{
    'api_key'   : _apikey,
    'languaje'  : _language,
    'page'      : _popularesPage.toString()
  });

  final resp = await _procesarRespuesta(url);

  _populares.addAll(resp);
  popularesSink( _populares );

  _cargando = false;
  return resp;
}

Future<List<Actor>> getCast( String peliId) async{
  //Creamos el URL
  final url = Uri.https(_url, '3/movie/$peliId/credits',{
    'api_key'   : _apikey,
    'languaje'  : _language,
  });

  //varia "resp" que almacena la respuesta de la url
  final resp = await http.get(url);
  //Variable con la que almacenamos la información, transformada en un MAPA
  final decodedData = json.decode(resp.body);
  //"cast" variable en la cual recibimos los datos completos con formato.
  final cast = new Cast.fromJsonList(decodedData['cast']);

  return cast.actores;

}


}