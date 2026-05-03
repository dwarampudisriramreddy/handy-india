enum ProductType { camera, rvg, xRay, accessory }

class ProductFeature {
  final String title;
  final String description;
  final String? imageUrl;

  ProductFeature({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory ProductFeature.fromMap(Map<String, dynamic> map) {
    return ProductFeature(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double shippingCharge;
  final String imageUrl;
  final String? videoUrl;
  final List<String> imageGallery;
  final List<ProductFeature> features;
  final ProductType type;
  final List<String> specs;
  final Map<String, String> comparableSpecs;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.shippingCharge = 0,
    required this.imageUrl,
    this.videoUrl,
    this.imageGallery = const [],
    this.features = const [],
    required this.type,
    required this.specs,
    required this.comparableSpecs,
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'shippingCharge': shippingCharge,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'imageGallery': imageGallery,
      'features': features.map((f) => f.toMap()).toList(),
      'type': type.index,
      'specs': specs,
      'comparableSpecs': comparableSpecs,
      'isFeatured': isFeatured,
    };
  }

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      shippingCharge: (data['shippingCharge'] ?? (data['deliveryCharge'] ?? 0)).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'],
      imageGallery: List<String>.from(data['imageGallery'] ?? []),
      features: (data['features'] as List? ?? [])
          .map((f) => ProductFeature.fromMap(Map<String, dynamic>.from(f)))
          .toList(),
      type: ProductType.values[data['type'] ?? 0],
      specs: List<String>.from(data['specs'] ?? []),
      comparableSpecs: Map<String, String>.from(data['comparableSpecs'] ?? {}),
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}

// Common features to be reused across products
final featureTwain = ProductFeature(
  title: 'Twain standard protocol',
  description: 'The unique scanner driver protocol of Twain allows our sensors to be perfectly compatible with other software. Therefore, you can still use the existing database and software while using Handy’s sensors, removing your trouble of expensive imported brands’ sensors repair or high-cost replacement.',
  imageUrl: 'https://www.handyimaging.com/uploads/HDR-500600-7.jpg',
);

final featureSoftware = ProductFeature(
  title: 'Powerful imaging management software',
  description: 'As the digital image management software, HandyDentist, was carefully developed by Handy’s engineers, it only takes 1 minute to install and 3 minutes to get started. It realizes one-click image processing, saves doctors\' time to easily finds problems and efficiently completes diagnosis and treatment. HandyDentist image management software provides a powerful management system to facilitate effective communication between doctors and patients.',
  imageUrl: 'https://www.handyimaging.com/uploads/HDR-500600-9.jpg',
);

final featureWebSoftware = ProductFeature(
  title: 'Optional high-performance webs software',
  description: 'Handydentist can be edited and viewed from various computers as the optional high-performance web software support shared data.',
  imageUrl: 'https://www.handyimaging.com/uploads/dsadqweqwe.jpg',
);

final featureISO = ProductFeature(
  title: 'ISO13485 Quality Management System',
  description: 'ISO13485 quality management system for medical device ensures the quality so that customers can rest assured.',
);

final featureUVC = ProductFeature(
  title: 'UVC Free-Driver',
  description: 'Compliant with standard UVC protocol, it eliminates the tedious process of installing drivers and allows a plug-and-use. As long as the third-party software supports the UVC protocol, it can also be used directly without additional drivers.',
);

final List<ProductFeature> hdrSeriesFeatures = [
  ProductFeature(
    title: 'FOP (Fiber Optic Plate)',
    description: 'The built-in FOP reduces X-ray radiation and effectively prolongs the sensor’s service life. As shown in the picture, the red X-rays from A are converted into yellow visible light after flashing, but there are still some red X-rays. After passing through FOP, there’s no red X-ray left.',
    imageUrl: 'https://www.handyimaging.com/uploads/HDR-500600-1.jpg',
  ),
  ProductFeature(
    title: 'Wide dynamic range',
    description: 'Both low and high dose can be easily shot, which greatly reduces the requirements for filming and the possibility of film wasting, and improves the image resolution and sensitivity.',
    imageUrl: 'https://www.handyimaging.com/uploads/HDR-500600-2.jpg',
  ),
  ProductFeature(
    title: 'Wide exposure range',
    description: 'The shooting width of 22.5mm exceeds the global average height of molars and can shoot the whole three teeth. When our peer companies are still providing conventional (No. 1) sensors with an effective area of 20x30mm, we have already designed a sensor with a height of 22.5mm which is more in line with the global average molar height of 22mm, based on clinical practice.',
    imageUrl: 'https://www.handyimaging.com/uploads/HDR-500600-3.jpg',
  ),
  ProductFeature(
    title: 'Optimized chip combination',
    description: 'The CMOS image sensor which is paired with an industrial-grade microfiber panel and the advanced AD-guided technology restores the real tooth picture. The built-in elastic protective layer alleviates the impact of external stress, which is not easy to be damaged when dropped or subjected to pressure, reducing users’ costs.',
    imageUrl: 'https://www.handyimaging.com/uploads/HDR-500600-4.jpg',
  ),
  ProductFeature(
    title: 'Durable Construction',
    description: 'One of the key features of the Handy data cable is its sturdy rip-proof cover. Made from premium PU, the case offers superior protection against damage and wear. The lid is not only extremely durable, but also easy to clean and maintain. With its tear-resistant shell, fine copper wire provides you with more durable products.',
  ),
  ProductFeature(
    title: 'Sterilizable liquid soaking',
    description: 'Our products feature tightly stitched sensors and are designed to achieve IPX7 waterproof rating. This means it can be fully submerged in water and thoroughly sanitized, allowing you to avoid any potential secondary cross-contamination issues.',
    imageUrl: 'https://www.handyimaging.com/uploads/HDR-500600-6.jpg',
  ),
  featureTwain,
  featureSoftware,
  featureWebSoftware,
  featureISO,
];

final List<Product> mockProducts = [
  Product(
    id: 'hdi-712d',
    name: 'Handy HDI-712D Intraoral Camera',
    description: '1080P Full HD intraoral camera with focusing range from 5mm to infinity. Patented technology for root canal microscopy effects.',
    price: 15000.0,
    shippingCharge: 250.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-712D-1.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    imageGallery: [
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-712D-1.jpg',
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-712D-2.jpg',
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-712D-3.jpg',
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-712D-4.jpg',
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-712D-5.jpg',
    ],
    features: [
      ProductFeature(
        title: 'Larger view',
        description: 'With focusing and shooting integrated patented technology and a focusing range from 5mm to infinity, it features 1080P full HD and can realize the imaging of patients\' root canals, double teeth, full mouth and face portrait.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-712D-11.jpg',
      ),
      ProductFeature(
        title: 'Ultra-low distortion optical lens',
        description: 'The lowest distortion design which is lowers than 5%, restoring the tooth structure more realistically',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-712D-6.jpg',
      ),
      ProductFeature(
        title: 'Durable metal body',
        description: 'CNC is carefully carved, fashionable and sturdy. By using anodized process, it is durable, not easy to change color, easier to clean and healthier.',
      ),
      ProductFeature(
        title: '3D adjustable focus slider',
        description: 'The focus switch and the shooting switch are in the same position. Its one-handed focus photography function allows it to be operated with different fingers and hands. It’s the DSLR in intraoral cameras.',
      ),
      ProductFeature(
        title: 'Close up dental photography',
        description: 'For patients with limited mouth opening, it is easier to obtain clear images of posterior teeth.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-712D-7.jpg',
      ),
      ProductFeature(
        title: 'Root canal microscopy',
        description: 'Similar to root canal microscopes, it observes the washing of the root canal wall and the root canal opening after pulp opening. The effect of root canal microscopes, the price of intraoral cameras.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-712D-8.jpg',
      ),
      ProductFeature(
        title: 'High resolution sensors',
        description: 'Large surface 1/3-inch sensor imported from the USA. Single-chip WDR dynamic solution, larger than 115db range, 1080p security dedicated sensor.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-712D-9.jpg',
      ),
      ProductFeature(
        title: 'Natural light lighting',
        description: '6 LED lights distributed around the perimeter of the lens meet the needs of the best light source for tooth colorimetry.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-712D-10-121x300.jpg',
      ),
      featureUVC,
      featureTwain,
      featureSoftware,
      featureWebSoftware,
      featureISO,
    ],
    type: ProductType.camera,
    isFeatured: true,
    specs: ['Resolution: 1080P', 'Focus: 5mm-inf', 'Lighting: 6 LEDs'],
    comparableSpecs: {
      'Item': 'HDI-712D',
      'Resolution': '1080P (1920*1080)',
      'Focus Range': '5mm - infinity',
      'Angle of View': '≥ 60º',
      'Lighting': '6 LEDs',
      'Output': 'USB 2.0',
      'Twain': 'Yes',
      'Operation System': 'Windows 7/10 (32bit&64bit)',
    },
  ),
  Product(
    id: 'hdr-500',
    name: 'Handy HDR-500 RVG Sensor',
    description: 'High-resolution RVG sensor with CMOS APS chip type and GOS scintillator.',
    price: 85000.0,
    shippingCharge: 500.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/1.-HDR-500.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    imageGallery: [
      'https://cdn.globalso.com/handyimaging/1.-HDR-500.jpg',
      'https://cdn.globalso.com/handyimaging/1eb025ed.gif',
      'https://cdn.globalso.com/handyimaging/07aaa6a7.gif',
      'https://cdn.globalso.com/handyimaging/8cf18766.gif',
      'https://cdn.globalso.com/handyimaging/89836eaa.gif',
      'https://cdn.globalso.com/handyimaging/e0f49e8d.gif',
    ],
    features: hdrSeriesFeatures,
    type: ProductType.rvg,
    isFeatured: true,
    specs: ['Chip: CMOS APS', 'Area: 30x22.5mm', 'Resolution: 14-20 lp/mm'],
    comparableSpecs: {
      'Chip Type': 'CMOS APS',
      'Fiber Optic Plate': 'Yes',
      'Scintillator': 'GOS',
      'Dimension': '39 × 28.5 mm',
      'Active Area': '30 × 22.5 mm',
      'Pixel Size': '18.5 μm',
      'Pixels': '1600 × 1200',
      'Resolution': '14–20 lp/mm',
      'Power Consumption': '600 mW',
      'Thickness': '6 mm',
      'Control Box': 'Yes',
      'TWAIN': 'Yes',
      'Operating System': 'Windows 2000 and above',
    },
  ),
  Product(
    id: 'hdr-600',
    name: 'Handy HDR-600 RVG Sensor',
    description: 'Ultra-high definition RVG sensor with CsI scintillator and Direct USB connection.',
    price: 110000.0,
    shippingCharge: 500.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/1.-HDR-500.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    imageGallery: [
      'https://cdn.globalso.com/handyimaging/1.-HDR-500.jpg',
      'https://cdn.globalso.com/handyimaging/1eb025ed.gif',
      'https://cdn.globalso.com/handyimaging/e0f49e8d.gif',
    ],
    features: [
      ProductFeature(
        title: 'CsI Scintillator',
        description: 'Advanced Cesium Iodide (CsI) scintillator for ultra-high definition diagnostics and superior image quality.',
      ),
      ProductFeature(
        title: 'Direct USB Connection',
        description: 'No control box needed. The sensor connects directly to your computer via USB for a more compact and streamlined workspace.',
      ),
      ...hdrSeriesFeatures,
    ],
    type: ProductType.rvg,
    specs: ['Chip: CMOS APS', 'Area: 36x27mm', 'Resolution: 20-27 lp/mm'],
    comparableSpecs: {
      'Chip Type': 'CMOS APS',
      'Fiber Optic Plate': 'Yes',
      'Scintillator': 'CsI',
      'Dimension': '44.5 × 33 mm',
      'Active Area': '36 × 27 mm',
      'Pixel Size': '18.5 μm',
      'Pixels': '1920 × 1440',
      'Resolution': '20–27 lp/mm',
      'Power Consumption': '400 mW',
      'Thickness': '6 mm',
      'Control Box': 'No (Direct USB)',
      'TWAIN': 'Yes',
      'Operating System': 'Windows 2000 and above',
    },
  ),
  Product(
    id: 'hdr-360',
    name: 'Handy HDR-360 RVG Sensor',
    description: 'Versatile RVG sensor with CMOS APS chip type and GOS scintillator.',
    price: 75000.0,
    shippingCharge: 500.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/1.-HDR-500.jpg',
    features: hdrSeriesFeatures,
    type: ProductType.rvg,
    specs: ['Chip: CMOS APS', 'Area: 30x22.5mm', 'Resolution: 14-20 lp/mm'],
    comparableSpecs: {
      'Chip Type': 'CMOS APS',
      'Fiber Optic Plate': 'Yes',
      'Scintillator': 'GOS',
      'Dimension': '39 × 28.5 mm',
      'Active Area': '30 × 22.5 mm',
      'Pixel Size': '18.5 μm',
      'Pixels': '1600 × 1200',
      'Resolution': '14–20 lp/mm',
      'Power Consumption': '~600 mW',
      'Thickness': '6 mm',
      'Control Box': 'Usually Yes',
      'TWAIN': 'Yes',
    },
  ),
  Product(
    id: 'hdr-460',
    name: 'Handy HDR-460 RVG Sensor',
    description: 'Direct USB RVG sensor with CsI scintillator.',
    price: 95000.0,
    shippingCharge: 500.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/1.-HDR-500.jpg',
    features: [
      ProductFeature(
        title: 'Direct USB',
        description: 'Convenient direct USB connection without the need for an external control box.',
      ),
      ...hdrSeriesFeatures,
    ],
    type: ProductType.rvg,
    specs: ['Chip: CMOS APS', 'Area: 35x26mm', 'Resolution: 20-27 lp/mm'],
    comparableSpecs: {
      'Chip Type': 'CMOS APS',
      'Fiber Optic Plate': 'Yes',
      'Scintillator': 'CsI',
      'Dimension': '44.5 × 33 mm',
      'Active Area': '35 × 26 mm',
      'Pixel Size': '18.5 μm',
      'Pixels': '1888 × 1402',
      'Resolution': '20–27 lp/mm',
      'Power Consumption': '~400–600 mW',
      'Thickness': '6 mm',
      'Control Box': 'Direct USB',
      'TWAIN': 'Yes',
    },
  ),
  Product(
    id: 'hdi-220d',
    name: 'Handy HDI-220D Pro Camera',
    description: 'High-definition 1080P intraoral camera with sturdy metal body and professional dental lens.',
    price: 12000.0,
    shippingCharge: 250.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/1.-HDI-220D-intraoral-camera.png',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    imageGallery: [
      'https://cdn.globalso.com/handyimaging/1.-HDI-220D-intraoral-camera.png',
      'https://cdn.globalso.com/handyimaging/2.-HDI-220D-intraoral-camera.png',
    ],
    features: [
      ProductFeature(
        title: 'HD',
        description: 'The image quality of 1080P FHD, with distortion lower than 5%, can perfectly present cracked teeth.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-220C-12.jpg',
      ),
      ProductFeature(
        title: 'Sturdy metal body',
        description: 'The electroplated aluminum alloy shell is easy to clean and durable. As its hand feel is close to that of a dental handpiece, it is easier for doctors to operate.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-220C-21.jpg',
      ),
      ProductFeature(
        title: 'Natural lighting',
        description: '6 LED lights meet the needs of the best light source for tooth colorimetry. The light-transmitting design of the LED backlight panel brings a new user experience.',
      ),
      ProductFeature(
        title: 'Professional dental lens',
        description: 'Professional dental camera lens with long service life and strong anti-aging ability. It is easy for doctors to take photos, increasing trust.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-220C-31.jpg',
      ),
      ProductFeature(
        title: 'Mechanical buttons',
        description: 'The mechanical buttons feel comfortable and more convenient for capturing images.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-220C-42.jpg',
      ),
      ProductFeature(
        title: 'High resolution sensors',
        description: 'Imported from America, a large area of 1/3-inch; Single-chip WDR solution with up to 115dB dynamic range.',
        imageUrl: 'https://www.handyimaging.com/uploads/Intraoral-Camera-HDI-220C-51.jpg',
      ),
      featureUVC,
      featureTwain,
      featureSoftware,
      featureWebSoftware,
      featureISO,
    ],
    type: ProductType.camera,
    specs: ['Resolution: 1080P', 'Focus: 5-35mm', 'Lighting: 6 LEDs'],
    comparableSpecs: {
      'Item': 'HDI-220D',
      'Resolution': '1080P (1920*1080)',
      'Focus Range': '5mm - 35mm',
      'Angle of View': '≥ 60º',
      'Lighting': '6 LEDs',
      'Output': 'USB 2.0',
      'Twain': 'Yes',
      'Operation System': 'Windows 7/10/11 (32bit&64bit)',
    },
  ),
  Product(
    id: 'hdi-200a',
    name: 'Handy HDI-200A Intraoral Camera',
    description: 'Medical-grade CMOS sensor with recording function and UVC free-driver.',
    price: 8500.0,
    shippingCharge: 200.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-200A-USB-2.0-100A-TV-1.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    imageGallery: [
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-200A-USB-2.0-100A-TV-1.jpg',
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-200A-USB-2.0-100A-TV-2.jpg',
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-200A-USB-2.0-100A-TV-3.jpg',
      'https://cdn.globalso.com/handyimaging/Intraoral-Camera-HDI-200A-USB-2.0-100A-TV-5.jpg',
    ],
    features: [
      ProductFeature(
        title: 'CMOS medical-grade sensor',
        description: 'Guarantees images’ color saturation and fidelity. Provides a continuous spectral curve and improves accuracy.',
      ),
      ProductFeature(
        title: 'Simple appearance',
        description: 'Seamless and screw-free, avoids rust and is easy to wipe, more durable.',
      ),
      ProductFeature(
        title: 'Recording function',
        description: 'HDI-200A supports the recording function, which is more convenient for doctors to record patients\' symptoms.',
      ),
      ProductFeature(
        title: 'Natural lighting',
        description: '6 imported LED lights help dentists obtain the real color of the oral cavity.',
      ),
      ProductFeature(
        title: 'HD lens',
        description: 'Easy to obtain images of cracked teeth, carious mucosal lesions, etc.',
      ),
      featureUVC,
      featureTwain,
      featureSoftware,
      featureWebSoftware,
      featureISO,
    ],
    type: ProductType.camera,
    specs: ['Resolution: 480P', 'Focus: 5-35mm', 'Lighting: 6 LEDs'],
    comparableSpecs: {
      'Item': 'HDI-200A/100A',
      'Resolution': '480P (640*480)',
      'Focus Range': '5mm - 35mm',
      'Angle of View': '≥ 60º',
      'Lighting': '6 LEDs',
      'Output': 'USB(200A) / CVBS(100A)',
      'Twain': 'Yes(200A)',
      'Operation System': 'Windows 7/10 (32bit&64bit), Android',
    },
  ),
  Product(
    id: 'portable-xray',
    name: 'Portable High-Frequency X-Ray Unit',
    description: 'Introducing our latest product, the compact radiation detector, designed with SLR inspiration and user-friendly features. Small in size and weighs only 1.9 kg, making it travel-friendly.',
    price: 150000.0,
    shippingCharge: 1000.0,
    imageUrl: 'https://cdn.globalso.com/handyimaging/ede6d956.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    imageGallery: [
      'https://cdn.globalso.com/handyimaging/ede6d956.jpg',
    ],
    features: [
      ProductFeature(
        title: 'User-friendly Design',
        description: 'Radiation well-controlled, real-time monitor of radiation dose. Childproof lock, safety protection for children, prevents misuse. Power-on self-test, easy troubleshooting. Digital display, easy to operate',
        imageUrl: 'https://www.handyimaging.com/uploads/aa0589ea1.jpg',
      ),
      ProductFeature(
        title: 'Advantages of 70kV 2mA',
        description: 'Fast exposure time. Increased X-ray penetration. High effective dose rate. Effective reduction of image blur.',
        imageUrl: 'https://www.handyimaging.com/uploads/aa0589ea.jpg',
      ),
      ProductFeature(
        title: 'Innovative Radiation Control',
        description: 'Equipped with innovative radiation control technology that provides real-time monitoring of radiation levels, ensuring that users remain safe at all times.',
      ),
      ProductFeature(
        title: 'Power-on self-test',
        description: 'Performs a diagnostic test of the detector’s internal components when powered on, ensuring that users can easily troubleshoot.',
      ),
    ],
    type: ProductType.xRay,
    specs: ['Voltage: 70kV', 'Current: 2mA', 'Weight: 1.9kg'],
    comparableSpecs: {
      'Voltage': '70kV',
      'Current': '2mA',
      'Weight': '1.9 kg',
      'Safety': 'Childproof lock',
      'Display': 'Digital',
    },
  ),
];
