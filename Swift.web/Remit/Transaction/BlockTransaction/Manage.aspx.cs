using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;


namespace Swift.web.Remit.Transaction.BlockTransaction
{
   
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        SwiftLibrary sl= new SwiftLibrary();
        private readonly LockUnlock obj = new LockUnlock();
        private const string viewFunctionId = "20121200";
        private const string approveFunctionId = "20121230";
        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckAuthentication(viewFunctionId);
            ManageButtons();
        }
        
        private void ManageButtons()
        {
            var mode = GetStatic.ReadQueryString("controlNo", "");
            var controlNo = GetStatic.ReadQueryString("controlNo", "");

            if (controlNo != "")
            {
                btnBlock.Visible = false;
                btnUnBlock.Visible = sl.HasRight(approveFunctionId);
                divSearch.Visible = false;
                LoadData();
            } else
            {
                btnBlock.Visible = sl.HasRight(approveFunctionId);
                btnBlock.Enabled = sl.HasRight(approveFunctionId);
                btnUnBlock.Visible = false;
                divSearch.Visible = true;
            }
        }

        private void LoadData()
        {
            var ctrlNo = GetStatic.ReadQueryString("controlNo", "");

            ucTran.SearchData("", ctrlNo,"","N", "UNBLOCK", "ADM: UNBLOCK TXN");

            divTranDetails.Visible = true;
            divComments.Visible = true;
        }

        private void SearchData()
        {
            ucTran.SearchData("", controlNo.Text, "","N","BLOCK","ADM: BLOCK TXN");
            if(ucTran.TranStatus != "Payment")
            {
                divTranDetails.Visible = false;
                PrintMessage("No transaction found..");
                return;
            }
            divTranDetails.Visible = true;
            divComments.Visible = true;
        }
        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Msg", "alert('"+msg+"');");
        }
        protected void btnBlock_Click(object sender, EventArgs e)
        {
            var dbResult = obj.BlockTransaction(GetStatic.GetUser(), controlNo.Text, comments.Text);
            ManageMessage(dbResult);
        }

        protected void btnUnBlock_Click(object sender, EventArgs e)
        {
            var cnNo = GetStatic.ReadQueryString("controlNo", "");
            if (cnNo == "")
                return;
            var dbResult = obj.UnBlockTransaction(GetStatic.GetUser(), cnNo, comments.Text);
            ManageMessage(dbResult);
        }

        protected void btnSearchDetail_Click(object sender, EventArgs e)
        {
            SearchData();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx");
            }
        }
    }
}