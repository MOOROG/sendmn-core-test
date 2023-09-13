using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.ExchangeSystem;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class List : System.Web.UI.Page {
    protected const string GridName = "grid_rate";
    private const string ViewFunctionId = "20230103";
    private const string ViewFunctionIdAgent = "40120000";

    private ExchangeDao rm = new ExchangeDao();
    private readonly StaticDataDdl sdd = new StaticDataDdl();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

    private string _popUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
    public string PopUpParam {
      set { _popUpParam = value; }
      get { return _popUpParam; }
    }

    private string _approveText = "<img alt = \"View Changes\" border = \"0\" title = \"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" /> ";
    public string ApproveText {
      set { _approveText = value; }
      get { return _approveText; }
    }

    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
        GetStatic.PrintMessage(Page);
        LoadGrid();
      }

    }

    private void LoadGrid() {
      var ds = rm.RateListLoadGrid("rateUpdate",GetStatic.GetUser(),"", "1", "10", "id", "DESC");
      var dt = ds.Tables[1];
      var html = new StringBuilder();
      html.Append("<div class=\"table table-responsive\">");
      html.Append("<table class=\"table table-responsive table-bordered table-striped\">");
      html.Append("<tr class=\"hdtitle\">");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>S.N.</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>Rate</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\" colspan='2'><center>Buy</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\" colspan='2'><center>Sale</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"></th>");
      html.Append("</tr>");

      var i = 0;
      int cnt = 0;
      foreach(DataRow dr in dt.Rows) {
        cnt = cnt + 1;
        var id = Convert.ToInt32(dr["id"]);
        html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ");\" class=\"oddbg\" onmouseover=\"if(this.className=='oddbg'){this.className='GridOddRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){} else{this.className='oddbg'}\">" : "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ");\" class=\"evenbg\" onmouseover=\"if(this.className=='evenbg'){this.className='GridEvenRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){}else{this.className='evenbg'}\">");
        html.Append("<td><center>" + cnt + "</center></td>");
        html.Append("<td><center>" + dr["quoteCurreny"] + "</center></td>");
        html.Append("<td><center>" + GetStatic.ParseDouble(dr["buyRate"].ToString()) + "</center></td>");
        html.Append("<td class=\"tdPay\"><center><input class='form-control' onkeyup=\"amountKeyup(event);\" type=\"text\" id = \"buyRate_" + id + "\" value=\"\"/>" + "</center></td>");
        html.Append("<td><center>" + GetStatic.ParseDouble(dr["saleRate"].ToString()) + "</td>");
        html.Append("<td class=\"tdPay\"><center><input class='form-control' onkeyup=\"amountKeyup(event);\" type=\"text\" id = \"saleRate_" + id + "\" value=\"\"/>" + "</center></td>");

        html.Append("<td nowrap='nowrap'>");
        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" disabled=\"disabled\" class=\"buttonDisabled btn btn-primary\" onclick=\"UpdateRate(" + id + ");\" title = \"Confirm Update\" value=\"Update\" />");
        html.Append("</td>");
        html.Append("</tr>");
      }

      html.Append("</table>");
      html.Append("</div>");
      rpt_rate.InnerHtml = html.ToString();
    }

    protected void btnUpdate_Click(object sender, EventArgs e) {
      var dbResult = rm.NubiaRateUpdate("update",GetStatic.GetUser(), rateId.Value, buy.Value,sale.Value);
      ManageMessage(dbResult);
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      if(dbResult.ErrorCode == "0") {
        Response.Redirect("List.aspx");
      }
      GetStatic.PrintMessage(Page);
    }
    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }


  }
}