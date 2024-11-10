import 'package:flutter/material.dart';

class CategoryItemPhone extends StatelessWidget {
  const CategoryItemPhone({
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
      constraints: const BoxConstraints(minWidth: 90, maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        borderRadius: BorderRadius.circular(45),
        color: isSelected ? Colors.black : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(45),
          splashFactory: InkSparkle.splashFactory,
          onTap: isSelected ? null : () => onSelect(),
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
            margin: const EdgeInsets.symmetric(vertical: 35),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: Text(
                      categoryTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 13,
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
