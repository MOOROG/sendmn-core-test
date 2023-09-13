using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Web.UI;

namespace Swift.web.AgentNew.AgentSend
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20122800";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly ApproveTransactionDao atd = new ApproveTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnApprove, "Are you sure to APPROVE this transaction?");
            if (!IsPostBack)
            {
                //Authenticate();
            }
            LoadTransaction();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadTransaction()
        {
            string tranNo = GetTranNo();
            ucTran.SearchData(tranNo, "", "", "", "APPROVE", "ADMIN: VIEW TXN TO APPROVE");
            divTranDetails.Visible = ucTran.TranFound;
            if (!ucTran.TranFound)
            {
                divControlno.InnerHtml = "<h2>No Transaction Found</h2>";
                return;
            }
        }

        protected string GetTranNo()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        private void Approve()
        {
            DbResult dbResult = atd.VerifyTransaction(GetTranNo(), GetStatic.GetUser());
            GetStatic.PrintMessage(Page, dbResult);
            if (dbResult.ErrorCode.Equals("0"))
            {
                ClientScript.RegisterStartupScript(Page.GetType(), "scr", "window.opener.CallBack();", true);
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            Approve();
        }
    }
}