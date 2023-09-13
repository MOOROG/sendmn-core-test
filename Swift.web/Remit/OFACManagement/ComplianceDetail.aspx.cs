using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web.UI;

namespace Swift.web.Remit.OFACManagement
{
    public partial class ComplianceDetail : Page
    {
        protected const string GridName = "grd_comDetails";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20198001";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Authenticate();
            if (GetTypeValue() == "compNew")
            {
                detail2.Visible = true;
                detail1.Visible = false;
                LoadComplianceNewDetail();
            }
            else
            {
                detail2.Visible = false;
                detail1.Visible = true;
                LoadGrid();
            }
        }

        private string GetTypeValue()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected long GetCsId()
        {
            return GetStatic.ReadNumericDataFromQueryString("csID");
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
        }

        private void LoadGrid()
        {
            var obj = new TranViewDao();

            double totAmt = 0.00;
            StringBuilder str =
                new StringBuilder(
                    "<table class='table table-responsive table-striped table-bordered'>");

            DataTable dt = obj.ExecuteDataset("EXEC proc_transactionView @flag = 'COMPL_DETAIL',@tranId=" + GetCsId() + ", @controlNo = " +
                 GetId() + "").Tables[1];

            int cols = dt.Columns.Count;

            DataTable dtHead =
                obj.ExecuteDataset("EXEC proc_transactionView @flag = 'COMPL_DETAIL',@tranId=" + GetCsId() + ", @controlNo = " +
                             GetId() + "").Tables[0];

            foreach (DataRow dr in dtHead.Rows)
            {
                str.Append("<tr>");
                str.Append("<th align=\"left\" colspan='" + cols + "'>" + dr["REMARKS"] + "</th>");
                str.Append("</tr>");
                str.Append("<tr>");
                str.Append("<th align=\"left\" colspan='" + cols + "'>" + dr["totTran"] + "</th>");
                str.Append("</tr>");
            }

            str.Append("<tr class='hdtitle'>");
            if (dt.Columns.Count > 0)
            {
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<th align=\"left\">" + dt.Columns[i].ColumnName + "</th>");
                }
                str.Append("</tr>");
                var cnt = 0;
                foreach (DataRow dr in dt.Rows)
                {
                    totAmt = totAmt + Double.Parse(dr["TRAN AMOUNT"].ToString());
                    str.Append("<tr>");
                    for (int i = 0; i < cols; i++)
                    {
                        if (i == 1)
                        {
                            str.Append("<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/Remit/Transaction/Reports/SearchTransaction.aspx?controlNo=" + dr[i] + "')\">" + dr[i] + "</a></td>");
                        }
                        else
                        {
                            str.Append("<td align=\"left\">" + dr[i] + "</td>");
                        }
                    }
                    str.Append("</tr>");
                }
                str.Append("<tr>");
                str.Append("<th align=\"right\" colspan='2'><font size='2px'><b>Total Tran Amount</b></font></th>");
                str.Append("<th align=\"left\"><font size='2px'>" + GetStatic.ShowDecimal(totAmt.ToString()) + "</font></th>");
                str.Append("</tr>");

                str.Append("</table>");
                rpt_grid.InnerHtml = str.ToString();
            }
        }

        private void LoadComplianceNewDetail()
        {
            var obj = new TranViewDao();

            double totAmt = 0.00;
            StringBuilder str =
                new StringBuilder(
                    "<table class='table table-responsive table-striped table-bordered'>");
            DataRow compData = obj.ExecuteDataRow("EXEC proc_complianceLogDetail @user = '" + GetStatic.GetUser() + "', @flag = 's', @rowId = " + obj.FilterString(GetId().ToString()));

            if (compData == null)
            {
                return;
            }

            sName.Text = compData["senderName"].ToString();
            sIdNo.Text = compData["senderIdNumber"].ToString();
            sIdType.Text = compData["senderIdType"].ToString();
            sCountry.Text = compData["senderCountry"].ToString();
            sContactNo.Text = compData["senderMobile"].ToString();

            rName.Text = compData["receiverName"].ToString();
            rCountry.Text = compData["receiverCountry"].ToString();

            compReason.Text = compData["complianceReason"].ToString();
            maxAmt.Text = compData["maxAmt"].ToString();
            sAmt.Text = compData["payOutAmt"].ToString();
            msg.Text = compData["message"].ToString();
        }

        //private void LoadGridData()
        //{
        //    grid.ColumnList = new List<GridColumn>
        //                          {
        //                              new GridColumn("currencyCode", "Currency Code", "", "T"),
        //                              new GridColumn("currencyName", "Currency Name", "", "T"),
        //                              new GridColumn("spFlag", "Applies For", "", "T"),
        //                              new GridColumn("isDefault", "Is Default", "", "T")
        //                          };

        // grid.GridType = 1; grid.GridName = GridName; grid.ShowFilterForm = false;
        // grid.ShowPagingBar = false; grid.GridWidth = 450; grid.DisableSorting = false;
        // grid.AllowEdit = false;

        // string sql = "EXEC proc_transactionView @flag = 'COMPL_DETAIL',@tranId=" + GetCsId() + ",
        // @controlNo = " + GetId();

        // grid.SetComma();

        //    rpt_grid.InnerHtml = grid.CreateGrid(sql);
        //}
    }
}