/// Filters null values from the map.
bool _nullFilter(_, val) => val == null;

/// Pre-selection of the payment method for the customer. Will only work if contact and email are also pre-filled. Possible values:
/// - `CheckoutMethod.card`: Card payments
/// - `CheckoutMethod.netbanking`: Netbanking payments
/// - `CheckoutMethod.wallet`: Wallet payments
/// - `CheckoutMethod.upi`: UPI payments
/// - `CheckoutMethod.emi`: EMI payments
enum CheckoutMethod {
  /// Card payments
  card("card"),

  /// Netbanking payments
  netbanking("netbanking"),

  /// Wallet payments
  wallet("wallet"),

  /// UPI payments
  upi("upi"),

  /// EMI payments
  emi("emi");

  final String value;
  const CheckoutMethod(this.value);

  String toJSON() => value;
}

/// You can prefill the following details at Checkout.
class CheckoutPrefill {
  /// Cardholder's name to be pre-filled if customer is to make card payments on Checkout. For example, Gaurav Kumar.
  final String? name;

  /// Email address of the customer.
  final String? email;

  /// Phone number of the customer. The expected format of the phone number is + {country code}{phone number}. If the country code is not specified, 91 will be used as the default value. This is particularly important while prefilling contact of customers with phone numbers issued outside India.
  final String? contact;

  /// CheckoutMethod to be pre-selected for the customer. Will only work if contact and email are also pre-filled.
  final CheckoutMethod? method;

  /// Creates a new CheckoutPrefill object.
  CheckoutPrefill({this.name, this.email, this.contact, this.method})
      : assert((contact != null && email != null) || method == null, {
          'message':
              'Contact and email are required to pre-select payment method.'
        });

  Map<String, dynamic> toJSON() {
    return {
      'name': name,
      'email': email,
      'contact': contact,
      'method': method?.toJSON(),
    }..removeWhere(_nullFilter);
  }
}

/// Thematic options to modify the appearance of Checkout.
class CheckoutTheme {
  /// Used to display or hide the top bar on the Checkout form. This bar shows the selected payment method, phone number and gives the customer the option to navigate back to the start of the Checkout form.
  /// - `true`: Hide the top bar.
  /// - `false`: Show the top bar.
  final bool hideTopbar;

  /// Enter your brand colour's HEX code to alter the text, payment method icons and CTA (call-to-action) button colour of the Checkout form.
  final String? color;

  /// Enter a HEX code to change the Checkout's backdrop colour.
  final String? backdropColor;

  /// Creates a new CheckoutTheme object.
  CheckoutTheme({
    this.hideTopbar = false,
    this.color,
    this.backdropColor,
  });

  Map<String, dynamic> toJSON() {
    return {
      'hide_topbar': hideTopbar,
      'color': color,
      'backdrop_color': backdropColor,
    }..removeWhere(_nullFilter);
  }
}

/// Options to handle the Checkout modal.
class CheckoutModalOptions {
  /// Indicates whether clicking the translucent blank space outside the Checkout form should close the form.
  /// - `true`: Closes the form when your customer clicks outside the checkout form..
  /// - `false`: (default) Does not close the form when customer clicks outside the checkout form.
  final bool backdropclose;

  /// Indicates whether pressing the escape key should close the Checkout form.
  /// - `true`: (default) Closes the form when your customer presses the escape key.
  /// - `false`: Does not close the form when customer presses the escape key.
  final bool escape;

  /// Determines whether Checkout must behave similar to the browser when back button is pressed.
  /// - `true`: (default) Checkout behaves similarly to the browser. That is, when the browser's back button is pressed, the Checkout also simulates a back press. This happens as long as the Checkout modal is open.
  /// - `false`:  Checkout does not simulate a back press when browser's back button is pressed
  final bool handleback;

  /// Determines whether a confirmation dialog box should be shown when customers attempt to close Checkout
  /// - `true`: Confirmation dialog box is shown.
  /// - `false`: (default) Confirmation dialog box is not shown.
  final bool confirmClose;

  /// Used to track the status of Checkout. You can pass a modal object with ondismiss: function(){} as options. This function is called when the modal is closed by the user
  final Function()? onDismiss;

  /// Show an animation before loading of Checkout
  /// - `true`: (default) Animation appears.
  /// - `false`: Animation does not appear.
  final bool animation;

  /// Creates a new CheckoutModalOptions object.
  CheckoutModalOptions({
    this.backdropclose = false,
    this.escape = true,
    this.handleback = true,
    this.confirmClose = false,
    this.onDismiss,
    this.animation = true,
  });

  Map<String, dynamic> toJSON() {
    return {
      'backdropclose': backdropclose,
      'escape': escape,
      'handleback': handleback,
      'confirm_close': confirmClose,
      'ondismiss': onDismiss,
      'animation': animation,
    }..removeWhere(_nullFilter);
  }
}

/// Marks fields as read-only.
class CheckoutReadonly {
  /// Used to set the contact field as readonly
  /// - `true`: Customer will not be able to edit this field
  /// - `false`: (default) Customer will be able to edit this field
  final bool contact;

  /// Used to set the email field as readonly
  /// - `true`: Customer will not be able to edit this field
  /// - `false`: (default) Customer will be able to edit this field
  final bool email;

  /// Used to set the name field as readonly
  /// - `true`: Customer will not be able to edit this field
  /// - `false`: (default) Customer will be able to edit this field
  final bool name;

  /// Creates a new CheckoutReadonly object.
  CheckoutReadonly({
    this.contact = false,
    this.email = false,
    this.name = false,
  });

  Map<String, dynamic> toJSON() {
    return {
      'contact': contact,
      'email': email,
      'name': name,
    };
  }
}

/// Hides the contact details
class CheckoutHiddenFields {
  /// Used to set the contact field as optional
  /// - `true`: Customer will not be able to view this field
  /// - `false`: (default) Customer will be able to see this field
  final bool contact;

  /// Used to set the email field as optional
  /// - `true`: Customer will not be able to view this field
  /// - `false`: (default) Customer will be able to see this field
  final bool email;

  /// Creates a new CheckoutHiddenFields object.
  CheckoutHiddenFields({
    this.contact = false,
    this.email = false,
  });

  Map<String, dynamic> toJSON() {
    return {
      'contact': contact,
      'email': email,
    };
  }
}

/// Parameters that enable retry of payment on the checkout.
class CheckoutRetry {
  /// Determines whether the customers can retry payments on the checkout
  /// - `true`: (default) Enables customers to retry payments.
  /// - `false`: Disables customers from retrying payments.
  final bool enabled;

  /// The number of times the customer can retry the payment. Recommended to set this to 4. Having a larger number here can cause loops to occur
  ///
  /// ⚠️ **NOTE**: Web Integration does not support the max_count parameter. It is applicable only in Android and iOS SDKs
  final int maxCount;

  /// Creates a new CheckoutRetry object.
  CheckoutRetry({
    this.enabled = true,
    this.maxCount = 4,
  });

  Map<String, dynamic> toJSON() {
    return {
      'enabled': enabled,
      'max_count': maxCount,
    };
  }
}

/// Parameters that enable configuration of checkout display language.
class CheckoutConfig {
  /// Child parameter that enables configuration of checkout display language.
  final Map<String, String> display;

  /// Creates a new CheckoutConfig object.
  CheckoutConfig({
    required this.display,
  });

  Map<String, dynamic> toJSON() {
    return {
      'display': display,
    };
  }
}

/// Checkout External object
class CheckoutExternal {
  /// Child parameter that enables configuration of checkout display language.
  final List<String> wallets;

  /// Creates a new CheckoutExternal object.
  CheckoutExternal({
    required this.wallets,
  });

  Map<String, dynamic> toJSON() {
    return {
      'wallets': wallets,
    };
  }
}

class CheckoutOptions {
  /// API Key ID generated from the Razorpay Dashboard.
  final String key;

  /// The amount to be paid by the customer in currency subunits. For example, if the amount is ₹500.00, enter 50000
  final int amount;

  /// The currency in which the payment should be made by the customer. See the list of [supported currencies](https://razorpay.com/docs/payments/payments/international-payments/#supported-currencies)
  final String currency;

  /// The business name shown on the Checkout form. For example, Acme Corp.
  final String name;

  /// Optional. Description of the purchase item shown on the Checkout form. It should start with an alphanumeric character.
  final String? description;

  /// Link to an image (usually your business logo) shown on the Checkout form. Can also be a `base64` string if you are not loading the image from a network.
  final String? image;

  /// Order ID generated via [Orders API](https://razorpay.com/docs/api/orders)
  final String orderId;

  /// Optional. Pre-filled customer details. See [CheckoutPrefill]
  final CheckoutPrefill? prefill;

  /// Optional. Set of key-value pairs that can be used to store additional information about the payment. It can hold a maximum of 15 key-value pairs, each 256 characters long (maximum)
  final Map<String, dynamic>? notes;

  /// Thematic options to modify the appearance of Checkout. See [CheckoutTheme]
  final CheckoutTheme? theme;

  /// Options to handle the Checkout modal.
  final CheckoutModalOptions? modal;

  /// If you are accepting recurring payments using Razorpay Checkout, you should pass the relevant subscription_id to the Checkout. Know more about [Subscriptions on Checkout](https://razorpay.com/docs/api/payments/subscriptions/#checkout-integration)
  final String? subscriptionId;

  /// Permit or restrict customer from changing the card linked to the subscription. You can also do this from the [hosted page](https://razorpay.com/docs/payments/subscriptions/payment-retries/#update-the-payment-method-via-our-hosted-page)
  /// - `true`: Allow the customer to change the card from Checkout
  /// - `false`: (default) Do not allow the customer to change the card from Checkout
  final bool subscriptionCardChange;

  /// Determines if you are accepting [recurring (charge-at-will) payments on Checkout](https://razorpay.com/docs/api/payments/recurring-payments/) via instruments such as emandate, paper NACH and so on.
  /// - `true`: You are accepting recurring payments.
  /// - `false`: (default): You are not accepting recurring payments.
  final bool recurring;

  /// Customers will be redirected to this URL on successful payment. Ensure that the domain of the Callback URL is whitelisted.
  final String? callbackURL;

  /// Determines whether to post a response to the event handler post payment completion or redirect to Callback URL. callback_url must be passed while using this parameter
  /// - `true`: Customer is redirected to the specified callback URL in case of payment failure
  /// - `false`: (default): Customer is shown the Checkout popup to retry the payment
  final bool redirect;

  /// Unique identifier of customer. Used for:
  /// - [Local saved card feature](https://razorpay.com/docs/payments/dashboard/account-settings/configuration/#manage-saved-cards)
  /// - Static bank account details on Checkout in case of [Bank Transfer payment method](https://razorpay.com/docs/payments/payment-methods/bank-transfer/).
  final String? customerId;

  /// Determines whether to allow saving of cards. Can also be configured via the [Dashboard](https://razorpay.com/docs/payments/dashboard/account-settings/configuration/#enable-flash-checkout).
  /// - `true`: Enables card saving feature
  /// - `false`: (default) Disables card saving feature
  final bool rememberCustomer;

  /// Sets a timeout on Checkout, in seconds. After the specified time limit, the customer will not be able to use Checkout.
  final int? timeout;

  /// Marks fields as read-only. See [CheckoutReadonly]
  final CheckoutReadonly? readonly;

  /// Hides the contact details. See [CheckoutHiddenFields]
  final CheckoutHiddenFields? hidden;

  /// Used to auto-read OTP for cards and net banking pages. Applicable from Android SDK version 1.5.9 and above
  /// - `true`: Enables auto-read OTP
  /// - `false`: (default) Disables auto-read OTP
  final bool sendSmsHash;

  /// Used to rotate payment page as per screen orientation. Applicable from Android SDK version 1.6.4 and above
  /// - `true`: Enables auto-rotate
  /// - `false`: (default) Disables auto-rotate
  final bool allowRotation;

  /// Parameters that enable retry of payment on the checkout. See [CheckoutRetry]
  final CheckoutRetry? retry;

  /// Parameters that enable configuration of checkout display language. See [CheckoutConfig]
  final CheckoutConfig? config;

  /// Checkout External object
  final CheckoutExternal? external;

  /// Creates a new CheckoutOptions object.
  CheckoutOptions({
    required this.key,
    required this.amount,
    required this.currency,
    required this.name,
    this.description,
    this.image,
    required this.orderId,
    this.prefill,
    this.notes,
    this.theme,
    this.modal,
    this.subscriptionId,
    this.subscriptionCardChange = false,
    this.recurring = false,
    this.callbackURL,
    this.redirect = false,
    this.customerId,
    this.rememberCustomer = false,
    this.timeout,
    this.readonly,
    this.hidden,
    this.sendSmsHash = false,
    this.allowRotation = false,
    this.retry,
    this.config,
    this.external,
  });

  Map<String, dynamic> toJSON() {
    return {
      'key': key,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': description,
      'image': image,
      'order_id': orderId,
      'prefill': prefill?.toJSON(),
      'notes': notes,
      'theme': theme?.toJSON(),
      'modal': modal?.toJSON(),
      'subscription_id': subscriptionId,
      'subscription_card_change': subscriptionCardChange,
      'recurring': recurring,
      'callback_url': callbackURL,
      'redirect': redirect,
      'customer_id': customerId,
      'remember_customer': rememberCustomer,
      'timeout': timeout,
      'readonly': readonly?.toJSON(),
      'hidden': hidden?.toJSON(),
      'send_sms_hash': sendSmsHash,
      'allow_rotation': allowRotation,
      'retry': retry?.toJSON(),
      'config': config?.toJSON(),
      'external': external?.toJSON(),
    }..removeWhere(_nullFilter);
  }
}
