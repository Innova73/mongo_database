class PathMilazzo {
  final String id;
  final String nome;
  final int tempoPercorrenza;
  final GeoJson datiGeoJSON;

  PathMilazzo({
    required this.id,
    required this.nome,
    required this.tempoPercorrenza,
    required this.datiGeoJSON,
  });

  factory PathMilazzo.fromJson(Map<String, dynamic> json) {
    return PathMilazzo(
      id: json['_id'].toString(),
      nome: json['nome'],
      tempoPercorrenza: int.parse(json['tempo_percorrenza'].toString()),
      datiGeoJSON: GeoJson.fromJson(json['datiGeoJSON']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome': nome,
      'tempo_percorrenza': tempoPercorrenza,
      'datiGeoJSON': datiGeoJSON.toJson(),
    };
  }
}

class GeoJson {
  final String type;
  final List<Feature> features;

  GeoJson({required this.type, required this.features});

  factory GeoJson.fromJson(Map<String, dynamic> json) {
    return GeoJson(
      type: json['type'],
      features: List<Feature>.from(json['features'].map((x) => Feature.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'features': List<dynamic>.from(features.map((x) => x.toJson())),
    };
  }
}

class Feature {
  final String type;
  final Properties properties;
  final Geometry geometry;

  Feature({required this.type, required this.properties, required this.geometry});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      type: json['type'],
      properties: Properties.fromJson(json['properties']),
      geometry: Geometry.fromJson(json['geometry']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties.toJson(),
      'geometry': geometry.toJson(),
    };
  }
}

class Properties {
  final int id;
  final String name;
  final String description;
  final String? link;

  Properties({required this.id, required this.name, required this.description, this.link});

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'link': link,
    };
  }
}

class Geometry {
  final String type;
  final List<double> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
