using Common.Utility;
using Swift.API.Common;
using Swift.API.Common.SMS;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Text;

namespace Swift.web.AgentPanel.ResetPassword
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40122000";
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            swiftLibrary.CheckSession();
        }

        protected void changePass_Click(object sender, EventArgs e)
        {
            DbResult _res = new DbResult();
            CheckPasswordUtility _checkPass = new CheckPasswordUtility();


            // Generate & update password
            var pwd = GeneratePassword(Convert.ToInt16(GetStatic.ReadWebConfig("passwordLength","9")));

            /**
             * _res.Extra - phone number
             * _res.Extra2 - email address
             */
            _res = _cd.ResetPassword(GetStatic.GetUser(), pwd, txtEmail.Value);
      if (_res.Extra2 == null) {
        string[] mailAdd = txtEmail.Text.Split('|');
        if (mailAdd.Length > 1) {
          _res.Extra2 = mailAdd[0].Trim();
        }
      }

            if (_res.ErrorCode == "0")
            {
                // Send new password via Email
                string _resp_email = GetStatic.SendEmail("New Password", "Your new password is: " + pwd, _res.Extra2);

                // Send new password via SMS
                string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":sendSms";
                SendSMSApiService _sendAPI = new SendSMSApiService();
                
                SMSRequestModel _req = new SMSRequestModel
                {
                    ProviderId = "onewaysms",
                    MobileNumber = _res.Extra.Trim().Replace("+", ""),
                    SMSBody = "Dear Customer, your new password for "+ GetStatic.ReadWebConfig("copyRightName", "") + " is: " + pwd,
                    ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40),
                    RequestedBy = GetStatic.GetUser(),
                    UserName = GetStatic.GetUser(),
                    method = "send"
                };
                JsonResponse _resp = _sendAPI.SMSTPApi(_req);

                string isSuccess = (_resp.ResponseCode == "0") ? "Success" : "Failed";

                GetStatic.CallBackJs1(this, "Success", "ShowMsg('Password reset: \"" + _res.Msg + "\"; Email: \"" + _resp_email + "\"; SMS: \"" + isSuccess + "\"');");
            }
            else
            {
                GetStatic.CallBackJs1(this, "Success", "ShowMsg('" + _res.Msg + "');");
            }
        }

        public static string GeneratePassword(int length)
        {
            Random random = new Random();
            string characters = "123456789ABCDEFGHKMNPQRSTUVWXYZabcdefghkmnpqrstuvwxyz@#$&*?";
            StringBuilder result = new StringBuilder(length);
            for (int i = 0; i < length; i++)
            {
                result.Append(characters[random.Next(characters.Length)]);
            }
            return result.ToString();
        }
    }
}