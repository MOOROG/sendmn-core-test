using Swift.DAL.AccountReport;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

namespace Swift.web.AccountReport.DayBook {
  public partial class dayBookReport : System.Web.UI.Page {
    private string vName = null;
    private string fromDate = null;
    private string toDate = null;
    private string voucherType = null;
    private SwiftLibrary _sl = new SwiftLibrary();
    private DayBookReportDAO st = new DayBookReportDAO();
    private readonly RemittanceDao obj = new RemittanceDao();

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        _sl.CheckSession();
        GenerateDayBookReport("All", "all");
        ddlShowAgent.Items.Clear();
        string sql = "SELECT agentName, agentId agentCode FROM agentMaster WHERE routingCode is null and parentId != 0";
        DataSet ds = obj.ExecuteDataset(sql);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach (DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["agentCode"].ToString();
            listItem.Text = row["agentName"].ToString();
            ddlShowAgent.Items.Add(listItem);
          }
        }
        ddlShowAgent.Items.Insert(0, new ListItem("Select Agent", "all"));
      }
    }

    protected string FromDate() {
      return GetStatic.ReadQueryString("startDate", "");
    }

    protected string ToDate() {
      return GetStatic.ReadQueryString("endDate", "");
    }

    protected string VoucherType() {
      return GetStatic.ReadQueryString("vType", "");
    }

    protected string VoucherName() {
      return GetStatic.ReadQueryString("vName", "");
    }

    private void GenerateDayBookReport(string showType, string agentType) {
      fromDate = FromDate();
      toDate = ToDate();
      voucherType = VoucherType();
      vName = VoucherName();
      if (agentType.Equals("all"))
        agentType = null;

      var dt = st.GetDayBookReport(fromDate, toDate, voucherType, agentType, showType);
      if (dt == null || dt.Rows.Count == 0) {
        dayBook.InnerHtml = "<td nowrap='nowrap' colspan='6' align='center' >Record Not Found ! </td>";
        return;
      }

      var sb = new StringBuilder();
      double AmountTotal = 0;
      int sNo = 1;

      foreach (DataRow item in dt.Rows) {
        sb.AppendLine("<tr>");
        AmountTotal += GetStatic.ParseDouble(item["amount"].ToString());

        string vNumber = item["Voucher"].ToString();
        string vNumLink = "";
        if (!item["Voucher"].ToString().Equals("999999999")) {
          vNumLink = "<a href='../../BillVoucher/VoucherReport/VoucherReportDetails.aspx?typeDDL=" + item["tran_type"].ToString() + "&vNum=" + item["Voucher"].ToString() + "&vText=" + vName;
          vNumLink += "&type=trannumber&trn_date=" + item["tran_date"].ToString() + "&tran_num=" + item["Voucher"].ToString() + "' title='Voucher Detail' >";
          vNumLink += vNumber + "</a>";
        } else {
          vNumLink = item["Voucher"].ToString();
        }

        sb.AppendLine("<td nowrap='nowrap' align='center' >" + sNo + " </td>");
        sb.AppendLine("<td nowrap='nowrap' >" + vNumLink + "</td>");
        sb.AppendLine("<td nowrap='nowrap'>" + GetStatic.GetVoucherName(item["tran_type"].ToString()) + " </td>");
        sb.AppendLine("<td nowrap='nowrap' >" + item["acc_num"] + " </td>");
        sb.AppendLine("<td nowrap='nowrap'>" + item["acct_name"] + " </td>");
        sb.AppendLine("<td nowrap='nowrap'>" + item["tran_date"] + " </td>");
        sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["amount"].ToString()) + " </td>");

        sb.AppendLine("</tr>");
        sNo++;
      }

      dayBook.InnerHtml = sb.ToString();
      totalBalance.Text = GetStatic.ShowDecimal(AmountTotal.ToString());
    }

    protected void pdf_Click(object sender, EventArgs e) {
      GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
    }

    protected void ddlShowAll_SelectedIndexChanged(object sender, EventArgs e) {
      GenerateDayBookReport(ddlShowAll.SelectedValue, ddlShowAgent.SelectedValue);
    }
    protected void ddlShowAgent_SelectedIndexChanged(object sender, EventArgs e) {
      GenerateDayBookReport(ddlShowAll.SelectedValue, ddlShowAgent.SelectedValue);
    }
  }
}