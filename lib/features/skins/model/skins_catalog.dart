class SkinsNode {
  const SkinsNode({
    required this.id,
    required this.title,
    required this.entries,
  });

  final String id;
  final String title;
  final List<SkinsEntry> entries;
}

sealed class SkinsEntry {
  const SkinsEntry({
    required this.title,
    required this.iconAsset,
  });

  final String title;
  final String iconAsset;
}

class SkinsEntryNode extends SkinsEntry {
  const SkinsEntryNode({
    required this.nodeId,
    required super.title,
    required super.iconAsset,
  });

  final String nodeId;
}

class SkinsEntryList extends SkinsEntry {
  const SkinsEntryList({
    required this.listId,
    required super.title,
    required super.iconAsset,
  });

  final String listId;
}

class SkinsListSpec {
  const SkinsListSpec({
    required this.id,
    required this.title,
    required this.count,
    required this.assetForIndex,
    required this.itemTitleForIndex,
  });

  final String id;
  final String title;
  final int count;
  final String Function(int index) assetForIndex;
  final String Function(int index) itemTitleForIndex;
}

class SkinsCatalog {
  static const homeTitle = 'Stylish Avatar & Skins';

  static const home = SkinsNode(
    id: 'home',
    title: homeTitle,
    entries: [
      SkinsEntryList(
        listId: 'all_character',
        title: 'All Character',
        iconAsset: 'assets/all_character.png',
      ),
      SkinsEntryNode(
        nodeId: 'animations',
        title: 'Animations',
        iconAsset: 'assets/animations.png',
      ),
      SkinsEntryNode(
        nodeId: 'accesories',
        title: 'Accesories',
        iconAsset: 'assets/accesories.png',
      ),
      SkinsEntryNode(
        nodeId: 'all_clothing',
        title: 'All Clothing',
        iconAsset: 'assets/all_clothing.png',
      ),
      SkinsEntryNode(
        nodeId: 'head_body',
        title: 'Head & Body',
        iconAsset: 'assets/head_body.png',
      ),
    ],
  );

  static const _nodes = <String, SkinsNode>{
    'animations': SkinsNode(
      id: 'animations',
      title: 'Animations',
      entries: [
        SkinsEntryList(
          listId: 'bundle_animation',
          title: 'Bundle Animation',
          iconAsset: 'assets/bundle_1.webp',
        ),
        SkinsEntryList(
          listId: 'emotes_animation',
          title: 'Emotes Animation',
          iconAsset: 'assets/emote_1.png',
        ),
      ],
    ),
    'accesories': SkinsNode(
      id: 'accesories',
      title: 'Accesories',
      entries: [
        SkinsEntryList(
          listId: 'face_accesories',
          title: 'Face Accesories',
          iconAsset: 'assets/face_1.webp',
        ),
        SkinsEntryList(
          listId: 'head_accesories',
          title: 'Head Accesories',
          iconAsset: 'assets/head_1.webp',
        ),
        SkinsEntryList(
          listId: 'neck_accesories',
          title: 'Neck Accesories',
          iconAsset: 'assets/neck_1.webp',
        ),
      ],
    ),
    'all_clothing': SkinsNode(
      id: 'all_clothing',
      title: 'All Clothing',
      entries: [
        SkinsEntryList(
          listId: 'shoes_collection',
          title: 'Shoes Collection',
          iconAsset: 'assets/shoes_1.webp',
        ),
        SkinsEntryList(
          listId: 'pants_collection',
          title: 'Pants Collection',
          iconAsset: 'assets/pants_1.webp',
        ),
        SkinsEntryList(
          listId: 't_shirts_collection',
          title: 'T-Shirts Collection',
          iconAsset: 'assets/t_shirt_1.webp',
        ),
        SkinsEntryList(
          listId: 'shirts_collection',
          title: 'Shirts Collection',
          iconAsset: 'assets/shirt_1.webp',
        ),
      ],
    ),
    'head_body': SkinsNode(
      id: 'head_body',
      title: 'Head & Body',
      entries: [
        SkinsEntryList(
          listId: 'face_look',
          title: 'Face Look',
          iconAsset: 'assets/face_look_1.png',
        ),
        SkinsEntryList(
          listId: 'face_shape',
          title: 'Face Shape',
          iconAsset: 'assets/face_shape_1.webp',
        ),
      ],
    ),
  };

  static SkinsNode? nodeById(String id) => _nodes[id];

  static SkinsListSpec? listById(String id) {
    switch (id) {
      case 'all_character':
        const names = [
          'Lima',
          'Mila',
          'Noah',
          'Ava',
          'Ethan',
          'Mia',
          'Liam',
          'Emma',
          'Olivia',
          'Lucas',
          'Sofia',
          'Aria',
          'James',
          'Henry',
          'Elena',
          'Nova',
          'Kai',
          'Zara',
          'Leo',
          'Nina',
        ];
        return SkinsListSpec(
          id: id,
          title: 'All Character',
          count: 20,
          assetForIndex: (i) => 'assets/character_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'bundle_animation':
        const names = [
          'Hero Run',
          'Ninja Dash',
          'Victory Walk',
          'Royal Step',
          'Shadow Sprint',
          'Power Pose',
          'Sky Glide',
          'Turbo Jump',
          'Wave Rider',
          'Champion Loop',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Bundle Animation',
          count: 10,
          assetForIndex: (i) => 'assets/bundle_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'emotes_animation':
        const names = [
          'Hello Wave',
          'Happy Dance',
          'Thumbs Up',
          'Victory Cheer',
          'Cool Spin',
          'Heart Pose',
          'Funny Laugh',
          'Clap Clap',
          'High Five',
          'Epic Bow',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Emotes Animation',
          count: 10,
          assetForIndex: (i) => 'assets/emote_${i + 1}.png',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'face_accesories':
        const names = [
          'Star Shades',
          'Neon Glasses',
          'Retro Specs',
          'Golden Visor',
          'Cool Lens',
          'Cyber Mask',
          'Cute Blush',
          'Spark Eyes',
          'Night Goggles',
          'Classic Frame',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Face Accesories',
          count: 10,
          assetForIndex: (i) => 'assets/face_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'head_accesories':
        const names = [
          'Street Cap',
          'Royal Crown',
          'Sky Helmet',
          'Cool Beanie',
          'Night Hood',
          'Sunny Hat',
          'Cyber Headset',
          'Angel Halo',
          'Samurai Helm',
          'Party Topper',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Head Accesories',
          count: 10,
          assetForIndex: (i) => 'assets/head_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'neck_accesories':
        const names = [
          'Gold Chain',
          'Pearl Loop',
          'Dragon Pendant',
          'Neon Collar',
          'Lucky Charm',
          'Crystal Tag',
          'Shadow Scarf',
          'Star Locket',
          'Royal Medallion',
          'Street Necklace',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Neck Accesories',
          count: 10,
          assetForIndex: (i) {
            final n = i + 1;
            final ext = n == 10 ? 'png' : 'webp';
            return 'assets/neck_${n}.$ext';
          },
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'shoes_collection':
        const names = [
          'Urban Runner',
          'Gold Kicks',
          'Shadow Steps',
          'Neon Sneakers',
          'Classic Boots',
          'Sky Walkers',
          'Street Slides',
          'Frost Trainers',
          'Red Rockets',
          'Night Runners',
          'Ocean Kicks',
          'Desert Boots',
          'Hero Shoes',
          'Cosmic Steps',
          'Retro Walk',
          'Speed Kicks',
          'Hype Shoes',
          'Vibe Sneakers',
          'Glow Steps',
          'Prime Boots',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Shoes Collection',
          count: 20,
          assetForIndex: (i) => 'assets/shoes_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'pants_collection':
        const names = [
          'Denim Drift',
          'Shadow Jeans',
          'Royal Trousers',
          'Street Cargo',
          'Neon Pants',
          'Classic Fit',
          'Night Cargo',
          'Ocean Denim',
          'Desert Fit',
          'Urban Slim',
          'Frost Jeans',
          'Bold Cargo',
          'Hero Pants',
          'Cosmic Fit',
          'Retro Denim',
          'Prime Pants',
          'Hype Fit',
          'Vibe Denim',
          'Glow Cargo',
          'Legend Fit',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Pants Collection',
          count: 20,
          assetForIndex: (i) => 'assets/pants_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 't_shirts_collection':
        const names = [
          'Pixel Tee',
          'Gold Logo Tee',
          'Shadow Tee',
          'Neon Tee',
          'Classic Tee',
          'Night Tee',
          'Ocean Tee',
          'Desert Tee',
          'Hero Tee',
          'Cosmic Tee',
          'Retro Tee',
          'Prime Tee',
          'Hype Tee',
          'Vibe Tee',
          'Glow Tee',
          'Legend Tee',
          'Street Tee',
          'Frost Tee',
          'Bold Tee',
          'Ultra Tee',
        ];
        return SkinsListSpec(
          id: id,
          title: 'T-Shirts Collection',
          count: 20,
          assetForIndex: (i) => 'assets/t_shirt_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'shirts_collection':
        const names = [
          'Urban Shirt',
          'Royal Shirt',
          'Shadow Shirt',
          'Neon Shirt',
          'Classic Shirt',
          'Night Shirt',
          'Ocean Shirt',
          'Desert Shirt',
          'Hero Shirt',
          'Cosmic Shirt',
          'Retro Shirt',
          'Prime Shirt',
          'Hype Shirt',
          'Vibe Shirt',
          'Glow Shirt',
          'Legend Shirt',
          'Street Shirt',
          'Frost Shirt',
          'Bold Shirt',
          'Ultra Shirt',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Shirts Collection',
          count: 20,
          assetForIndex: (i) => 'assets/shirt_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'face_look':
        const names = [
          'Smile Look',
          'Cool Look',
          'Happy Look',
          'Serious Look',
          'Sassy Look',
          'Hero Look',
          'Mystic Look',
          'Funny Look',
          'Classic Look',
          'Bold Look',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Face Look',
          count: 10,
          assetForIndex: (i) => 'assets/face_look_${i + 1}.png',
          itemTitleForIndex: (i) => names[i % names.length],
        );
      case 'face_shape':
        const names = [
          'Soft Shape',
          'Sharp Shape',
          'Round Shape',
          'Cool Shape',
          'Hero Shape',
          'Classic Shape',
        ];
        return SkinsListSpec(
          id: id,
          title: 'Face Shape',
          count: 6,
          assetForIndex: (i) => 'assets/face_shape_${i + 1}.webp',
          itemTitleForIndex: (i) => names[i % names.length],
        );
    }
    return null;
  }
}
