using Swift.DAL.Treasury;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.BillVoucher.FundTransfer.Setting
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly IFundTransferDao obj = new FundTransferDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFuntionId = "20153000";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDDL();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFuntionId);
        }

        protected void PopulateDDL()
        {
            _sl.SetDDL(ref TransferFund, "EXEC proc_dropDownList @FLAG='transferType'", "detailTitle", "detailTitle", "", "");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectCorrespondentBankById(GetId().ToString(), GetStatic.GetUser());
            if (dr == null)
                return;

            TransferFund.Text = dr["transferType"].ToString();
            PartnerName.Text = dr["nameOfPartner"].ToString();
            ReceiveAc.Value = dr["receiveUSDNostro"].ToString();
            ReceiveAc.Text = dr["NostroName"].ToString();
            CorrespondentAc.Value = dr["receiveUSDCorrespondent"].ToString();
            CorrespondentAc.Text = dr["CorrespondentName"].ToString();
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            var res = obj.AddCorrespondent(TransferFund.Text, PartnerName.Text, ReceiveAc.Value, CorrespondentAc.Value, GetStatic.GetUser(), GetId().ToString());
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