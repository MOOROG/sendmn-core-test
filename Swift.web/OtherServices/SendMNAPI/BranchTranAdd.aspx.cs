using Newtonsoft.Json;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class BranchTranAdd : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "20111300";
    private const string AddFunctionId = "20111310";
    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";
    private RemittanceDao rDao = new RemittanceDao();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    string custId = "";
    string rwId = "";
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      custId = GetStatic.ReadQueryString("customerId", "");
      rwId = GetStatic.ReadQueryString("id", "");
      hidCusid.Value = custId;
      if (!rwId.Equals(""))
        populateFields();
    }
    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }
    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    private void populateFields() {
      if (!IsPostBack) {
        string sql = "EXEC [proc_branchTransaction] @flg = 'edit',@id = " + rwId;
        DataSet ds = rDao.ExecuteDataset(sql);
        if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
          return;
        DataRow dr = ds.Tables[0].Rows[0];
        inOut.SelectedValue = dr["inOut"].ToString();
        systemName.SelectedValue = dr["systemName"].ToString();
        controlNumber.Text = dr["controlNumber"].ToString();
        recSendLastname.Text = dr["recSendLastname"].ToString();
        recSendName.Text = dr["recSendName"].ToString();
        receivedCurrency.SelectedValue = dr["receivedCurrency"].ToString();
        receivedAmount.Text = dr["receivedAmount"].ToString();
        rate.Text = dr["rate"].ToString();
        gaveCurrency.SelectedValue = dr["gaveCurrency"].ToString();
        gaveAmount.Text = dr["gaveAmount"].ToString();
        tranType.Text = dr["tranType"].ToString();
        gaveTookAmount.Text = dr["gaveTookAmount"].ToString();
        serviceFee.Text = dr["serviceFee"].ToString();
        sendRecLastName.Text = dr["sendRecLastName"].ToString();
        sendRecName.Text = dr["sendRecName"].ToString();
        country.Text = dr["country"].ToString();
        hidCusid.Value = dr["customerId"].ToString();
        rwId = dr["id"].ToString();
      }
    }

    protected void btnRegister_Click(object sender, EventArgs e) {
      BranchTransactionMdl btmdl = new BranchTransactionMdl();
      btmdl.inOut = inOut.SelectedValue;
      btmdl.systemName = systemName.SelectedValue;
      btmdl.controlNumber = controlNumber.Text;
      btmdl.recSendLastname = recSendLastname.Text;
      btmdl.recSendName = recSendName.Text;
      btmdl.receivedCurrency = receivedCurrency.SelectedValue;
      btmdl.receivedAmount = receivedAmount.Text;
      btmdl.rate = rate.Text;
      btmdl.gaveCurrency = gaveCurrency.SelectedValue;
      btmdl.gaveAmount = gaveAmount.Text;
      btmdl.tranType = tranType.Text;
      btmdl.gaveTookAmount = gaveTookAmount.Text;
      btmdl.serviceFee = serviceFee.Text;
      btmdl.sendRecLastName = sendRecLastName.Text;
      btmdl.sendRecName = sendRecName.Text;
      btmdl.country = country.Text;
      btmdl.operatorName = GetStatic.GetUser();
      btmdl.customerId = hidCusid.Value;
      string sql = "";
      if (rwId.Equals("")) {
        string jsonString = JsonConvert.SerializeObject(btmdl);
        sql = "EXEC [proc_branchTransaction] @flg = 'new',@user = '" + btmdl.operatorName + "', @datas = N'" + jsonString + "'";
      } else {
        btmdl.id = Convert.ToInt32(rwId);
        string jsonString = JsonConvert.SerializeObject(btmdl);
        sql = "EXEC [proc_branchTransaction] @flg = 'update',@user = '" + btmdl.operatorName + "', @datas = N'" + jsonString + "'";
      }
      rDao.ExecuteDataset(sql);
      var dbResult = new DbResult { ErrorCode = "", Msg = "DONE" };
      GetStatic.SetMessage(dbResult);
      Response.Redirect("BranchTransaction.aspx");
    }
  }

  public class BranchTransactionMdl {
    public int id { get; set; }
    public string inOut { get; set; }
    public string systemName { get; set; }
    public string controlNumber { get; set; }
    public string recSendLastname { get; set; }
    public string recSendName { get; set; }
    public string receivedCurrency { get; set; }
    public string receivedAmount { get; set; }
    public string rate { get; set; }
    public string gaveCurrency { get; set; }
    public string gaveAmount { get; set; }
    public string tranType { get; set; }
    public string gaveTookAmount { get; set; }
    public string serviceFee { get; set; }
    public string sendRecLastName { get; set; }
    public string sendRecName { get; set; }
    public string country { get; set; }
    public string operatorName { get; set; }
    public DateTime tranDate { get; set; }
    public string customerId { get; set; }

  }
}