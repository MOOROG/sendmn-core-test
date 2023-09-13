using Google.Authenticator;
using Swift.API.Common;

namespace Swift.API.GoogleAuthenticator
{
    public class GoogleAuthenticatorAPI
    {
        protected TwoFactorAuthenticator _tfa = new TwoFactorAuthenticator();
        protected string _key = Utility.ReadWebConfig("2FAGoogle", "");
        protected string _keyForEncDec = Utility.ReadWebConfig("keyForEncryptionDecryption", "");
        public GoogleAuthenticatorModel GenerateCodeAndImageURL(string userName)
        {
            GoogleAuthenticatorModel _model = new GoogleAuthenticatorModel();
            string userUniqueKeyEncrypted = EncryptDecryptUtility.Encrypt(userName + _key, _keyForEncDec);
            Utility.WriteSession("UserUniqueKey", userUniqueKeyEncrypted);

            var _googleSetupInfo = _tfa.GenerateSetupCode("JME REMIT", userName, userUniqueKeyEncrypted, 200, 200, true);
            _model.SetupCode = _googleSetupInfo.ManualEntryKey;
            _model.BarCodeImageUrl = _googleSetupInfo.QrCodeSetupImageUrl;

            return _model;
        }

        public GoogleAuthenticatorModel GenerateCodeAndImageURL(string userName, string userUniqueKeyEncrypted)
        {
            GoogleAuthenticatorModel _model = new GoogleAuthenticatorModel();

            var _googleSetupInfo = _tfa.GenerateSetupCode("JME REMIT", userName, userUniqueKeyEncrypted, 200, 200, true);
            _model.SetupCode = _googleSetupInfo.ManualEntryKey;
            _model.BarCodeImageUrl = _googleSetupInfo.QrCodeSetupImageUrl;
            _model.ManualEntryKey = _googleSetupInfo.ManualEntryKey;
            
            return _model;
        }

        public DbResult Verify2FA(string otp, string userUniqueKey)
        {
            DbResult _dbRes = new DbResult();
            if (string.IsNullOrEmpty(otp))
            {
                _dbRes.SetError("1", "OTP Code can not be blank!", null);
                return _dbRes;
            }

            bool isValid = _tfa.ValidateTwoFactorPIN(userUniqueKey, otp);
            if (isValid)
                _dbRes.SetError("0", "Two factor authentication verified successfully!", null);
            else
                _dbRes.SetError("1", "Please enter valid OTP!", null);

            return _dbRes;
        }
    }
}
