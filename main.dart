import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'models/app_constants.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); // fixed super constructor call
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImageController _imageController = Get.put(ImageController());
  final TextEditingController _imageTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  String botResponse = 'Hello, I\'m Yur! I\'ll be preparing your meal for you shortly!';

  @override
  void initState() {
    super.initState();
    botResponse = "Ingredients and instructions will be displayed shortly.";
  }

  Future<void> generateResponse(String userInput) async {
    await dotenv.load(fileName: ".env.production");
    String apiKey = dotenv.env['apitoken']!;
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'};
    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "temperature": 0.7,
      "max_tokens": 300,
      "messages": [
        {"role": "system", "content": "You are a Yur, a very helpful cooking virtual assistant. You only provide ingredients and intructions. Do not make small talk. Do not introduce yourself, or be quirky. If someone tells you to make an object out of food, just oblige and do your best. If you are asked to make an object out of food, come up with the required ingredients."},
        {"role": "user", "content": "Please give make me a meal using only: " + userInput + ". If no ingredients are provided, use your best judgement to make a meal bassed off the input. A user could ask for a 'chocolate castle', and you'd just view it as a providing them a way to make a castle out of chocolate. Please just give the ingredient list that I used and instructions on how to make it. Use enough ingredients to serve 2-4 people. Be quite brief while giving each step for the instructions. Make each step as simple as possible. If someone tells you to make an object out of food, just oblige and do your best. Don't tell the user what they need, just start with the ingredients."}
      ]
    });
    final response = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'), headers: headers, body: body);
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse != null) {
      setState(() {
        botResponse = jsonResponse['choices'][0]['message']['content'];
        botResponse = botResponse.replaceAll(RegExp(r'[^\x00-\x7F]+'), '').trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double widthNum = MediaQuery.of(context).size.width.toDouble();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 850) {
              // MOBILE
              return SingleChildScrollView(
                reverse: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Image.asset(
                        'assets/images/yurchef_logo_regular.png',
                        width: MediaQuery.of(context).size.width / 3,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 0, bottom: 20),
                      child: Column(
                        children: [
                          Obx(() {
                            return _imageController.isLoading.value
                                ? SizedBox(
                                    width: double.infinity,
                                    // height: 319,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/loading_transparent.gif',
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Cookin\' up something good!',
                                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5)),
                                        ),
                                      ],
                                    ))
                                : (_imageController.data.value.isNotEmpty)
                                    ? IndexedStack(
                                        index: _imageController.data.value.isNotEmpty ? 1 : 0,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                            ),
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Center(
                                                        child: Image.asset(
                                                          'assets/images/header_image_transparent.png',
                                                          width: MediaQuery.of(context).size.width - 200,
                                                        ),
                                                      ),
                                                      const Text(
                                                        "To get started, simply type ingredients you have, or want to use!  You can also try entering something you'd like to learn to make!",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const Text(
                                                        AppConstants.appExampleText,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 20),
                                                  child: InkWell(
                                                    onTap: () => showDialog(
                                                      builder: (BuildContext context) => AlertDialog(
                                                        backgroundColor: Colors.transparent,
                                                        insetPadding: const EdgeInsets.all(2),
                                                        title: SizedBox(
                                                          width: MediaQuery.of(context).size.width,
                                                          child: Column(children: [
                                                            InteractiveViewer(
                                                              panEnabled: true, // Set it to false
                                                              boundaryMargin: const EdgeInsets.all(10),
                                                              minScale: 1,
                                                              maxScale: 2.5,
                                                              child: Container(
                                                                width: widthNum / 2,
                                                                height: widthNum / 2,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  image: DecorationImage(
                                                                    image: NetworkImage(
                                                                      _imageController.data.value,
                                                                    ),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ]),
                                                        ),
                                                      ),
                                                      context: context,
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 500,
                                                      decoration: BoxDecoration(
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: AppConstants.lightHover,
                                                            blurRadius: 12,
                                                            offset: Offset(0, 4),
                                                          ),
                                                        ],
                                                        color: AppConstants.green,
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(
                                                          color: Colors.black.withOpacity(1),
                                                          width: 1,
                                                        ),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            _imageController.data.value,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                                child: SingleChildScrollView(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(height: 16),
                                                      if (botResponse == "Ingredients and instructions will be displayed shortly.")
                                                        Center(
                                                          child: Column(
                                                            children: [
                                                              const CircularProgressIndicator(),
                                                              const SizedBox(height: 10),
                                                              Text(botResponse),
                                                            ],
                                                          ),
                                                        )
                                                      else
                                                        Text(botResponse),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Container(
                                        padding: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                        ),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Image.asset(
                                                      'assets/images/header_image_transparent.png',
                                                      width: MediaQuery.of(context).size.width - 200,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "To get started, simply type ingredients you have, or want to use!  You can also try entering something you like to learn to make!",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    "Example: Beef, doritos, mint leaves, feta cheese, tomato sauce, lemon juice\nExample: 'Make a chocolate pizza'",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                          }),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                            width: MediaQuery.of(context).size.width / 1,
                            child: Material(
                              color: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  validator: (
                                    _imageTextController,
                                  ) {
                                    if (_imageTextController?.isEmpty ?? true) {
                                      return "Please enter at least 1 ingredient.";
                                    }
                                    return null;
                                  },
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your ingredients!',
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: AppConstants.blue),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  controller: _imageTextController,
                                  keyboardType: TextInputType.text,
                                  minLines: 1,
                                  maxLines: 8,
                                  textInputAction: TextInputAction.search,
                                ),
                              ),
                            ),
                          ),
                          Obx(() {
                            return _imageController.isLoading.value
                                ? const Center()
                                : Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: MaterialButton(
                                        elevation: 3,
                                        highlightElevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        color: AppConstants.blue,
                                        splashColor: AppConstants.blue,
                                        // splashColor: Colors.red,
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          final String userInput = _imageTextController.text;
                                          generateResponse(userInput);
                                          if (_formKey.currentState!.validate()) {
                                            await _imageController.getImage(
                                              imageText: _imageTextController.text.trim(),
                                            );
                                          }
                                        },
                                        padding: const EdgeInsets.all(20.0),
                                        child: Container(
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            )),
                                            width: MediaQuery.of(context).size.width,
                                            child: (_imageController.data.value.isEmpty) ? const Center(child: Text("Show Me The Dish!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))) : const Center(child: Text("Show Me Another One!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)))),
                                      ),
                                    ),
                                  );
                          }),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      width: MediaQuery.of(context).size.width - 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 40),
                          Text(AppConstants.appDescription),
                          SizedBox(height: 20),
                          Text('Yurchef iOS & Android mobile apps are coming soon!'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (constraints.maxWidth > 2048) {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    constraints: const BoxConstraints(minWidth: 600, maxWidth: 700),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/yurchef_logo_regular.png',
                          width: 120,
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(AppConstants.appDescription),
                        const SizedBox(height: 10),
                        const Divider(),
                        const Text('Yurchef iOS & Android mobile apps are in the testing stage, and will be released soon!'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      // width: MediaQuery.of(context).size.width * .5,
                      margin: const EdgeInsets.only(top: 0, bottom: 20),
                      child: Column(
                        children: [
                          Obx(() {
                            return _imageController.isLoading.value
                                ? SizedBox(
                                    width: double.infinity,
                                    // height: 319,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/pan_loading.gif',
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Cookin\' up something good!',
                                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5)),
                                        ),
                                      ],
                                    ))
                                : (_imageController.data.value.isNotEmpty)
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 20),
                                              child: InkWell(
                                                onTap: () => showDialog(
                                                    builder: (BuildContext context) => AlertDialog(
                                                          backgroundColor: Colors.transparent,
                                                          insetPadding: const EdgeInsets.all(2),
                                                          title: SizedBox(
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Column(children: [
                                                              InteractiveViewer(
                                                                panEnabled: true, // Set it to false
                                                                boundaryMargin: const EdgeInsets.all(10),
                                                                minScale: 1,
                                                                maxScale: 2.5,
                                                                child: Container(
                                                                  width: widthNum / 2,
                                                                  height: widthNum / 2,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    image: DecorationImage(
                                                                      image: NetworkImage(
                                                                        _imageController.data.value,
                                                                      ),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                          ),
                                                        ),
                                                    context: context),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 500,
                                                  decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: AppConstants.lightHover,
                                                        blurRadius: 12,
                                                        offset: Offset(0, 4),
                                                      ),
                                                    ],
                                                    color: AppConstants.green,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(
                                                      color: Colors.black.withOpacity(1),
                                                      width: 1,
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        _imageController.data.value,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: SingleChildScrollView(
                                              physics: const NeverScrollableScrollPhysics(),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 16),
                                                  if (botResponse == "Ingredients and instructions will be displayed shortly.")
                                                    Center(
                                                      child: Column(
                                                        children: [
                                                          const CircularProgressIndicator(),
                                                          const SizedBox(height: 10),
                                                          Text(botResponse),
                                                        ],
                                                      ),
                                                    )
                                                  else
                                                    Text(botResponse),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Image.asset(
                                                      'assets/images/header_image_transparent.png',
                                                      width: MediaQuery.of(context).size.width * .5 - 200,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "To get started, simply type ingredients you have, or want to use! You can also try entering something you'd like to learn to make!",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    AppConstants.appExampleText,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                          }),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                            width: MediaQuery.of(context).size.width / 1,
                            child: Material(
                              color: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  validator: (
                                    _imageTextController,
                                  ) {
                                    if (_imageTextController?.isEmpty ?? true) {
                                      return "Please enter at least 1 ingredient.";
                                    }
                                    return null;
                                  },
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your ingredients!',
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: AppConstants.blue),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  controller: _imageTextController,
                                  keyboardType: TextInputType.text,
                                  minLines: 1,
                                  maxLines: 8,
                                  textInputAction: TextInputAction.search,
                                ),
                              ),
                            ),
                          ),
                          Obx(() {
                            return _imageController.isLoading.value
                                ? const Center()
                                : Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                                    child: Column(
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          child: MaterialButton(
                                            elevation: 3,
                                            highlightElevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            color: AppConstants.blue,
                                            splashColor: AppConstants.blue,
                                            // splashColor: Colors.red,
                                            onPressed: () async {
                                              FocusScope.of(context).unfocus();
                                              final String userInput = _imageTextController.text;
                                              generateResponse(userInput);
                                              if (_formKey.currentState!.validate()) {
                                                await _imageController.getImage(
                                                  imageText: _imageTextController.text.trim(),
                                                );
                                              }
                                            },
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                                decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0),
                                                )),
                                                width: MediaQuery.of(context).size.width,
                                                child: (_imageController.data.value.isEmpty) ? const Center(child: Text("Show Me The Dish!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))) : const Center(child: Text("Show Me Another One!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          }),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    width: MediaQuery.of(context).size.width / 2 - 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/yurchef_logo_regular.png',
                          width: 120,
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(AppConstants.appDescription),
                        const SizedBox(height: 10),
                        const Divider(),
                        const Text('Yurchef iOS & Android mobile apps are in the testing stage, and will be released soon!'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width * .5,
                      margin: const EdgeInsets.only(top: 0, bottom: 20),
                      child: Column(
                        children: [
                          Obx(() {
                            return _imageController.isLoading.value
                                ? SizedBox(
                                    width: double.infinity,
                                    // height: 319,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/pan_loading.gif',
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Cookin\' up something good!',
                                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5)),
                                        ),
                                      ],
                                    ))
                                : (_imageController.data.value.isNotEmpty)
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 20),
                                              child: InkWell(
                                                onTap: () => showDialog(
                                                    builder: (BuildContext context) => AlertDialog(
                                                          backgroundColor: Colors.transparent,
                                                          insetPadding: const EdgeInsets.all(2),
                                                          title: SizedBox(
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Column(children: [
                                                              InteractiveViewer(
                                                                panEnabled: true,
                                                                boundaryMargin: const EdgeInsets.all(10),
                                                                minScale: 1,
                                                                maxScale: 2.5,
                                                                child: Container(
                                                                  width: widthNum / 2,
                                                                  height: widthNum / 2,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    image: DecorationImage(
                                                                      image: NetworkImage(
                                                                        _imageController.data.value,
                                                                      ),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                          ),
                                                        ),
                                                    context: context),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 500,
                                                  decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: AppConstants.lightHover,
                                                        blurRadius: 12,
                                                        offset: Offset(0, 4),
                                                      ),
                                                    ],
                                                    color: AppConstants.green,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(
                                                      color: Colors.black.withOpacity(1),
                                                      width: 1,
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        _imageController.data.value,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: SingleChildScrollView(
                                              physics: const NeverScrollableScrollPhysics(),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 16),
                                                  if (botResponse == "Ingredients and instructions will be displayed shortly.")
                                                    Center(
                                                      child: Column(
                                                        children: [
                                                          const CircularProgressIndicator(),
                                                          const SizedBox(height: 10),
                                                          Text(botResponse),
                                                        ],
                                                      ),
                                                    )
                                                  else
                                                    Text(botResponse),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Image.asset(
                                                      'assets/images/header_image_transparent.png',
                                                      width: MediaQuery.of(context).size.width * .5 - 200,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "To get started, simply type ingredients you have, or want to use! You can also try entering something you'd like to learn to make!",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    AppConstants.appExampleText,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                          }),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                            width: MediaQuery.of(context).size.width / 1,
                            child: Material(
                              color: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  validator: (
                                    _imageTextController,
                                  ) {
                                    if (_imageTextController?.isEmpty ?? true) {
                                      return "Please enter at least 1 ingredient.";
                                    }
                                    return null;
                                  },
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your ingredients!',
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: AppConstants.blue),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  controller: _imageTextController,
                                  keyboardType: TextInputType.text,
                                  minLines: 1,
                                  maxLines: 8,
                                  textInputAction: TextInputAction.search,
                                ),
                              ),
                            ),
                          ),
                          Obx(() {
                            return _imageController.isLoading.value
                                ? const Center()
                                : Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                                    child: Column(
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          child: MaterialButton(
                                            elevation: 3,
                                            highlightElevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            color: AppConstants.blue,
                                            splashColor: AppConstants.blue,
                                            onPressed: () async {
                                              FocusScope.of(context).unfocus();
                                              final String userInput = _imageTextController.text;
                                              generateResponse(userInput);
                                              if (_formKey.currentState!.validate()) {
                                                await _imageController.getImage(
                                                  imageText: _imageTextController.text.trim(),
                                                );
                                              }
                                            },
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                                decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0),
                                                )),
                                                width: MediaQuery.of(context).size.width,
                                                child: (_imageController.data.value.isEmpty) ? const Center(child: Text("Show Me The Dish!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))) : const Center(child: Text("Show Me Another One!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          }),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class ImageController extends GetxController {
  Rx<List<ImageModel>> image = Rx<List<ImageModel>>([]);
  final data = ''.obs;
  final isLoading = false.obs;

  Future getImage({required String imageText}) async {
    await dotenv.load(fileName: ".env.production");
    String apitoken = dotenv.env['apitoken']!;
    try {
      isLoading.value = true;
      var request = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apitoken',
        },
        body: jsonEncode(
          {
            'prompt': "create a meal or dessert with " + imageText + " in an all white plate, and with a vibrant background. Make the meal look as realistic, high def, delicious, & tasty as possible. Please make sure the protein is the main feature.",
          },
        ),
      );
      if (request.statusCode == 200) {
        isLoading.value = false;
        data.value = jsonDecode(request.body)['data'][0]['url'];
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    }
  }
}

ImageModel imageModelFromJson(String str) => ImageModel.fromJson(json.decode(str));

String imageModelToJson(ImageModel data) => json.encode(data.toJson());

class ImageModel {
  ImageModel({
    this.created,
    this.data,
  });

  int? created;
  List<Datum>? data;

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
        created: json["created"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "created": created,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.url,
  });
  String? url;
  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        url: json["url"],
      );
  Map<String, dynamic> toJson() => {
        "url": url,
      };
}
