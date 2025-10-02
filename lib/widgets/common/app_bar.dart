import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showCartIcon;
  final bool showSearchIcon;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onCartPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showCartIcon = true,
    this.showSearchIcon = true,
    this.onSearchPressed,
    this.onCartPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor,
      elevation: elevation,
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    List<Widget> appBarActions = [];

    if (showSearchIcon) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchPressed ?? () => _showSearchDialog(context),
          tooltip: 'ค้นหา',
        ),
      );
    }

    if (showCartIcon) {
      appBarActions.add(
        Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: onCartPressed ?? () => _navigateToCart(context),
                  tooltip: 'ตะกร้าสินค้า',
                ),
                if (cartProvider.totalItemsCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppConstants.errorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartProvider.totalItemsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return appBarActions;
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SearchDialog(),
    );
  }

  void _navigateToCart(BuildContext context) {
    // Navigate to cart screen
    // This would typically use the bottom navigation or Navigator
    DefaultTabController.of(context)?.animateTo(2); // Assuming cart is tab 2
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ค้นหาสินค้า...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ยกเลิก'),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                ElevatedButton(
                  onPressed: () => _performSearch(_searchController.text),
                  child: const Text('ค้นหา'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    Navigator.of(context).pop();
    // TODO: Implement search functionality
    // This would typically navigate to products screen with search query
    debugPrint('Searching for: $query');
  }
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final String? userEmail;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const ProfileAppBar({
    super.key,
    this.userName,
    this.userEmail,
    this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppConstants.primaryColor,
                child: Text(
                  user?.username.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.username ?? 'ผู้ใช้',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null && user!.email.isNotEmpty)
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('แก้ไขโปรไฟล์'),
                ],
              ),
              onTap: onProfileTap,
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('ตั้งค่า'),
                ],
              ),
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.logout, color: AppConstants.errorColor),
                  SizedBox(width: 8),
                  Text(
                    'ออกจากระบบ',
                    style: TextStyle(color: AppConstants.errorColor),
                  ),
                ],
              ),
              onTap: onLogoutTap,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}