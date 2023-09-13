using Swift.DAL.Remittance.Transaction.CustomerSoa;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.CustomerSOA
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "2019300";
        private const string AddEditFunctionId = "2019310";
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                toDate.Text = DateTime.Now.ToShortDateString();
                fromDate.Text = DateTime.Now.ToShortDateString();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CustomerSoaDao cusDao = new CustomerSoaDao();
            StringBuilder sb = new StringBuilder("");
            var dateFrom = fromDate.Text;
            var dateTo = toDate.Text;
            var customerEmail = email.Text;
            var reportType = soaType.SelectedValue;
            var res = cusDao.GetCustomerSao(dateFrom, dateTo, customerEmail, reportType);
            if (reportType.Equals("soaDetail"))
            {
                SoaDetail(res, sb);
            }
            else
            {
                SoaSummary(res, sb);
            }

        }

        private void SoaDetail(DataSet res, StringBuilder sb)
        {
            SoaDetailDiv.Visible = true;
            SoaSummaryDiv.Visible = false;

            if (res == null || res.Tables.Count.Equals("0") || res.Tables[0].Rows.Count <= 0)
            {
                sb.Append("<tr><td colspan='8' style='text-align:center'>No Records Found </td></tr>");
                tblSoaDetail.InnerHtml = sb.ToString();
                return;
            }

            foreach (DataRow item in res.Tables[0].Rows)
            {
                sb.Append("<tr>");
                sb.Append("<td>" + item["controlNo"].ToString() + "</td>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["cAmt"].ToString()) + "</td>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["tAmt"].ToString()) + "</td>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["pAmt"].ToString()) + "</td>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["serviceCharge"].ToString()) + "</td>");
                sb.Append("<td>" + item["senderName"].ToString() + "</td>");
                sb.Append("<td>" + item["receiverName"].ToString() + "</td>");
                sb.Append("<td>" + item["createdDate"].ToString() + "</td>");
                sb.Append("</tr>");
            }
            tblSoaDetail.InnerHtml = sb.ToString();
        }
        private void SoaSummary(DataSet res, StringBuilder sb)
        {
            SoaSummaryDiv.Visible = true;
            SoaDetailDiv.Visible = false;

            if (res == null || res.Tables.Count.Equals("0") || res.Tables[0].Rows.Count <= 0)
            {
                sb.Append("<tr><td colspan='5' style='text-align:center'>No Records Found </td></tr>");
                tblSoaSummary.InnerHtml = sb.ToString();
                return;
            }

            foreach (DataRow item in res.Tables[0].Rows)
            {
                sb.Append("<tr>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["cAmt"].ToString()) + "</td>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["tAmt"].ToString()) + "</td>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["pAmt"].ToString()) + "</td>");
                sb.Append("<td style='text-align:right'>" + GetStatic.ShowDecimal(item["serviceCharge"].ToString()) + "</td>");
                sb.Append("<td>" + item["createdDate"].ToString() + "</td>");
                sb.Append("</tr>");
            }
            tblSoaSummary.InnerHtml = sb.ToString();
        }
    }
}