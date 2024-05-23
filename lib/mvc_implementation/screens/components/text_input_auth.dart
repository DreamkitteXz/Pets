import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/components/data_picker.dart';

class TextInput extends StatefulWidget {
  final String inputTitle;
  final TextEditingController controller;
  final bool isPassword;
  bool dataPicker;
  String? hint;

  TextInput(
      {Key? key,
      required this.inputTitle,
      required this.controller,
      this.isPassword = false,
      this.dataPicker = false,
      this.hint})
      : super(key: key);

  @override
  State<TextInput> createState() => TextInputState();
}

class TextInputState extends State<TextInput> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    String article = artigoPalavra();

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
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: widget.hint,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCAC6C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              suffixIcon: widget.isPassword
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF212121),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    )
                  : widget.dataPicker
                      ? Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.date_range_rounded,
                              color: Color(0xFF212121),
                            ),
                            onPressed: () async {
                              DateTime? _selectedDate;
                              if (widget.dataPicker) {
                                DateTime? pickedDate =
                                    await _showDataPickernasc(
                                        _selectedDate, context);
                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDate = pickedDate;
                                    widget.controller.text =
                                        formatDateToString(pickedDate);
                                  });
                                }
                              }
                            },
                          ),
                        )
                      : null,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCAC6C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFFDA29B),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFFDA29B),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            onTap: () async {
              DateTime? _selectedDate;
              if (widget.dataPicker) {
                DateTime? pickedDate =
                    await _showDataPickernasc(_selectedDate, context);
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                    widget.controller.text = formatDateToString(pickedDate);
                  });
                }
              }
            },
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Insira $article ${widget.inputTitle}';
              }
            },
          ),
        ),
        if (widget.isPassword)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  //TODO: COLOCAR A TELA DE ESQUECEU A SENHA!
                  child: Text(
                    'Esqueceu a Senha?',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // VERIFICA SE A PALAVRA É MASCULINA OU FEMININA
  String artigoPalavra() {
    String article = 'o'; // Define o artigo padrão como masculino ('o')
    if (widget.inputTitle.isNotEmpty) {
      // Verifica se a palavra não está vazia
      String lastChar = widget.inputTitle[widget.inputTitle.length - 1];
      // Obtém o último caractere da palavra
      if (lastChar.toLowerCase() == 'a') {
        // Se o último caractere for 'a' (minúsculo), o artigo é definido como feminino ('a')
        article = 'a';
      }
    }
    return article;
  }
}
// ===============================================================
// Função DataPicker e Função de formatação para aparecer na Tela

String formatDateToString(DateTime? date) {
  if (date == null) return '';
  return DateFormat('dd/MM/yyyy').format(date);
}

Future<DateTime?> _showDataPickernasc(
    DateTime? _selectedDate, BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(DateTime.now().year - 20),
    lastDate: DateTime.now(),
  );

  return picked;
}
  //===============================================================
