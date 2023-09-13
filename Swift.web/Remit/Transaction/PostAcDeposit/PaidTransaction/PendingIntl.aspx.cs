using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using Swift.DAL.BL.ThirdParty.BankDeposit;

namespace Swift.web.Remit.Transaction.PostAcDeposit.PaidTransaction {
  public partial class PendingIntl : System.Web.UI.Page {
    private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
    private readonly PayAcDepositDao _obj = new PayAcDepositDao();
    private const string ViewFunctionId = "20122500";
    private string _tranNo = "";
    protected void Page_Load(object sender, EventArgs e) {
      _swiftLibrary.CheckSession();
      if (!IsPostBack) {
        Authenticate();
        GetStatic.PrintMessage(Page);
        hdnPAgent.Value = GetStatic.ReadQueryString("pAgent", "");
        hdnPAgentName.Value = GetStatic.ReadQueryString("pAgentName", "");
        lblBankName.Text = hdnPAgentName.Value;
        LoadGrid();
      }
      GetStatic.ResizeFrame(Page);
      _tranNo = (Request.Form["chkId"] ?? "").ToString();
    }

    private void LoadGrid() {
      string fromDate = GetStatic.ReadQueryString("fromDate", "");
      string toDate = GetStatic.ReadQueryString("toDate", "");
      string fromTime = GetStatic.ReadQueryString("fromTime", "");
      string toTime = GetStatic.ReadQueryString("toTime", "");
      var ds = _obj.GetPendingPostIntl(GetStatic.GetUser(), hdnPAgent.Value, fromDate, toDate, fromTime, toTime);
      if (ds == null)
        return;
      var dt = ds.Tables[0];
      int cols = dt.Columns.Count;
      var totalRec = 0;
      int cnt = 0;
      var totalAmt = 0.00;
      var str = new StringBuilder("<b>No of Records: [[totalRec]]</b>");
      str.Append("<table class='table table-responsive table-bordered table-striped'>");
      str.Append("<tr>");
      str.Append("<th><a href=\"javascript:void(0);\" onClick=\"CheckAll(this)\">√|×</a></th>");
      for (int i = 2; i < cols; i++) {
        str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
      }
      str.Append("</tr>");
      if (ds.Tables[0].Rows.Count == 0) {
        str.Append("<tr><td colspan='15'><b>No Record Found</td></b></tr>");
      } else {
        foreach (DataRow dr in dt.Rows) {
          str.AppendLine(++cnt % 2 == 1
                                  ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                  : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
          str.Append("<td align=\"center\">");
          if (dr["isApi"].ToString() == "N")
            str.Append("<input type='checkbox' id = \"chk_" + dr["Tran No"] + "\" name = \"chkId\" value='" + dr["Tran No"] + "' /></td>");
          else
            str.Append("</td>");
          for (int i = 2; i < cols; i++) {
            if (i == 9) {
              str.Append("<td align=\"left\"><a href=\"PayIntl.aspx?pAgentName=" + hdnPAgentName.Value + "&tranId="
                  + dr["Tran No"] + "&isApi=" + dr["isApi"] + "&rowId=" + dr["rowId"] + "&pAgent=" + hdnPAgent.Value
                  + "&fromDate=" + fromDate + "&toDate=" + toDate + "&fromTime=" + fromTime + "&toTime=" + toTime + "\">" + dr[i] + "</a></td>");
            } else if (i == 11)
              str.Append("<td style=\"text-align:right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</td>");
            else {
              if (i == 12) {
                if (int.Parse(dr[i].ToString()) > 10) {
                  str.Append("<td align=\"right\" bgcolor=\"#F5B7B1\">" + dr[i].ToString() + "</td>");
                } else {
                  str.Append("<td align=\"right\">" + dr[i] + "</td>");
                }
              } else if (i == 2) {
                str.Append("<td align=\"left\"><a href=\"/Remit/Transaction/Modify/ModifyTran.aspx?tranNo=" + dr["Control No"] + "\">" + dr[i] + "</a></td>");
              } else {
                str.Append("<td align=\"left\">" + dr[i] + "</td>");
              }
              //str.Append("<td align=\"left\">" + dr[i] + "</td>");
            }
          }
          str.Append("</tr>");
          totalRec++;
          totalAmt += double.Parse(dr[11].ToString());
        }
        str.Append("<tr><td colspan=\"10\" style=\"text-align:right\"><b>Total Amount<b></td><td style=\"text-align:right\"><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td></tr>");
      }
      str.Append("</table>");
      result.Visible = true;
      rpt_grid.InnerHtml = str.ToString().Replace("[[totalRec]]", totalRec.ToString());
    }

    private void Authenticate() {
      _swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    protected void btnPaidTxn_Click(object sender, EventArgs e) {
      if (!isRefresh) {
        PayAcDeposit("Y");
      }
    }

    private void PayAcDeposit(string IsHoPaid) {
      var tranArr = _tranNo.Split(',');

      if (tranArr.Length > Convert.ToInt32(GetStatic.ReadWebConfig("payTxnCount", "10"))) {
        GetStatic.AlertMessage(this, "You can not proceed txn more than limit : " + GetStatic.ReadWebConfig("payTxnCount", "10"));
        return;
      }

      // var dbResult = _obj.PayIntl(GetStatic.GetUser(), _tranNo, hdnPAgent.Value, IsHoPaid);

      IBankDepositDao _dao = new BankDepositDao();
      var dbResult = _dao.PayBankDeposit(GetStatic.GetUser(), tranArr);
      GetStatic.PrintMessage(Page, dbResult);
      LoadGrid();
    }

    #region Browser Refresh
    private bool refreshState;
    private bool isRefresh;

    protected override void LoadViewState(object savedState) {
      object[] AllStates = (object[])savedState;
      base.LoadViewState(AllStates[0]);
      refreshState = bool.Parse(AllStates[1].ToString());
      if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
        isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
    }

    protected override object SaveViewState() {
      Session["ISREFRESH"] = refreshState;
      object[] AllStates = new object[3];
      AllStates[0] = base.SaveViewState();
      AllStates[1] = !(refreshState);
      return AllStates;
    }
    #endregion
  }
}
