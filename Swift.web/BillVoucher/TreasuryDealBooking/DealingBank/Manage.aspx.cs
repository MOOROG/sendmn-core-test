using Swift.DAL.Treasury;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.BillVoucher.TreasuryDealBooking.DealingBank
{
    public partial class List : System.Web.UI.Page
    {
        private readonly IFundTransferDao obj = new FundTransferDao();
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        private const string ViewFunctionId = "20150090";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
            }
        }

        private void Authenticate()
        {
            remLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectBankById(GetId().ToString(), GetStatic.GetUser());
            if (dr == null)
                return;
            bankName.Text = dr["BankName"].ToString();
            krwAcc.Value = dr["SellAcNo"].ToString();
            krwAcc.Text = dr["SellAcName"].ToString();
            usdAcc.Value = dr["BuyAcNo"].ToString();
            usdAcc.Text = dr["BuyAcName"].ToString();
            chkPayCurrency.Checked = Convert.ToBoolean(dr["Settle_PayCurr"]);
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string hasChk = (chkPayCurrency.Checked ? "1" : "0");
            var res = obj.AddNewBank(bankName.Text, krwAcc.Value, usdAcc.Value, GetStatic.GetUser(), GetId().ToString(), hasChk);
            GetStatic.SetMessage(res);

            if (res.ErrorCode != "0")
            {
                return;
            }

            GetStatic.PrintMessage(this);
            Response.Redirect("List.aspx");
        }
    }
}