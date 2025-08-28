// lib/helpers/Strings.dart

import 'LanguageManager.dart';

class Strings {
  static String get menu => _byLang('Menu', 'Menü', 'Menu', 'Menu');
  static String get myOrders => _byLang('My Orders', 'Siparişlerim', 'Mes Commandes', 'Mijn Bestellingen');
  static String get pickup => _byLang('Pickup', 'Gel-Al', 'Retrait', 'Afhalen');
  static String get delivery => _byLang('Delivery', 'Teslimat', 'Livraison', 'Bezorging');
  static String get chooseDeliveryType => _byLang('Choose Delivery Type', 'Teslimat Tipi Seçin', 'Choisir le mode de livraison', 'Kies leveringsmethode');
  static String get cancel => _byLang('Cancel', 'İptal', 'Annuler', 'Annuleer');
  static String get confirm => _byLang('Confirm', 'Tamam', 'Confirmer', 'Bevestigen');
  static String get minAmount => _byLang('Min', 'Min', 'Min', 'Min'); // Tüm dillerde kısa olduğu için sabit kalabilir
  static String get choosePickupAddress => _byLang('Select Pickup Address', 'Gel-Al Adresi Seçin', 'Sélectionnez l\'adresse de retrait', 'Kies afhaaladres');
  static String get address => _byLang('Address', 'Adres', 'Adresse', 'Adres');
  static String get pickupRequired => _byLang('Please select a pickup address', 'Lütfen bir Gel-Al adresi seçin', 'Veuillez sélectionner une adresse de retrait', 'Selecteer een afhaaladres');
  static String get update => _byLang('Update', 'Güncelle', 'Mettre à jour', 'Bijwerken');
  // --- Login Screen Additions ---
  static String get welcomeBack => _byLang('Welcome Back!', 'Tekrar Hoş Geldiniz!', 'Bienvenue de retour !', 'Welkom terug!');
  static String get signInToYourAccount => _byLang('Sign in to your account', 'Hesabınıza giriş yapın', 'Connectez-vous à votre compte', 'Meld u aan bij uw account');
  static String get emailAddressHint => _byLang('Email Address', 'E-posta Adresi', 'Adresse e-mail', 'E-mailadres');
  static String get passwordHint => _byLang('Password', 'Şifre', 'Mot de passe', 'Wachtwoord');
  static String get rememberMe => _byLang('Remember Me', 'Beni Hatırla', 'Se souvenir de moi', 'Onthoud mij');
  static String get forgotPassword => _byLang('Forgot Password?', 'Şifremi Unuttum?', 'Mot de passe oublié ?', 'Wachtwoord vergeten?');
  static String get loginButton => _byLang('Login', 'Giriş Yap', 'Se connecter', 'Inloggen');
  static String get loginFailed => _byLang('Login Failed!', 'Giriş Başarısız!', 'Échec de la connexion !', 'Inloggen mislukt!');
  static String get guestLoginButton => _byLang('Continue as Guest', 'Misafir Olarak Devam Et', 'Continuer en tant qu\'invité', 'Doorgaan als gast');
  static String get dontHaveAnAccount => _byLang('Don\'t have an account?', 'Hesabın yok mu?', 'Vous n\'avez pas de compte ?', 'Heb je geen account?');
  static String get signUpButton => _byLang('Sign Up', 'Kaydol', 'S\'inscrire', 'Aanmelden');
  // ------------------------------


  static String get myInvoice => _byLang('My Invoice', 'Faturalarım', 'Ma Facture', 'Mijn Factuur');
  static String get logout => _byLang('Logout', 'Çıkış Yap', 'Se Déconnecter', 'Afmelden');
  static String get logoutConfirm => _byLang('Are you sure you want to logout?', 'Çıkış yapmak istediğinizden emin misiniz?', 'Êtes-vous sûr de vouloir vous déconnecter ?', 'Weet u zeker dat u wilt uitloggen?');

  static String get noOrdersFound => _byLang('No orders found', 'Sipariş bulunamadı', 'Aucune commande trouvée', 'Geen bestellingen gevonden');
  static String get repeat => _byLang('Repeat', 'Tekrarla', 'Répéter', 'Herhalen');
  static String get orderPlaced => _byLang('Order placed', 'Sipariş verildi', 'Commande passée', 'Bestelling geplaatst');
  static String get orderConfirmed => _byLang('Order confirmed', 'Sipariş onaylandı', 'Commande confirmée', 'Bestelling bevestigd');
  static String get orderCompleted => _byLang('Order completed', 'Sipariş tamamlandı', 'Commande terminée', 'Bestelling voltooid');
  static String get invoiced => _byLang('Invoiced', 'Faturalandı', 'Facturé', 'Gefactureerd');

  // ... diğer strings

  static String get deleteAccount => _byLang(
      'Delete Account',
      'Hesabımı Sil',
      'Supprimer le compte',
      'Account verwijderen'
  );

  static String get deleteAccountConfirm => _byLang(
      'Are you sure you want to delete your account? This action cannot be undone.',
      'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
      'Weet u zeker dat u uw account wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.'
  );

  static String get deleteAccountSuccess => _byLang(
      'Account deleted successfully.',
      'Hesabınız başarıyla silindi.',
      'Compte supprimé avec succès.',
      'Account succesvol verwijderd.'
  );

  static String get deleteAccountFailed => _byLang(
      'Failed to delete account. Please try again.',
      'Hesap silme başarısız oldu. Lütfen tekrar deneyin.',
      'Échec de la suppression du compte. Veuillez réessayer.',
      'Het verwijderen van het account is mislukt. Probeer het opnieuw.'
  );
/*  static String get loginFailed => _byLang(
      'Login failed! Please check your credentials.',
      'Giriş başarısız! Lütfen bilgilerinizi kontrol edin.',
      'Échec de la connexion ! Veuillez vérifier vos identifiants.',
      'Inloggen mislukt! Controleer uw gegevens.'
  );*/
/*
  static String get welcomeBack => _byLang(
      'Welcome back!',
      'Tekrar hoş geldiniz!',
      'Bon retour !',
      'Welkom terug!'
  );

  static String get signInToYourAccount => _byLang(
      'Sign in to your account',
      'Hesabınıza giriş yapın',
      'Connectez-vous à votre compte',
      'Log in op uw account'
  );

  static String get emailAddressHint => _byLang(
      'Email Address',
      'E-posta Adresi',
      'Adresse e-mail',
      'E-mailadres'
  );

  static String get passwordHint => _byLang(
      'Password',
      'Şifre',
      'Mot de passe',
      'Wachtwoord'
  );

  static String get rememberMe => _byLang(
      'Remember me',
      'Beni hatırla',
      'Se souvenir de moi',
      'Onthoud mij'
  );

  static String get forgotPassword => _byLang(
      'Forgot password',
      'Şifremi unuttum',
      'Mot de passe oublié',
      'Wachtwoord vergeten'
  );

  static String get loginButton => _byLang(
      'Login',
      'Giriş Yap',
      'Connexion',
      'Inloggen'
  );*/

  static String get categoriesTitle => _byLang(
      'Categories',
      'Kategoriler',
      'Catégories',
      'Categorieën'
  );

  static String get noCategoriesFound => _byLang(
      'No categories found',
      'Kategori bulunamadı',
      'Aucune catégorie trouvée',
      'Geen categorieën gevonden'
  );

  static String get generalError => _byLang(
      'Error',
      'Hata',
      'Erreur',
      'Fout'
  );

  static String get categoryProductsTitle => _byLang(
      'Category Products',
      'Kategori Ürünleri',
      'Produits par catégorie',
      'Producten per categorie'
  );

  static String get searchProductsHint => _byLang(
      'Search products...',
      'Ürün ara...',
      'Rechercher des produits...',
      'Producten zoeken...'
  );

  static String get productsError => _byLang(
      'Error',
      'Hata',
      'Erreur',
      'Fout'
  );

  static String get noProductsFound => _byLang(
      'No products found',
      'Ürün bulunamadı',
      'Aucun produit trouvé',
      'Geen producten gevonden'
  );
  static String get cartDataError => _byLang(
      'Failed to get cart data.',
      'Sepet verisi alınamadı.',
      'Échec de la récupération des données du panier.',
      'Kan winkelwagengegevens niet ophalen.'
  );

  static String get serverError => _byLang(
      'Server error',
      'Sunucu hatası',
      'Erreur serveur',
      'Serverfout'
  );

  static String get checkoutTitle => _byLang(
      'Order Review',
      'Sipariş Kontrolü',
      'Vérification de commande',
      'Bestelling controleren'
  );


  static String get shoppingSummary => _byLang(
      'Shopping Summary',
      'Alışveriş Özeti',
      'Résumé des achats',
      'Winkeloverzicht'
  );

  static String get total => _byLang(
      'Total',
      'Toplam',
      'Total',
      'Totaal'
  );
  static String get orderComplete => _byLang(
      'Order Complete',
      'Siparişi Tamamla',
      'Commande terminée',
      'Bestelling voltooid'
  );
  static String get searchInvoiceLabel => _byLang(
      'Search Invoice',
      'Fatura Ara',
      'Rechercher une facture',
      'Factuur zoeken'
  );

  static String get searchInvoiceHint => _byLang(
      'Enter invoice no',
      'Fatura numarası gir',
      'Entrez le numéro de facture',
      'Voer factuurnummer in'
  );

  static String get noInvoiceFound => _byLang(
      'No invoice found.',
      'Fatura bulunamadı.',
      'Aucune facture trouvée.',
      'Geen factuur gevonden.'
  );

  static String get totalLabel => _byLang(
      'Total',
      'Toplam',
      'Total',
      'Totaal'
  );
  static String get orderSuccess => _byLang(
      'Your order was successful!',
      'Siparişiniz başarıyla oluşturuldu!',
      'Votre commande a été passée avec succès !',
      'Uw bestelling is succesvol geplaatst!'
  );

  static String get orderNumber => _byLang(
      'Order Number',
      'Sipariş Numarası',
      'Numéro de commande',
      'Bestelnummer'
  );

  static String get paymentReminder => _byLang(
      'Please go to checkout\nto make your payment.',
      'Lütfen ödeme yapmak için\nsipariş kontrolüne gidin.',
      'Veuillez passer à la caisse\npour effectuer votre paiement.',
      'Ga naar afrekenen\nom uw betaling te voltooien.'
  );

  static String get backToHome => _byLang(
      'Back To Home',
      'Ana Sayfaya Dön',
      'Retour à l\'accueil',
      'Terug naar home'
  );
  static String get pdfUrlNotAvailable => _byLang(
      'PDF URL is not available',
      'PDF URL mevcut değil',
      'L\'URL du PDF n\'est pas disponible',
      'PDF-URL is niet beschikbaar'
  );

  static String get openPdfTitle => _byLang(
      'Open PDF',
      'PDF Aç',
      'Ouvrir le PDF',
      'PDF openen'
  );

  static String get openInBrowser => _byLang(
      'Open in Browser',
      'Tarayıcıda Aç',
      'Ouvrir dans le navigateur',
      'Openen in browser'
  );

  static String get viewInApp => _byLang(
      'View in App',
      'Uygulamada Görüntüle',
      'Voir dans l\'application',
      'Bekijken in app'
  );

  static String get cancel2 => _byLang(
      'Cancel',
      'İptal',
      'Annuler',
      'Annuleren'
  );

  static String get pdfDownloadStarted => _byLang(
      'Downloading PDF...',
      'PDF indiriliyor...',
      'Téléchargement du PDF...',
      'PDF wordt gedownload...'
  );

  static String get couldNotLaunchUrl => _byLang(
      'Could not launch URL',
      'URL başlatılamadı',
      'Impossible de lancer l\'URL',
      'URL kan niet worden geopend'
  );

  static String get error => _byLang(
      'Error',
      'Hata',
      'Erreur',
      'Fout'
  );

  static String get errorOnPage => _byLang(
      'Error on page',
      'Sayfa hatası',
      'Erreur à la page',
      'Fout op pagina'
  );

  static String get orderPdf => _byLang(
      'Order PDF',
      'Sipariş PDF',
      'PDF de commande',
      'Bestelling PDF'
  );
  static String get pdfViewer => _byLang(
      'PDF Viewer',          // English
      'PDF Görüntüleyici',   // Turkish
      'Visionneuse PDF',     // French
      'PDF Viewer'           // Dutch (veya Almanca'da "PDF-Anzeige" kullanılabilir)
  );
  static String get complete => _byLang(
      'Complete',
      'Tamamlandı',
      'Terminé',
      'Voltooid'
  );

  static String get draft => _byLang(
      'Draft',
      'Taslak',
      'Brouillon',
      'Concept'
  );

  static String get placedOn => _byLang(
      'Placed on',
      'Sipariş Tarihi',
      'Passé le',
      'Geplaatst op'
  );

  static String get repeat2 => _byLang(
      'Repeat',
      'Tekrarla',
      'Répéter',
      'Herhalen'
  );
  static String get productsAddedToCart => _byLang(
      'Products added to your cart, Please go to Cart Page',
      'Ürünler sepetinize eklendi, Lütfen Sepet Sayfasına gidin',
      'Produits ajoutés à votre panier, veuillez aller à la page Panier',
      'Producten toegevoegd aan uw winkelwagen, ga naar de winkelwagenpagina'
  );
  static String get howToViewPdf => _byLang(
      'How would you like to view the PDF?',
      'PDF\'i nasıl görüntülemek istersiniz?',
      'Comment souhaitez-vous voir le PDF ?',
      'Hoe wilt u de PDF bekijken?'
  );
  static String get stock => _byLang(
      'Stock',
      'Stok',
      'Stock',
      'Voorraad'
  );

  static String get quantity => _byLang(
      'Quantity',
      'Miktar',
      'Quantité',
      'Hoeveelheid'
  );

  static String get addToCart => _byLang(
      'Add to cart',
      'Sepete Ekle',
      'Ajouter au panier',
      'In winkelwagen'
  );

  static String get productAdded => _byLang(
      'Product added to cart',
      'Ürün sepete eklendi',
      'Produit ajouté au panier',
      'Product toegevoegd aan winkelwagen'
  );

  static String get productAddingFailed => _byLang(
      'Product adding failed',
      'Ürün ekleme başarısız',
      'Échec de l\'ajout du produit',
      'Product toevoegen mislukt'
  );

  static String get genericError => _byLang(
      'Error',
      'Hata',
      'Erreur',
      'Fout'
  );

  static String get errorFetchingCarousel => _byLang(
      'Error fetching carousel items',
      'Carousel ögeleri alınırken hata oluştu',
      'Erreur lors de la récupération des éléments du carrousel',
      'Fout bij ophalen carrousel-items'
  );

  static String get errorFetchingProducts => _byLang(
      'Error fetching products',
      'Ürünler alınırken hata oluştu',
      'Erreur lors de la récupération des produits',
      'Fout bij ophalen producten'
  );

/*  static String get genericError => _byLang(
      'Error',
      'Hata',
      'Erreur',
      'Fout'
  );*/

  static String get productsTitle => _byLang(
      'Products',
      'Ürünler',
      'Produits',
      'Producten'
  );

  static String get noProductsAvailable => _byLang(
      'No products available',
      'Ürün bulunamadı',
      'Aucun produit disponible',
      'Geen producten beschikbaar'
  );

  static String get carouselFailed => _byLang(
      'Carousel could not be loaded',
      'Carousel yüklenemedi',
      'Impossible de charger le carrousel',
      'Carrousel kon niet worden geladen'
  );

  static String get tryAgain => _byLang(
      'Try Again',
      'Tekrar Dene',
      'Réessayer',
      'Opnieuw proberen'
  );

  static String get noCarouselContent => _byLang(
      'No carousel content found',
      'Carousel içeriği bulunamadı',
      'Aucun contenu de carrousel trouvé',
      'Geen carrousel-inhoud gevonden'
  );

/*  static String get categoriesTitle => _byLang(
      'Categories',
      'Kategoriler',
      'Catégories',
      'Categorieën'
  );*/

  static String get base64DecodeError => _byLang(
      'Base64 decode error',
      'Base64 çözme hatası',
      'Erreur de décodage Base64',
      'Base64-decodefout'
  );

  static String get cartEmpty => _byLang(
      'Your cart is empty!',
      'Sepetiniz boş!',
      'Votre panier est vide !',
      'Uw winkelwagen is leeg!'
  );
  static String get cart => _byLang(
      'Cart',
      'Sepet',
      'Panier',
      'Winkelwagen'
  );

  static String get subtotal => _byLang(
      'Subtotal',
      'Ara Toplam',
      'Sous-total',
      'Subtotaal'
  );

  static String get discount => _byLang(
      'Discount',
      'İndirim',
      'Remise',
      'Korting'
  );

 /* static String get total => _byLang(
      'Total',
      'Toplam',
      'Total',
      'Totaal'
  );*/

  static String get checkout => _byLang(
      'Checkout',
      'Siparişi Onayla',
      'Paiement',
      'Afrekenen'
  );

  static String get productRemovedFromCart => _byLang(
      'Product removed from cart',
      'Ürün sepetten çıkarıldı',
      'Produit retiré du panier',
      'Product verwijderd uit winkelwagen'
  );

  static String get productAddedToCart => _byLang(
      'Product added to cart',
      'Ürün sepete eklendi',
      'Produit ajouté au panier',
      'Product toegevoegd aan winkelwagen'
  );

  static String get failedToAddProduct => _byLang(
      'Failed to add product to cart',
      'Ürün sepete eklenemedi',
      'Échec de l\'ajout du produit au panier',
      'Product toevoegen aan winkelwagen mislukt'
  );

  static String get addCart => _byLang(
      'Add Cart',
      'Sepete Ekle',
      'Ajouter au panier',
      'In winkelwagen'
  );

  // SignUpScreen strings
  static String get createAccount => _byLang(
      'Create Account',
      'Hesap Oluştur',
      'Créer un compte',
      'Account aanmaken'
  );

  static String get signUpToGetStarted => _byLang(
      'Sign up to get started',
      'Başlamak için kaydolun',
      'Inscrivez-vous pour commencer',
      'Meld u aan om te beginnen'
  );



  static String get confirmPasswordHint => _byLang(
      'Confirm Password',
      'Parolayı Onayla',
      'Confirmer le mot de passe',
      'Wachtwoord bevestigen'
  );


  static String get alreadyHaveAnAccount => _byLang(
      'Already have an account?',
      'Zaten bir hesabınız var mı?',
      'Vous avez déjà un compte ?',
      'Heeft u al een account?'
  );

  static String get signUpSuccess => _byLang(
      'Registration successful! Please log in.',
      'Kayıt başarılı! Lütfen giriş yapın.',
      'Inscription réussie ! Veuillez vous connecter.',
      'Registratie succesvol! Log alstublieft in.'
  );

  static String get signUpFailed => _byLang(
      'Registration failed. Please try again.',
      'Kayıt başarısız oldu. Lütfen tekrar deneyin.',
      'Échec de l\'inscription. Veuillez réessayer.',
      'Registratie mislukt. Probeer het opnieuw.'
  );

  static String get emailRequired => _byLang(
      'Please enter an email address.',
      'Lütfen bir e-posta adresi girin.',
      'Veuillez entrer une adresse e-mail.',
      'Voer een e-mailadres in.'
  );

  static String get emailInvalid => _byLang(
      'Please enter a valid email address.',
      'Lütfen geçerli bir e-posta adresi girin.',
      'Veuillez entrer une adresse e-mail valide.',
      'Voer een geldig e-mailadres in.'
  );

  static String get passwordRequired => _byLang(
      'Please enter a password.',
      'Lütfen bir parola girin.',
      'Veuillez entrer un mot de passe.',
      'Voer een wachtwoord in.'
  );

  static String get passwordTooShort => _byLang(
      'Password must be at least 6 characters long.',
      'Parola en az 6 karakter olmalıdır.',
      'Le mot de passe doit contenir au moins 6 caractères.',
      'Het wachtwoord moet minstens 6 tekens lang zijn.'
  );

  static String get passwordsDoNotMatch => _byLang(
      'Passwords do not match.',
      'Parolalar eşleşmiyor.',
      'Les mots de passe ne correspondent pas.',
      'Wachtwoorden komen niet overeen.'
  );



  static String _byLang(String en, String tr, String fr, String nl) {
    switch (LanguageManager().currentLanguage) {
      case AppLanguage.turkish:
        return tr;
      case AppLanguage.french:
        return fr;
      case AppLanguage.dutch:
        return nl;
      case AppLanguage.english:
      default:
        return en;
    }
  }
}
