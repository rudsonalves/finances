import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/app_button_styles.dart';
import '../../locator.dart';
import './category_state.dart';
import './category_controller.dart';
import './widgets/categories_header.dart';
import './widgets/dismissible_category.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import 'widgets/add_category_dialog.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _controller = locator.get<CategoryController>();

  @override
  void initState() {
    super.initState();
    initController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initController() async {
    await _controller.init();
  }

  void callBack() {
    _controller.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: Text(
          locale.categoryPageCategories,
          style: AppTextStyles.textStyleSemiBold18,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AppTopBorder(),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.onSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CategoriesHeader(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            // Category State Loading
                            if (_controller.state is CategoryStateLoading) {
                              return CustomCircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              );
                            }

                            // Category is Empty
                            if (_controller.categories.isEmpty) {
                              return Center(
                                child: Text(
                                  locale.categoryPageNoCategories,
                                ),
                              );
                            }

                            // Category State Success
                            if (_controller.state is CategoryStateSuccess) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _controller.categories.length,
                                itemBuilder: (context, index) {
                                  return DismissibleCategory(
                                    controller: _controller,
                                    index: index,
                                    callBack: callBack,
                                  );
                                },
                              );
                            }

                            // Category State Error
                            return Center(
                              child: Text(
                                locale.categoryPageTryLate,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (context) => AddCategoryDialog(
                                callBack: callBack,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(locale.genericAdd),
                          style: AppButtonStyles.primaryButtonColor(context),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: Text(locale.genericClose),
                          style: AppButtonStyles.primaryButtonColor(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
