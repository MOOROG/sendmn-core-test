using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class BlacklistedAccountsAdd : System.Web.UI.Page {
    private const string AddFunctionId = "40120001";
    private const string AddFunctionIdAgent = "40120001";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao rDao = new RemittanceDao();
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();

        long cusid = GetStatic.ReadNumericDataFromQueryString("id");
        if (cusid > 0)
          PopulateData(cusid);

      }
    }
    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));
    }

    private void PopulateData(long cusid) {
      string sql = "SELECT TOP(1) * FROM blacklistedaccounts WHERE id = " + rDao.FilterString(cusid.ToString());
      DataRow dr = rDao.ExecuteDataRow(sql);

      if (dr != null) {
        hidCusid.Value = dr["id"].ToString();
        account_number.Text = dr["account_number"].ToString();
        bankname.Text = dr["bankname"].ToString();
        amount.Text = dr["amount"].ToString();
        receiverName.Text = dr["receiverName"].ToString();
        if (!dr["close_date"].ToString().Equals(""))
          close_date.Text = DateTime.Parse(dr["close_date"].ToString()).ToString("yyyy-MM-dd");
        description.Text = dr["description"].ToString();
        senderName.Text = dr["senderName"].ToString();
        senderPhone.Text = dr["senderPhone"].ToString();
        receiverPhone.Text = dr["receiverPhone"].ToString();
        senderBankName.Text = dr["senderBankName"].ToString();
        senderAccountNumber.Text = dr["senderAccountNumber"].ToString();
        tnxAgentName.Text = dr["tnxAgentName"].ToString();
        if (!dr["tnxDate"].ToString().Equals(""))
          tnxDate.Text = DateTime.Parse(dr["tnxDate"].ToString()).ToString("yyyy-MM-dd");
        remainingAmount.Text = dr["remainingAmount"].ToString();
        remainingComment.Text = dr["remainingComment"].ToString();
        tnxControlNo.Text = dr["tnxControlNo"].ToString();

      }
    }
    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    protected void btnRegister_Click(object sender, EventArgs e) {
      BlacklistMdl blMdl = new BlacklistMdl();
      blMdl.cusid = hidCusid.Value;
      blMdl.account_number = account_number.Text;
      blMdl.bankname = bankname.Text;
      blMdl.amount = string.IsNullOrEmpty(amount.Text) ? 0 : Convert.ToDouble(amount.Text);
      blMdl.receiverName = receiverName.Text;
      if (!string.IsNullOrEmpty(close_date.Text))
        blMdl.close_date = DateTime.Parse(close_date.Text);
      blMdl.description = description.Text;
      blMdl.senderName = senderName.Text;
      blMdl.senderPhone = senderPhone.Text;
      blMdl.receiverPhone = receiverPhone.Text;
      blMdl.senderBankName = senderBankName.Text;
      blMdl.senderAccountNumber = senderAccountNumber.Text;
      blMdl.tnxAgentName = tnxAgentName.Text;
      if (!string.IsNullOrEmpty(close_date.Text))
        blMdl.tnxDate = DateTime.Parse(tnxDate.Text);
      blMdl.remainingAmount = string.IsNullOrEmpty(remainingAmount.Text) ? 0 : Convert.ToDouble(remainingAmount.Text);
      blMdl.remainingComment = remainingComment.Text;
      blMdl.tnxControlNo = tnxControlNo.Text;
      string sql = "";
      var jsonObj = Newtonsoft.Json.JsonConvert.SerializeObject(blMdl);
      if (hidCusid.Value.Equals("")) {
        sql = "EXEC [proc_blacklistedAccount] @flg = 'new', @datas = N'" + jsonObj + "'";
      } else {
        sql = "EXEC [proc_blacklistedAccount] @flg = 'edit', @datas = N'" + jsonObj + "'";
      }
      rDao.ExecuteDataset(sql);
      Response.Redirect("BlacklistedAccounts.aspx");
      return;
    }
  }
}