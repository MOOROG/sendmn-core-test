using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Cancel
{
    public partial class CancelWithCharge : Page
    {
        protected const string GridName = "grid_canceltrn";

        private const string ViewFunctionId = "20822400";
        private const string ProcessFunctionId = "20822410";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CancelTransactionDao obj = new CancelTransactionDao();
        private StaticDataDdl _sdd = new StaticDataDdl();
        readonly SmtpMailSetting _smtpMailSetting = new SmtpMailSetting();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                //LoadGrid("");
                GetStatic.PrintMessage(Page);
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
            btnCancel.Visible = _sdd.HasRight(ProcessFunctionId);
        }

        private void LoadByControlNo(string cNo)
        {
            ucTran.SearchData("", cNo, "", "N", "CANCEL", "ADM: CANCEL TXN");

            switch (ucTran.TranStatus)
            {
                case "":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction not found");
                    return;
                case "Paid":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction has already been paid");
                    return;
                case "Cancel":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction has already been cancelled");
                    return;
                case "Block":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction is blocked");
                    return;
                case "Compliance":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction under compliance");
                    return;
                case "Lock":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction is locked. Please contact HO");
                    return;
            }
            //switch (ucTran.PayStatus)
            //{
            //    case "Post":
            //        divTranDetails.Visible = false;
            //        PrintMessage("Transaction is Post. Please contact Head Office.");
            //        return;
            //}
            divTranDetails.Visible = ucTran.TranFound;
            searchDiv.Visible = !ucTran.TranFound;
            header.Text = "Cancel Transaction";
            hddTran.Value = ucTran.TranNo;
            //SendEmail();
        }

        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Result", "alert('" + msg + "')");
        }

        private void ManageMessage(DbResult dbResult)
        {
            string url = "CancelReceipt.aspx?tranId=" + ucTran.TranNo;
            string mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            string scriptName = "CallBack";
            string functionName = "CallBack('" + mes + "','" + url + "')";
            GetStatic.CallBackJs1(Page, scriptName, functionName);

            // Page.ClientScript.RegisterStartupScript(this.GetType(), "Done", "<script language = \"javascript\">return CallBack('" + mes + "')</script>");
        }


        private void RejectCancelRequest()
        {
            var dbResult = obj.RejectCancelRequestV2(GetStatic.GetUser(), ucTran.CtrlNo);
            GetStatic.SetMessage(dbResult);
            Response.Redirect("CancelWithCharge.aspx");
        }

        //Local Method
        private void CancelTranLocal()
        {
            DbResult dbResult = obj.CancelLocal(GetStatic.GetUser(), ucTran.CtrlNo, cancelReason.Text, "D");// D means cancel with charge
            ManageMessage(dbResult);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadByControlNo(controlNo.Text);
        }

        protected void btnTranSelect_Click(object sender, EventArgs e)
        {
            string id = grid.GetRowId(GridName);
            //LoadGrid(id);
            LoadByControlNo(id);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
             CancelTranLocal();
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            RejectCancelRequest();
        }
    }
}