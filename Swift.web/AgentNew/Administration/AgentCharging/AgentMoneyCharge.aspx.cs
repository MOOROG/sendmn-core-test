using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.ExchangeSystem;
using Swift.DAL.SwiftDAL;
using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection.Emit;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.AxHost;

namespace Swift.web.AgentNew.Administration.AgentCharging {
  public partial class AgentMoneyCharge : System.Web.UI.Page {

    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    private readonly RemittanceLibrary obj = new RemittanceLibrary();
    private const string ViewFunctionId = "10112203";
    WalletDao _dao = new WalletDao();
    private readonly SwiftLibrary _sl = new SwiftLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
        amountId.Text = "0";
        _sl.SetDDL(ref sendAgent, "exec [SendMnPro_Remit].dbo.[proc_agentMaster] @flag='al6'", "agentId", "agentName", "", "All");
      }
    }

    private void Authenticate() {
      obj.CheckAuthentication(ViewFunctionId);
    }

    //public void PopulateData(DataTable dt) {
    //  DataRow dr = dt.Rows[0];
    //  dateId.Text = dr["mobileNo"].ToString();
    //  AmountId.Text = dr["fullName"].ToString();
    //  amountCurrencyId.Text = dr["fullName"].ToString();
    //  rateId.Text = dr["fullName"].ToString();
    //  sendAgent.SelectedItem.Value = dr["agent_id"].ToString();
    //  sendAgent.SelectedItem.Text = dr["acct_name"].ToString();
    //}

    protected void add_Click(object sender, EventArgs e) {
      string amountCurrency = string.IsNullOrEmpty(amountCurrencyId.Text.Replace(",", "")) ? "0" : amountCurrencyId.Text.Replace(",", "");
      string rate = string.IsNullOrEmpty(rateId.Text.Replace(",", "")) ? "0" : rateId.Text.Replace(",", "");
      if (Convert.ToInt32(amountCurrency) <= 0) {
        GetStatic.AlertMessage(this, "Please Enter Valid Amount ($)!!");
        return;
      } else if (Convert.ToInt32(rate) <= 0) {
        GetStatic.AlertMessage(this, "Please Enter Valid Rate!!");
        return;
      }
      var dbResult = _dao.UploadMoneyInAgentFund(dateId.Text, sendAgent.SelectedItem.Value, sendAgent.SelectedItem.Text, accListId.SelectedValue, amountCurrency, rate, GetStatic.GetUser());
      GetStatic.AlertMessage(this, dbResult.Msg);
      //Response.Redirect("/admin/Dashboard.aspx");
    }

    //private string GetId() {
    //  return GetStatic.ReadQueryString("acct_id", "");
    //}
    //protected void update_Click(object sender, EventArgs e) {
    //  Update();
    //}
    //private void Update() {
    //  string agent = sendAgent.Text;
    //  string amount = amountCurrencyId.Text.Replace(",", "");
    //  string date = dateId.Text;
    //  string rate = rateId.Text.Replace(",", "");
    //  string user = GetStatic.GetUser();
    //  string id = GetId();
    //}

    protected void Acc_SelectedIndexChanged(object sender, EventArgs e) {
      LoadAgentInAccount(ref accListId, sendAgent.Text, "");
      accListId.Focus();
    }

    private void LoadAgentInAccount(ref DropDownList ddl, string agent, string defaultValue) {
      var sql = "EXEC proc_agentMaster @flag = 'agentAcc', @agentId=" + _sdd.FilterString(agent);
      _sdd.SetDDL(ref ddl, sql, "acct_num", "acct_name", defaultValue, "All");
    }
  }
}