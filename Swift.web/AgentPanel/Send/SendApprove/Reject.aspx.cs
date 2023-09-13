using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.AgentPanel.Send.SendApprove
{
    public partial class Reject : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40161236";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly ApproveTransactionDao atd = new ApproveTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnReject, "Are you sure to reject this transaction?");
            if (!IsPostBack)
            {
                Authenticate();
            }
            //LoadTransaction();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }
                
        //private void LoadTransaction()
        //{
        //    string tranNo = GetTranNo();
        //    ucTran.SearchData(tranNo, "", "", "", "REJECT", "ADMIN: VIEW TXN TO REJECT");
        //    divTranDetails.Visible = ucTran.TranFound;
        //    if (!ucTran.TranFound)
        //    {
        //        divControlno.InnerHtml = "<h2>No Transaction Found</h2>";
        //        return;
        //    }          
        //}
        
        protected string GetTranNo()
        {
            return GetStatic.ReadQueryString("id", "");
        }
        
        private void ManageReject()
        {
            var dr = atd.Reject(GetStatic.GetUser(), GetTranNo(), remarks.Text, GetStatic.GetSettlingAgent());
            GetStatic.AlertMessage(Page, dr.Msg);
            if (dr.ErrorCode.Equals("0"))
            {
                GetStatic.CallJSFunction(Page, "window.returnValue = true; window.close();");
            }
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            ManageReject();
        }
    }
}