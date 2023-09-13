using Swift.DAL.Treasury;
using Swift.web.Library;
using System;

namespace Swift.web.BillVoucher.TreasuryDealBooking
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150090";
        private readonly SwiftLibrary _sdd = new SwiftLibrary();
        private readonly IFundTransferDao _vrd = new FundTransferDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDDL();
                date.Text = DateTime.Now.ToString("yyyy-MM-dd");
                maturityDate.Text = DateTime.Now.AddDays(2).ToString("yyyy-MM-dd");
                Misc.MakeNumericTextbox(ref rate);
                Misc.MakeNumericTextbox(ref usdAmount);
            }
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref bankDDL, "EXEC proc_dropDownList @FLAG='BankList'", "RowId", "BankName", "", "Select Bank");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void BtnSave_Click(object sender, EventArgs e)
        {
            var result = _vrd.SaveDealBooking(date.Text, bankDDL.Text, usdAmount.Text, rate.Text, krwAmount.Text, dealer.Text, maturityDate.Text, contractNo.Text, GetStatic.GetUser());
            if (result.ErrorCode == "0")
            {
                date.Text = "";
                bankDDL.Text = "";
                usdAmount.Text = "";
                rate.Text = "";
                krwAmount.Text = "";
                dealer.Text = "";
                maturityDate.Text = "";
                contractNo.Text = "";
            }
            divMsg.InnerHtml = result.Msg;
            return;
        }
    }
}