part of 'package:maid/main.dart';

class PromptField extends StatefulWidget {
  const PromptField({
    super.key, 
  });

  @override
  State<PromptField> createState() => PromptFieldState();
}

class PromptFieldState extends State<PromptField> {
  final TextEditingController controller = TextEditingController();
  StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      // For sharing or opening text coming from outside the app while the app is in the memory
      streamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen((value) {
        setState(() {
          controller.text = value.first.path;
        });
      }, onError: (err) {
        log(err.toString());
      });

      // For sharing or opening text coming from outside the app while the app is closed
      ReceiveSharingIntent.instance.getInitialMedia().then((value) {
        if (value.isNotEmpty) {
          setState(() {
            controller.text = value.first.path;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  /// This is the onPressed function that will be used to submit the message.
  /// It will call the onPrompt function with the text from the controller.
  /// It will also clear the controller after the message is submitted.
  void onSubmit() async {
    try {
      final prompt = controller.text;
      controller.clear();
      await ArtificialIntelligence.of(context).prompt(prompt);
    }
    catch (exception) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: exception),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildPromptField(),
    )
  );

  /// This is the prompt field that will be used to type a message.
  Widget buildPromptField() => TextField(
    keyboardType: TextInputType.multiline,
    minLines: 1,
    maxLines: 9,
    enableInteractiveSelection: true,
    controller: controller,
    decoration: buildInputDecoration(),
  );

  /// This is the input decoration for the prompt field. 
  /// It will have a hint text and a submit button at the end of the field.
  InputDecoration buildInputDecoration() => InputDecoration(
    hintText: 'Type a message...',
    suffixIcon: suffixButtonBuilder()
  );

  /// This is the submit button that will be used to submit the message.
  Widget suffixButtonBuilder() => Selector<ArtificialIntelligence, bool>(
    selector: (context, ai) => ai.busy,
    builder: (context, busy, child) => busy ? 
      buildStopButton() : 
      buildSubmitButton(),
  );

  Widget buildSubmitButton() => Selector<ArtificialIntelligence, bool>(
    selector: (context, ai) => ai.canPrompt,
    builder: (context, canPrompt, child) => IconButton(
      icon: const Icon(Icons.send),
      onPressed: canPrompt ? onSubmit : null,
      disabledColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
    ),
  );

  /// This is the stop button that will be used to stop the message.
  Widget buildStopButton() => IconButton(
    icon: Icon(
      Icons.stop_circle_sharp,
      color: Theme.of(context).colorScheme.onError,
    ),
    iconSize: 30,
    onPressed: ArtificialIntelligence.of(context).stop,
  );
}