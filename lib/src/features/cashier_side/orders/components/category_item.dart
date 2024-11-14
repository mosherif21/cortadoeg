import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.icon,
    required this.categoryTitle,
    required this.isSelected,
    required this.onSelect,
  });

  final IconData icon;
  final String categoryTitle;
  final Function onSelect;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.black : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashFactory: InkSparkle.splashFactory,
          onTap: isSelected ? null : () => onSelect(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Tooltip(
              message: categoryTitle,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: Text(
                      categoryTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
