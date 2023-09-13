using Swift.DAL.Remittance.Transaction.ThirdParty.Ria;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.RiaTransaction
{
    public partial class RiaEntryForm : System.Web.UI.Page
    {
        RiaTxnDao _ria = new RiaTxnDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "40120300";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                ManageFields();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void ManageFields()
        {
            remitDate.Attributes.Add("readonly", "readonly");
            remitDate.Text = DateTime.Now.ToString("d");
            Misc.MakeAmountTextBox(ref cAmt);
            Misc.MakeAmountTextBox(ref pAmt);
            Misc.MakeAmountTextBox(ref sCharge);

            //Populate RIA Exrate
            //exRateUSD.Attributes.Add("readonly", "readonly");
            //exRateUSD.Text = _ria.GetExchangeRate();

            //Populate DDLs
            _sdd.SetDDL(ref sCountry, "EXEC [proc_dropDownLists] @flag='country'", "countryId", "countryName", "", "Sender Native Country");
            _sdd.SetDDL(ref rCountry, "EXEC [proc_dropDownLists] @flag='country'", "countryId", "countryName", "", "Receiving Country");
            _sdd.SetDDL(ref pCurr, "EXEC [PROC_RIASENDTXN] @flag='pCurr'", "currencyCode", "currencyCode", "", "Payout Currency");
            _sdd.SetDDL(ref idType, "EXEC proc_online_dropDownList @flag='idType'", "valueId", "detailTitle", "", "Select ID Type");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            DbResult _dbRes = new DbResult();
            RiaTxnDetails _txnDetails = SetRiaTxnDetails();
            _dbRes = _ria.SendRiaTxn(_txnDetails);
            if (_dbRes.ErrorCode == "0")
            {
                ClearFields();
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
            else
            {
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
        }

        private void ClearFields()
        {
            remitDate.Text = DateTime.Now.ToString("d");
            cAmt.Text = "";
            sCharge.Text = "";
            senderName.Text = "";
            sIdNumber.Text = "";
            controlNumber.Text = "";
            receiverName.Text = "";
            rCountry.SelectedValue = "";
            orderNumber.Text = "";
            seqNumber.Text = "";
            pAmt.Text = "";
            pCurr.SelectedValue = "";
            idType.SelectedValue = "";
            sMobile.Text = "";
            sEmail.Text = "";
        }

        private RiaTxnDetails SetRiaTxnDetails()
        {
            return new RiaTxnDetails { 
                User = GetStatic.GetUser(),
                BranchCode = GetStatic.GetBranch(),
                RemitDate = remitDate.Text,
                CollectAmount = cAmt.Text,
                USDExRate = exRateUSD.Text,
                ServiceCharge = sCharge.Text,
                SenderName = senderName.Text,
                SenderIdNumber = sIdNumber.Text,
                SenderCountry = sCountry.SelectedItem.Text,
                ControlNumber = controlNumber.Text,
                ReceiverName = receiverName.Text,
                ReceiverCountry = rCountry.SelectedItem.Text,
                OrderNumber = orderNumber.Text,
                SequenceNumber = seqNumber.Text,
                PayoutAmount = pAmt.Text,
                PayoutCurrency = pCurr.SelectedValue,
                SenderCountryId = sCountry.SelectedValue,
                PaymentMethod = "CASH PAYMENT",
                ReceiverCountryId = sCountry.SelectedValue,
                sIdType = idType.SelectedValue,
                sIdTypeText = idType.SelectedItem.Text,
                sMobile = sMobile.Text,
                sEmail=sEmail.Text
            };
        }
    }
}