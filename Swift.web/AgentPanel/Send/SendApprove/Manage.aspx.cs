using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.AgentPanel.Send.SendApprove
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40161240";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly ApproveTransactionDao atd = new ApproveTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnApprove, "Are you sure to APPROVE this transaction?");
            if (!IsPostBack)
            {
                //Authenticate();
              
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
        //    ucTran.SearchData(tranNo, "", "", "", "APPROVE", "ADMIN: VIEW TXN TO APPROVE");
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
               

        private void Approve()
        {
            var dr = atd.ApproveHoldedTXN(GetStatic.GetUser(), GetTranNo());
            GetStatic.AlertMessage(Page, dr.Msg);
            if (dr.ErrorCode.Equals("0"))
            {
                GetStatic.CallJSFunction(Page, "window.returnValue = true; window.close();");
            }
            
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            Approve();
        }
    }
}