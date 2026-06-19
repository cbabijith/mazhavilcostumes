import 'package:equatable/equatable.dart';

// Product domain models for the Mazhavil Costumes mobile app.
//
// Mirrors the Next.js Product domain types including costumes-specific
// fields (material, metal_purity, metal_color, weight_grams) and
// rental-specific fields (condition, min/max rental days, inventory counts).

class BranchInventory extends Equatable {
  final String id;
  final String productId;
  final String branchId;
  final int stockCount;
  final String? branchName;
  final String createdAt;
  final String updatedAt;

  const BranchInventory({
    required this.id,
    required this.productId,
    required this.branchId,
    required this.stockCount,
    this.branchName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, productId, branchId, stockCount, branchName, createdAt, updatedAt];

  factory BranchInventory.fromJson(Map<String, dynamic> json) {
    String? branchName = json['branch_name'] as String?;
    if (branchName == null && json['branches'] is Map) {
      branchName = (json['branches'] as Map<String, dynamic>)['name'] as String?;
    }

    return BranchInventory(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      branchId: json['branch_id'] as String? ?? '',
      stockCount: json['stock_count'] as int? ?? json['quantity'] as int? ?? 0,
      branchName: branchName,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'branch_id': branchId,
      'stock_count': stockCount,
      'branch_name': branchName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductImage extends Equatable {
  final String url;
  final String altText;
  final bool isPrimary;
  final int sortOrder;

  const ProductImage({
    required this.url,
    this.altText = '',
    this.isPrimary = false,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [url, altText, isPrimary, sortOrder];

  factory ProductImage.fromJson(dynamic json) {
    if (json is String) {
      return ProductImage(url: json);
    }
    return ProductImage(
      url: json['url'] ?? '',
      altText: json['alt_text'] ?? json['alt'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'alt_text': altText,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
    };
  }
}

class ProductVariant extends Equatable {
  final String id;
  final String name;
  final String value;
  final double additionalPrice;
  final bool inStock;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.value,
    this.additionalPrice = 0,
    this.inStock = true,
  });

  @override
  List<Object?> get props => [id, name, value, additionalPrice, inStock];

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      additionalPrice: (json['additional_price'] as num?)?.toDouble() ?? 0,
      inStock: json['in_stock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'additional_price': additionalPrice,
      'in_stock': inStock,
    };
  }
}

class Product extends Equatable {
  final String id;
  final String storeId;
  final String? categoryId;
  final String? subcategoryId;
  final String? subvariantId;
  final String? branchId;
  final String? categoryName;
  final String name;
  final String slug;
  final String? description;
  final String? sku;
  final String? barcode;
  final double pricePerDay;
  final double purchasePrice;
  final double securityDeposit; // Kept for UI backward compatibility, defaults to 0.0
  final double gstPercentage;

  // Inventory
  final int quantity;
  final int availableQuantity;
  final int reservedQuantity;
  final int maintenanceQuantity;
  final int totalQuantity;

  // Costumes-specific
  final String? material;
  final String? metalPurity;
  final String? metalColor;
  final double? weightGrams;

  // Rental-specific
  final String? condition;
  final String? sanitizationStatus;
  final int? minRentalDays;
  final int? maxRentalDays;

  // Media & variants
  final List<ProductImage> images;
  final List<ProductVariant> sizes;
  final List<ProductVariant> colors;

  // Flags
  final bool isActive;
  final bool isFeatured;
  final bool trackInventory;
  final int lowStockThreshold;

  // Timestamps
  final String createdAt;
  final String? updatedAt;

  // Audit Fields (matching Admin types)
  final String? createdBy;
  final String? createdAtBranchId;
  final String? updatedBy;
  final String? updatedAtBranchId;

  // Branch inventory
  final List<BranchInventory> branchInventory;

  const Product({
    required this.id,
    required this.storeId,
    this.categoryId,
    this.subcategoryId,
    this.subvariantId,
    this.branchId,
    this.categoryName,
    required this.name,
    required this.slug,
    this.description,
    this.sku,
    this.barcode,
    required this.pricePerDay,
    this.purchasePrice = 0.0,
    this.securityDeposit = 0.0,
    this.gstPercentage = 0.0,
    required this.quantity,
    required this.availableQuantity,
    this.reservedQuantity = 0,
    this.maintenanceQuantity = 0,
    this.totalQuantity = 0,
    this.material,
    this.metalPurity,
    this.metalColor,
    this.weightGrams,
    this.condition,
    this.sanitizationStatus,
    this.minRentalDays,
    this.maxRentalDays,
    this.images = const [],
    this.sizes = const [],
    this.colors = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.trackInventory = true,
    this.lowStockThreshold = 10,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdAtBranchId,
    this.updatedBy,
    this.updatedAtBranchId,
    this.branchInventory = const [],
  });

  @override
  List<Object?> get props => [
        id,
        storeId,
        categoryId,
        subcategoryId,
        subvariantId,
        branchId,
        categoryName,
        name,
        slug,
        description,
        sku,
        barcode,
        pricePerDay,
        purchasePrice,
        securityDeposit,
        gstPercentage,
        quantity,
        availableQuantity,
        reservedQuantity,
        maintenanceQuantity,
        totalQuantity,
        material,
        metalPurity,
        metalColor,
        weightGrams,
        condition,
        sanitizationStatus,
        minRentalDays,
        maxRentalDays,
        images,
        sizes,
        colors,
        isActive,
        isFeatured,
        trackInventory,
        lowStockThreshold,
        createdAt,
        updatedAt,
        createdBy,
        createdAtBranchId,
        updatedBy,
        updatedAtBranchId,
        branchInventory,
      ];

  /// Quick helper — primary image URL or null.
  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.where((i) => i.isPrimary);
    return primary.isNotEmpty ? primary.first.url : images.first.url;
  }

  /// Stock status label for UI badges.
  String get stockStatusLabel {
    if (availableQuantity <= 0) return 'Out of Stock';
    if (availableQuantity <= lowStockThreshold) return 'Low Stock';
    return 'In Stock';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      subcategoryId: json['subcategory_id'] as String?,
      subvariantId: json['subvariant_id'] as String?,
      branchId: json['branch_id'] as String?,
      categoryName: json['category']?['name'] as String?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      gstPercentage: (json['gst_percentage'] as num?)?.toDouble() ??
          (json['category']?['gst_percentage'] as num?)?.toDouble() ??
          0.0,
      quantity: json['quantity'] as int? ?? 0,
      availableQuantity: json['available_quantity'] as int? ?? 0,
      reservedQuantity: json['reserved_quantity'] as int? ?? 0,
      maintenanceQuantity: json['maintenance_quantity'] as int? ?? 0,
      totalQuantity: json['total_quantity'] as int? ?? json['quantity'] as int? ?? 0,
      material: json['material'] as String?,
      metalPurity: json['metal_purity'] as String?,
      metalColor: json['metal_color'] as String?,
      weightGrams: (json['weight_grams'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
      sanitizationStatus: json['sanitization_status'] as String?,
      minRentalDays: json['min_rental_days'] as int?,
      maxRentalDays: json['max_rental_days'] as int?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e))
              .toList() ??
          [],
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      colors: (json['colors'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      trackInventory: json['track_inventory'] as bool? ?? true,
      lowStockThreshold: json['low_stock_threshold'] as int? ?? 10,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
      createdBy: json['created_by'] as String?,
      createdAtBranchId: json['created_at_branch_id'] as String?,
      updatedBy: json['updated_by'] as String?,
      updatedAtBranchId: json['updated_at_branch_id'] as String?,
      branchInventory: _parseBranchInventory(json),
    );
  }

  /// Parse branch inventory from either 'branch_inventory' or 'product_inventory' key.
  static List<BranchInventory> _parseBranchInventory(Map<String, dynamic> json) {
    final raw = json['branch_inventory'] ?? json['product_inventory'];
    if (raw is List) {
      return raw.map((e) => BranchInventory.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'subvariant_id': subvariantId,
      'branch_id': branchId,
      'category_name': categoryName,
      'name': name,
      'slug': slug,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'price_per_day': pricePerDay,
      'purchase_price': purchasePrice,
      'security_deposit': securityDeposit,
      'gst_percentage': gstPercentage,
      'quantity': quantity,
      'available_quantity': availableQuantity,
      'reserved_quantity': reservedQuantity,
      'maintenance_quantity': maintenanceQuantity,
      'total_quantity': totalQuantity,
      'material': material,
      'metal_purity': metalPurity,
      'metal_color': metalColor,
      'weight_grams': weightGrams,
      'condition': condition,
      'sanitization_status': sanitizationStatus,
      'min_rental_days': minRentalDays,
      'max_rental_days': maxRentalDays,
      'images': images.map((e) => e.toJson()).toList(),
      'sizes': sizes.map((e) => e.toJson()).toList(),
      'colors': colors.map((e) => e.toJson()).toList(),
      'is_active': isActive,
      'is_featured': isFeatured,
      'track_inventory': trackInventory,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'created_at_branch_id': createdAtBranchId,
      'updated_by': updatedBy,
      'updated_at_branch_id': updatedAtBranchId,
      'branch_inventory': branchInventory.map((e) => e.toJson()).toList(),
    };
  }
}
