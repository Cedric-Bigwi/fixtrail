class AppConstants {
  static const appName = 'FixTrail';
  static const tagline = 'Spot it. Report it. Watch it get fixed.';

  /// Only these email domains may register / use the app.
  /// (For local testing with another email, temporarily add its domain here
  /// AND in firebase/firestore.rules.)
  /// Photo storage backend.
  /// true  = Supabase Storage (free tier, no billing needed)
  /// false = Firebase Storage (requires the Firebase Blaze plan)
  static const useSupabaseStorage = true;
  static const supabaseUrl = 'https://miqgkjsmotucyxpyeakj.supabase.co';
  // Publishable key only (sb_publishable_...). NEVER put the secret key in the app.
  static const supabasePublishableKey = 'sb_publishable_6H0GiwFjKCQ3cLhKr49VZA_Vz4MBkc_';
  static const supabaseBucket = 'incident-photos';

  /// Email-verification gate.
  /// false = ALU-domain check only (easy testing with accounts whose inbox you
  /// cannot open). true = users must click the emailed link before entering.
  /// If you change this, also change `requireVerified()` in firebase/*.rules.
  static const requireEmailVerification = false;

  static const allowedDomains = ['alustudent.com', 'alueducation.com'];

  static const locations = [
    'Student Residence',
    'Block A',
    'Block B',
    'Block C',
    'Library',
    'Cafeteria',
    'Sports Field',
    'Parking Lot',
    'Admin Building',
    'Main Gate',
    'Outdoor Grounds',
    'Other',
  ];
}
