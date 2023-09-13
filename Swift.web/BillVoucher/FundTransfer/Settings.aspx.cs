using Swift.DAL.SwiftDAL;
using Swift.DAL.Treasury;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.BillVoucher.FundTransfer
{
    public partial class Settings : System.Web.UI.Page
    {
        private const string ViewFuntionId = "20153000";
        private readonly SwiftLibrary _sdd = new SwiftLibrary();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private IFundTransferDao _sd = new FundTransferDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDDL();
                PopulateData();
            }
        }

        private void PopulateData()
        {
            receieveInUsd.Text = "";
            receieveInUsd.Value = "";
            furtherTransferTo.Text = "";
            furtherTransferTo.Value = "";
            DataRow dr = _sd.GetSettingDetails(ddlTransferType.SelectedValue);

            if (dr == null)
            {
                return;
            }

            nameOfPartner.Text = dr["nameOfPartner"].ToString();

            if (ddlTransferType.SelectedValue == "2")
            {
                receieveInUsd.Text = dr["ACC1"].ToString();
                receieveInUsd.Value = dr["receiveUSDNostro"].ToString();
                furtherTransferTo.Text = dr["ACC2"].ToString();
                furtherTransferTo.Value = dr["receiveUSDCorrespondent"].ToString();
            }
            else
            {
                receieveInUsd.Text = dr["ACC1"].ToString();
                receieveInUsd.Value = dr["receiveUSDNostro"].ToString();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFuntionId);
        }

        protected void PopulateDDL()
        {
            _sl.SetDDL(ref ddlTransferType, "EXEC proc_dropDownList @FLAG='transferType'", "rowId", "transferType", "", "");
        }

        protected void btnTransfer_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Update()
        {
            DbResult _db = new DbResult();
            _db = _sd.UpdateFundTransferDetail(ddlTransferType.SelectedValue, nameOfPartner.Text, receieveInUsd.Value, furtherTransferTo.Value, GetStatic.GetUser());
            if (_db.ErrorCode == "0")
            {
                var scriptName = "CallBack";
                var functionName = "CallBack('" + _db.Msg + "')";
                GetStatic.CallBackJs1(Page, scriptName, functionName);
            }
        }

        protected void ddlTransferType_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateData();
        }
    }
}