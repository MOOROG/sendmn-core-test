using Swift.DAL.BL.Remit.Transaction.Domestic;
using Swift.DAL.Domain;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.Send.SendRegional
{
    public partial class Confirm : System.Web.UI.Page
    {
        //readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly RemittanceLibrary rl = new RemittanceLibrary();

        private readonly string _sBranch = GetStatic.ReadQueryString("sBranch", "");
        private readonly string _pDistrictName = GetStatic.ReadQueryString("pDistrictName", "");
        private readonly string _pLocation = GetStatic.ReadQueryString("pLocation", "");
        private readonly string _pLocationName = GetStatic.ReadQueryString("pLocationName", "");
        private readonly decimal _tAmt = GetStatic.ReadDecimalDataFromQueryString("tAmt");
        private readonly decimal _sc = GetStatic.ReadDecimalDataFromQueryString("sc");
        private readonly decimal _cAmt = GetStatic.ReadDecimalDataFromQueryString("cAmt");
        private readonly string _dm = GetStatic.ReadQueryString("dm", "");
        private readonly string _pBankBranch = GetStatic.ReadQueryString("pBankBranch", "");
        private readonly string _pBankBranchName = GetStatic.ReadQueryString("pBankBranchName", "");
        private readonly string _pBankName = GetStatic.ReadQueryString("pBankName", "");
        private readonly string _accountNo = GetStatic.ReadQueryString("accountNo", "");

        private readonly string _senderId = GetStatic.ReadQueryString("senderId", "");
        private readonly string _sMemId = GetStatic.ReadQueryString("sMemId", "");
        private readonly string _sFirstName = GetStatic.ReadQueryString("sFirstName", "");
        private readonly string _sMiddleName = GetStatic.ReadQueryString("sMiddleName", "");
        private readonly string _sLastName1 = GetStatic.ReadQueryString("sLastName1", "");
        private readonly string _sLastName2 = GetStatic.ReadQueryString("sLastName2", "");
        private readonly string _sAddress = GetStatic.ReadQueryString("sAddress", "");
        private readonly string _sContactNo = GetStatic.ReadQueryString("sContactNo", "");
        private readonly string _sIdType = GetStatic.ReadQueryString("sIdType", "");
        private readonly string _sIdNo = GetStatic.ReadQueryString("sIdNo", "");
        private readonly string _sEmail = GetStatic.ReadQueryString("sEmail", "");

        private readonly string _receiverId = GetStatic.ReadQueryString("receiverId", "");
        private readonly string _rMemId = GetStatic.ReadQueryString("rMemId", "");
        private readonly string _rFirstName = GetStatic.ReadQueryString("rFirstName", "");
        private readonly string _rMiddleName = GetStatic.ReadQueryString("rMiddleName", "");
        private readonly string _rLastName1 = GetStatic.ReadQueryString("rLastName1", "");
        private readonly string _rLastName2 = GetStatic.ReadQueryString("rLastName2", "");
        private readonly string _rAddress = GetStatic.ReadQueryString("rAddress", "");
        private readonly string _rContactNo = GetStatic.ReadQueryString("rContactNo", "");
        private readonly string _rel = GetStatic.ReadQueryString("rel", "");
        private readonly string _rIdType = GetStatic.ReadQueryString("rIdType", "");
        private readonly string _rIdNo = GetStatic.ReadQueryString("rIdNo", "");

        private readonly string _payMsg = GetStatic.ReadQueryString("payMsg", "");
        private readonly string _sof = GetStatic.ReadQueryString("sof", "");
        private readonly string _por = GetStatic.ReadQueryString("por", "");

        private readonly string _occupation = GetStatic.ReadQueryString("occupation", "");

        private const string ViewFunctionId = "40102700";
        private const string AddEditFunctionId = "40102710";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                ShowData();
            }
            Misc.MakeAmountTextBox(ref txtCollAmt);
        }

        private void Authenticate()
        {
            rl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        protected void ShowData()
        {
            var confirmText = "Confirmation:\n_____________________________________";
            confirmText += "\n\nAre you sure to send this transaction?";
            //btnProceedCc.ConfirmText = confirmText;

            if (!ValidateTransaction())
                return;
            sBranchName.Text = rl.GetAgentName(_sBranch);
            if (_dm.ToUpper() == "BANK DEPOSIT")
            {
                trBankDetail.Visible = true;
                bankName.Text = _pBankName;
                branchName.Text = _pBankBranchName;
                accountNo.Text = _accountNo;
            }
            sName.Text = _sFirstName + " " + _sMiddleName + " " + _sLastName1 + " " + _sLastName2;
            sAddress.Text = _sAddress;
            sContactNo.Text = _sContactNo;
            sIdType.Text = _sIdType;
            sIdNo.Text = _sIdNo;
            sEmail.Text = _sEmail;
            sMemId.Text = _sMemId;

            rName.Text = _rFirstName + " " + _rMiddleName + " " + _rLastName1 + " " + _rLastName2;
            rAddress.Text = _rAddress;
            rContactNo.Text = _rContactNo;
            rRel.Text = _rel;
            rIdType.Text = _rIdType;
            rIdNo.Text = _rIdNo;
            rMemId.Text = _rMemId;

            pMsg.Text = _payMsg;
            pLocation.Text = _pLocationName;
            pDistrict.Text = _pDistrictName;
            pCountry.Text = "Nepal";
            payMode.Text = _dm;

            tAmt.Text = GetStatic.FormatData(_tAmt.ToString(), "M");
            serviceCharge.Text = GetStatic.FormatData(_sc.ToString(), "M");
            cAmt.Text = GetStatic.FormatData(_cAmt.ToString(), "M");
            pAmt.Text = GetStatic.FormatData(_tAmt.ToString(), "M");
            pMsg.Text = _payMsg;
            lblSof.Text = _sof;
            lblPor.Text = _por;
            lblOccupation.Text = _occupation;
        }

        private bool ValidateTransaction()
        {
            if (!RequiredFieldValidate())
            {
                GetStatic.CallBackJs1(Page, "Print Message", "ManageMessage('" + Msg + "');");
                return false;
            }
            return true;
        }

        private string Msg = "";

        private bool RequiredFieldValidate()
        {
            if (string.IsNullOrWhiteSpace(_sFirstName))
            {
                Msg = " Sender First Name missing";
                return false;
            }

            if (string.IsNullOrWhiteSpace(_rFirstName))
            {
                Msg = " Receiver First Name missing";
                return false;
            }

            if (string.IsNullOrWhiteSpace(_dm))
            {
                Msg = "Please choose payment mode";
                return false;
            }
            if (_tAmt == 0)
            {
                Msg = "Transfer Amount missing";
                return false;
            }
            if (_sc == 0)
            {
                Msg = "Service Charge missing";
                return false;
            }
            if (_cAmt == 0)
            {
                Msg = "Collection Amount is missing. Cannot send transaction";
                return false;
            }
            return true;
        }

        protected void btnProceed_Click(object sender, EventArgs e)
        {
            Proceed();
        }

        private void Proceed()
        {
            decimal cAmtvarify = decimal.Parse(txtCollAmt.Text);
            if (_cAmt != cAmtvarify)
            {
                var msg = "alert('" +
                          GetStatic.FilterMessageForJs(
                              "Collection Amount doesnot match. Please check the amount details.") + "');";
                GetStatic.CallBackJs1(Page, "cb", msg);
                return;
            }
            var dbResult = Save();
            if (dbResult.ErrorCode == "0")
            {
                ManageMessage(dbResult);
            }
            else
            {
                var message = "alert('" + GetStatic.FilterMessageForJs(dbResult.Msg) + "');";
                GetStatic.CallBackJs1(Page, "cb", message);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");
            var invPrintMode = "Y";
            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "','" + invPrintMode + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        private DbResult Save()
        {
            var st = new SendTransactionDao();
            var tran = new TranDetail();
            var randObj = new Random();
            string txnId = randObj.Next(1000000000, 1999999999).ToString();
            tran.SBranch = _sBranch;
            tran.AgentRefId = txnId;
            tran.PBankBranch = _pBankBranch;
            tran.AccountNo = _accountNo;
            tran.PLocation = _pLocation;
            tran.TransferAmt = _tAmt.ToString();
            tran.ServiceCharge = _sc.ToString();
            tran.TotalCollection = _cAmt.ToString();
            tran.PayoutAmt = _tAmt.ToString();
            tran.DeliveryMethod = _dm;
            tran.SenderId = _senderId;
            tran.SMemId = _sMemId;
            tran.SFirstName = _sFirstName;
            tran.SMiddleName = _sMiddleName;
            tran.SLastName1 = _sLastName1;
            tran.SLastName2 = _sLastName2;
            tran.SAddress = _sAddress;
            tran.SContactNo = _sContactNo;
            tran.SIDType = _sIdType;
            tran.SIDNo = _sIdNo;
            tran.SEmail = _sEmail;
            tran.ReceiverId = _receiverId;
            tran.RMemId = _rMemId;
            tran.RFirstName = _rFirstName;
            tran.RMiddleName = _rMiddleName;
            tran.RLastName1 = _rLastName1;
            tran.RLastName2 = _rLastName2;
            tran.RAddress = _rAddress;
            tran.RContactNo = _rContactNo;
            tran.RIDType = _rIdType;
            tran.RIDNo = _rIdNo;
            tran.RelWithSender = _rel;
            tran.PayoutMsg = _payMsg;
            tran.txtPass = txnPassword.Text;
            tran.DcInfo = GetStatic.GetDcInfo();
            tran.IpAddress = GetStatic.GetIp();
            tran.SourceOfFund = _sof;
            tran.PurposeOfRemit = _por;
            tran.Occupation = _occupation;
            var dbResult = st.SendDomesticTransactionRegional(GetStatic.GetUser(), tran, GetStatic.GetFromSendTrnTime(), GetStatic.GetToSendTrnTime());
            return dbResult;
        }
    }
}