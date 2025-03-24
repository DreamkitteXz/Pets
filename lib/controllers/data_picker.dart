import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerInput extends StatefulWidget {
  final String inputTitle;
  final TextEditingController controller;
  final bool isFutureDateOnly;
  final bool isPastDateOnly;
  final String? hint;
  final String? Function(String?)? validator; // Add validator parameter

  const DatePickerInput({
    Key? key,
    required this.inputTitle,
    required this.controller,
    this.isFutureDateOnly = false,
    this.isPastDateOnly = false,
    this.hint,
    this.validator, // Add to constructor
  }) : super(key: key);

  @override
  State<DatePickerInput> createState() => _DatePickerInputState();
}

class _DatePickerInputState extends State<DatePickerInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            widget.inputTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF041A23),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextFormField(
            controller: widget.controller,
            readOnly: true,
            validator: widget.validator, // Add validator here
            decoration: InputDecoration(
              hintText: widget.hint ?? "DD/MM/AAAA",
              helperText: widget.isFutureDateOnly
                  ? 'Selecione uma data futura'
                  : widget.isPastDateOnly
                      ? 'Selecione uma data passada'
                      : 'Selecione uma data',
              helperStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCAC6C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCAC6C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.date_range_rounded,
                    color: Color(0xFF212121),
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime firstDate =
        widget.isFutureDateOnly ? now : DateTime(now.year - 100);
    DateTime lastDate = widget.isPastDateOnly ? now : DateTime(now.year + 100);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        widget.controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }
}
