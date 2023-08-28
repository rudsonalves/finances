import 'package:flutter/material.dart';

class AutocompleteTextFormField extends StatefulWidget {
  final String labelText;
  final String? prefixText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? hintText;
  final TextCapitalization capitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onEditingComplete;
  final Widget? suffixIcon;
  final List<String> suggestions;

  const AutocompleteTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.name,
    this.textInputAction = TextInputAction.next,
    this.hintText,
    this.capitalization = TextCapitalization.none,
    this.validator,
    this.prefixText,
    this.onChanged,
    this.onEditingComplete,
    this.suffixIcon,
    required this.suggestions,
  });

  @override
  State<AutocompleteTextFormField> createState() =>
      _AutocompleteTextFormFieldState();
}

class _AutocompleteTextFormFieldState extends State<AutocompleteTextFormField> {
  bool _isAutoCompleteOpen = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = widget.controller.text.toLowerCase();
    setState(() {
      if (text.length > 2) {
        _filteredSuggestions = widget.suggestions
            .where((suggestion) => suggestion.toLowerCase().contains(text))
            .toList();
      } else {
        _filteredSuggestions = [];
      }
    });
  }

  void _onSuggestionSelected(String suggestion) {
    setState(() {
      _isAutoCompleteOpen = false;
      widget.controller.text = suggestion;
      if (widget.onEditingComplete != null) {
        widget.onEditingComplete!(suggestion);
      }
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Column(
        children: [
          TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.capitalization,
            validator: widget.validator,
            onChanged: (text) {
              setState(() {
                _isAutoCompleteOpen = true;
                if (widget.onChanged != null) {
                  widget.onChanged!(text);
                }
              });
            },
            decoration: InputDecoration(
              suffixIcon: widget.suffixIcon,
              prefixText: widget.prefixText,
              hintText: widget.hintText,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              labelText: widget.labelText.toUpperCase(),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          if (_isAutoCompleteOpen && _filteredSuggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                    color: colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(16)),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    return ListTile(
                      title: Text(suggestion),
                      onTap: () => _onSuggestionSelected(suggestion),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
