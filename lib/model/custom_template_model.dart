class CustomTemplateResponse {
  final bool status;
  final String message;
  final List<CustomTemplate> data;

  CustomTemplateResponse({required this.status, required this.message, required this.data});

  factory CustomTemplateResponse.fromJson(Map<String, dynamic> json) {
    return CustomTemplateResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((i) => CustomTemplate.fromJson(i)).toList() ?? [],
    );
  }
}

class CustomTemplate {
  final int id;
  final String name;
  final String backgroundImageUrl;
  final int canvasWidth;
  final int canvasHeight;
  final List<CustomTemplateLayer> layers;

  CustomTemplate({
    required this.id,
    required this.name,
    required this.backgroundImageUrl,
    this.canvasWidth = 1080,
    this.canvasHeight = 1080,
    required this.layers,
  });

  factory CustomTemplate.fromJson(Map<String, dynamic> json) {
    // Backend column is background_image_url
    String bgUrl = json['background_image_url'] ?? json['background_image'] ?? '';
    bgUrl = bgUrl.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
    return CustomTemplate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      backgroundImageUrl: bgUrl,
      canvasWidth: json['canvas_width'] ?? 1080,
      canvasHeight: json['canvas_height'] ?? 1080,
      layers: (json['layers'] as List?)?.map((i) => CustomTemplateLayer.fromJson(i)).toList() ?? [],
    );
  }
}

class CustomTemplateLayer {
  final int id;
  final String layerType;
  final String layerName;
  final double posX;
  final double posY;
  final double? width;
  final double? height;
  final double? fontSize;
  final String? colorHex;
  final String? fontFamily;
  final String? defaultValue;
  final bool isEditable;
  final String? textAlign;
  final String? imageUrl;

  CustomTemplateLayer({
    required this.id,
    required this.layerType,
    required this.layerName,
    required this.posX,
    required this.posY,
    this.width,
    this.height,
    this.fontSize,
    this.colorHex,
    this.fontFamily,
    this.defaultValue,
    this.isEditable = true,
    this.textAlign,
    this.imageUrl,
  });

  factory CustomTemplateLayer.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['image_url']?.toString();
    String? imageUrl = rawImageUrl
        ?.replaceAll('127.0.0.1', '10.0.2.2')
        .replaceAll('localhost', '10.0.2.2');

    return CustomTemplateLayer(
      id: json['id'] ?? 0,
      layerType: json['layer_type'] ?? 'text',
      layerName: json['layer_name'] ?? '',
      posX: double.tryParse(json['pos_x']?.toString() ?? '0') ?? 0,
      posY: double.tryParse(json['pos_y']?.toString() ?? '0') ?? 0,
      width: json['width'] != null ? double.tryParse(json['width'].toString()) : null,
      height: json['height'] != null ? double.tryParse(json['height'].toString()) : null,
      fontSize: json['font_size'] != null ? double.tryParse(json['font_size'].toString()) : null,
      colorHex: json['color_hex'],
      fontFamily: json['font_family'],
      defaultValue: json['default_value']?.toString(),
      isEditable: json['is_editable'] == true || json['is_editable'] == 1,
      textAlign: json['text_align']?.toString(),
      imageUrl: imageUrl,
    );
  }
}

