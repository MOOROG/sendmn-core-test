using Swift.DAL.BL.AgentPanel.Send;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.SendTxn.TxnHistory
{
    public partial class SenderAdvanceSearch : System.Web.UI.Page
    {
        readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            searchValue.Focus();
            if (!IsPostBack)
            {
                PopulateDdl();
            }
        }
        private void Authenticate()
        {
            //sl.CheckAuthentication(ViewFunctionId);
            sl.CheckSession();
        }
        private void PopulateDdl()
        {
            _sdd.SetDDL(ref searchType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
            //_sdd.SetDDL(ref searchType, "EXEC proc_dropDownLists @flag = 'custSearchType'", "detailTitle", "detailDesc", "", "Select");
        }

        #region method

        private void LoadGrid()
        {

            rpt_grid.InnerHtml = "";
            SendTranIRHDao dao = new SendTranIRHDao();
            var dt = dao.LoadCustomerDataNew(searchType.Text, searchValue.Text, "advS-new", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
            if (dt == null || dt.Rows.Count == 0)
            {
                ManageMessage("1", "Record not found for respected Search.");
                return;
            }
            if (dt.Rows[0]["errorCode"].ToString() == "1")
            {
                ManageMessage(dt.Rows[0]["errorCode"].ToString(), dt.Rows[0]["msg"].ToString());
                return;
            }
            int cnt = 0;
            StringBuilder sb = new StringBuilder("<div class='table table-responsive'><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\" class=\"table table-bordered table-condensed\">");
            sb.AppendLine("<tr >");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'></th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Customer ID</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Sender Name</th>");
            //sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Receiver Name</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Country</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Address</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Mobile No</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>ID Type</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>ID Number</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Valid Date</th>");

            sb.AppendLine("</tr>");

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                ++cnt;
                sb.AppendLine("<tr onclick='CheckTR(" + cnt + ");' class=" + (cnt % 2 == 0 ? "'oddbg'" : "'evenbg'") + ">");
                //for (int j = 0; j < dt.Columns.Count; j++)
                //{
                sb.AppendLine("<td><input type='radio' name='rdoId' id='rdoId' value=" + dt.Rows[i]["customerId"] + "></td>");
                sb.AppendLine("<td>" + dt.Rows[i]["customerId"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["senderName"] + "</td>");
                //sb.AppendLine("<td>" + dt.Rows[i]["receiverName"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["countryName"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["address"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["mobile"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["idType"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["idNumber"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["validDate"] + "</td>");
                //}

                sb.AppendLine("</tr>");
            }
            sb.AppendLine("</table>");
            rpt_grid.InnerHtml = sb.ToString();
        }

        private void ManageMessage(string res, string msg)
        {
            GetStatic.CallBackJs1(Page, "Call Back", "alert('" + msg + "');");
        }

        #endregion
        protected void BtnSave2_Click(object sender, EventArgs e)
        {
            if (searchValue.Text != "")
                LoadGrid();
        }

        protected void btnOk_Click(object sender, EventArgs e)
        {
            string id = Request.Form["rdoId"];
            GetStatic.CallBackJs1(Page, "Call Back", "CallBack('" + id + "');");
            //ManageMessage(id, "");
        }
    }
}