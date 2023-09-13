using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.Modify
{
    public partial class ModifyTran : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40101700";
        private const string ProcessFunctionId = "40101710";
        private readonly StaticDataDdl sd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                //fromDate.Text= DateTime.Now.ToString("yyyy-MM-dd");
            }
            GetStatic.ResizeFrame(Page);
            Misc.MakeNumericTextbox(ref tranId);
        }

        private void Authenticate()
        {
            sd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
        }

        protected void btnSearchDetail_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(controlNo.Text))
                LoadGridView(controlNo.Text, "", "", "", "");
            else if (!string.IsNullOrEmpty(tranId.Text))
                LoadGridView("", tranId.Text, "", "", "");
            //else
            //{
            //    //if (fromDate.Text == "")
            //    //{
            //    //    PrintMessage("Please enter date!");
            //    //    return;
            //    //}
            //    //else
            //    LoadGridView("", "", null, null, fromDate.Text);
            //}
        }

        protected void btnClick_Click(object sender, EventArgs e)
        {
            LoadByControlNo(hdnControlNo.Value, hdnStatus.Value);
        }

        private void LoadGridView(string cNo, string txnId, string searchByText, string serachBy, string date)
        {
            var obj = new TranViewDao();
            var ds = obj.DisplayMatchTran(GetStatic.GetUser(), searchByText, serachBy, date, cNo, txnId);

            if (ds == null)
            {
                divLoadGrid.Visible = false;
                PrintMessage("Transaction not found!");
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<div class='panel panel-default'><div class='panel-heading'>Search Result</div><div class='panel-body'><table class='table table-bordered' border=\"0\" cellspacing=0 cellpadding=\"3\"></div></div>");
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    for (int i = 0; i < cols; i++)
                    {
                        str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                    }
                    str.Append("</tr>");
                }
                str.Append("</table></fieldset>");
                divLoadGrid.Visible = true;
                divLoadGrid.InnerHtml = str.ToString();
            }
        }

        private void LoadByControlNo(string cNo, string tranStatus)
        {
            if (sd.HasRight(ProcessFunctionId) && tranStatus == "Payment")
                ucTran.SearchData("", cNo, "u", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");
            else
                ucTran.SearchData("", cNo, "", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");

            if (!ucTran.TranFound)
            {
                PrintMessage("Transaction not found!");
                return;
            }

            //if (ucTran.TranStatus != "Payment")
            //{
            //    string status = ucTran.TranStatus;
            //    divTranDetails.Visible = false;
            //    PrintMessage("Transaction not authorised for modification; Status:" + status + "!");
            //    return;
            //}

            //var createdBy = ucTran.CreatedBy;
            //if (GetStatic.GetUser() != createdBy)
            //{
            //    GetStatic.AlertMessage(Page, "You are not authorized to view this transaction");
            //    return;
            //}

            divTranDetails.Visible = ucTran.TranFound;
            divSearch.Visible = !ucTran.TranFound;
        }

        private void LoadByControlNo(string cNo)
        {
            if (sd.HasRight(ProcessFunctionId))
                ucTran.SearchData("", cNo, "u", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");
            else
                ucTran.SearchData("", cNo, "", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");

            if (!ucTran.TranFound)
            {
                PrintMessage("Transaction not found!");
                return;
            }

            if (ucTran.TranStatus != "Payment")
            {
                string status = ucTran.TranStatus;
                divTranDetails.Visible = false;
                PrintMessage("Transaction not authorised for modification; Status:" + status + "!");
                return;
            }

            /*
            var createdBy = ucTran.CreatedBy;
            if (GetStatic.GetUser() != createdBy)
            {
                GetStatic.AlertMessage(Page, "You are not authorized to view this transaction");
                return;
            }
             * */
            divTranDetails.Visible = ucTran.TranFound;
            divSearch.Visible = !ucTran.TranFound;
        }

        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Msg", "alert('" + msg + "');");
        }

        protected void btnReloadDetail_Click(object sender, EventArgs e)
        {
            LoadByControlNo(ucTran.CtrlNo);
        }
    }
}