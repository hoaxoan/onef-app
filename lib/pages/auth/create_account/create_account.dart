import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:onef/pages/auth/create_account/blocs/create_account.dart';
import 'package:onef/pages/auth/create_account/widgets/auth_text_field.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/validation.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/buttons/secondary_button.dart';
import 'package:onef/widgets/buttons/success_button.dart';

class OFAuthCreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OFAuthCreateAccountPageState();
  }
}

class OFAuthCreateAccountPageState extends State<OFAuthCreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreateAccountBloc _createAccountBloc;
  LocalizationService _localizationService;
  ValidationService _validationService;
  ToastService _toastService;

  TextEditingController _linkController = TextEditingController();

  bool _tokenIsInvalid;
  bool _tokenValidationInProgress;

  CancelableOperation _tokenValidationOperation;

  @override
  void initState() {
    super.initState();
    _tokenIsInvalid = false;
    _tokenValidationInProgress = false;
    _linkController.addListener(_onLinkChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _linkController.removeListener(_onLinkChanged);
    _tokenValidationOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _localizationService = provider.localizationService;
    _validationService = provider.validationService;
    _createAccountBloc = provider.createAccountBloc;
    _toastService = provider.toastService;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildPasteRegisterLink(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildLinkForm(),
                    const SizedBox(height: 20.0),
                    _buildRequestInvite(context: context)
                  ],
                ))),
      ),
      backgroundColor: Colors.indigoAccent,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: 20.0 + MediaQuery.of(context).viewInsets.bottom,
              top: 20.0,
              left: 20.0,
              right: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: _buildPreviousButton(context: context),
              ),
              Expanded(child: _buildNextButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _validateForm() async {
    if (_formKey.currentState.validate()) {
      bool tokenIsValid = await _validateToken();
      if (!tokenIsValid) _setTokenIsInvalid(true);
      return tokenIsValid;
    }
    return false;
  }

  void onPressedNextStep(BuildContext context) async {
    bool isFormValid = await _validateForm();

    if (isFormValid) {
      setState(() {
        var token = _getTokenFromLink(_linkController.text.trim());
        _createAccountBloc.setToken(token);
        Navigator.pushNamed(context, '/auth/get-started');
      });
    }
  }

  String _getTokenFromLink(String link) {
    final uri = Uri.decodeFull(link);
    final params = Uri.parse(uri).queryParametersAll;
    var token = '';
    if (params.containsKey('token')) {
      token = params['token'][0];
    } else {
      token = uri.split('?token=')[1];
    }
    return token;
  }

  Widget _buildNextButton(BuildContext context) {
    String buttonText = _localizationService.trans('auth__create_acc__next');

    return OFSuccessButton(
      minWidth: double.infinity,
      size: OFButtonSize.large,
      isLoading: _tokenValidationInProgress,
      child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
      onPressed: () {
        onPressedNextStep(context);
      },
    );
  }

  Widget _buildPreviousButton({@required BuildContext context}) {
    String buttonText =
        _localizationService.trans('auth__create_acc__previous');

    return OFSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildPasteRegisterLink({@required BuildContext context}) {
    String pasteLinkText =
        _localizationService.trans('auth__create_acc__paste_link');

    return Column(
      children: <Widget>[
        Text(
          '🔗',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(pasteLinkText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildLinkForm() {
    return Form(
      key: _formKey,
      child: Row(children: <Widget>[
        new Expanded(
          child: Container(
              color: Colors.transparent,
              child: OFAuthTextField(
                autocorrect: false,
                hintText: '',
                validator: (String link) {
                  String validateLink = _validationService
                      .validateUserRegistrationLink(link.trim());
                  if (validateLink != null) {
                    return validateLink;
                  }

                  if (_tokenIsInvalid) {
                    return _localizationService.auth__create_acc__invalid_token;
                  }

                  return null;
                },
                controller: _linkController,
              )),
        ),
      ]),
    );
  }

  Widget _buildRequestInvite({@required BuildContext context}) {
    String requestInviteText =
        _localizationService.trans('auth__create_acc__request_invite');

    return OFSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            requestInviteText,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/waitlist/subscribe_email_step');
      },
    );
  }

  _validateToken() async {
    _setTokenValidationInProgress(true);
    String token = _getTokenFromLink(_linkController.text.trim());
    debugPrint('Validating token ${token}');

    try {
      final isTokenValid = await _validationService.isInviteTokenValid(token);
      debugPrint('Token was valid:  ${isTokenValid}');
      return isTokenValid;
    } catch (error) {
      _onError(error);
    } finally {
      _setTokenValidationInProgress(false);
    }
  }

  _onLinkChanged() {
    if (_tokenIsInvalid) _setTokenIsInvalid(false);
  }

  _setTokenIsInvalid(bool tokenIsInvalid) {
    setState(() {
      _tokenIsInvalid = tokenIsInvalid;
      _formKey.currentState.validate();
    });
  }

  _setTokenValidationInProgress(bool tokenValidationInProgress) {
    setState(() {
      _tokenValidationInProgress = tokenValidationInProgress;
    });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }
}
