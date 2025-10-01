import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showLabels;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.secondaryColor,
        selectedFontSize: showLabels ? AppConstants.fontSizeSmall : 0,
        unselectedFontSize: showLabels ? AppConstants.fontSizeSmall : 0,
        backgroundColor: Colors.white,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
            label: showLabels ? 'หน้าแรก' : '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.store_outlined, Icons.store, 1),
            label: showLabels ? 'สินค้า' : '',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                return _buildCartIcon(cartProvider.totalItemsCount, 2);
              },
            ),
            label: showLabels ? 'ตะกร้า' : '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.receipt_long_outlined, Icons.receipt_long, 3),
            label: showLabels ? 'คำสั่งซื้อ' : '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.person_outline, Icons.person, 4),
            label: showLabels ? 'โปรไฟล์' : '',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    final isSelected = currentIndex == index;
    
    return AnimatedContainer(
      duration: AppConstants.animationDurationShort,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppConstants.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Icon(
        isSelected ? filledIcon : outlinedIcon,
        size: 24,
      ),
    );
  }

  Widget _buildCartIcon(int itemCount, int index) {
    final isSelected = currentIndex == index;
    
    return AnimatedContainer(
      duration: AppConstants.animationDurationShort,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppConstants.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Stack(
        children: [
          Icon(
            isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
            size: 24,
          ),
          if (itemCount > 0)
            Positioned(
              right: 0,
              top: 0,
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
                  itemCount > 99 ? '99+' : '$itemCount',
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
      ),
    );
  }
}

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavBarItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: AppConstants.animationDurationMedium,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (selectedColor ?? AppConstants.primaryColor).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected
                        ? selectedColor ?? AppConstants.primaryColor
                        : unselectedColor ?? AppConstants.secondaryColor,
                  ),
                  if (isSelected && item.label != null) ...[
                    const SizedBox(width: 8),
                    AnimatedOpacity(
                      duration: AppConstants.animationDurationMedium,
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Text(
                        item.label!,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: selectedColor ?? AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FloatingNavBarItem {
  final IconData icon;
  final String? label;
  final Widget? badge;

  const FloatingNavBarItem({
    required this.icon,
    this.label,
    this.badge,
  });
}

// Modern Curved Bottom Navigation Bar
class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavBarItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppConstants.animationDurationMedium,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (selectedColor ?? AppConstants.primaryColor).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? selectedColor ?? AppConstants.primaryColor
                              : unselectedColor ?? AppConstants.secondaryColor,
                        ),
                        if (item.badge != null) item.badge!,
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: AppConstants.animationDurationMedium,
                    style: TextStyle(
                      fontSize: isSelected ? 12 : 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? selectedColor ?? AppConstants.primaryColor
                          : unselectedColor ?? AppConstants.secondaryColor,
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavBarItem {
  final IconData icon;
  final String label;
  final Widget? badge;

  const BottomNavBarItem({
    required this.icon,
    required this.label,
    this.badge,
  });
}

// Badge Widget for Cart or Notifications
class NavBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const NavBadge({
    super.key,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color ?? AppConstants.errorColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(
          minWidth: 16,
          minHeight: 16,
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}