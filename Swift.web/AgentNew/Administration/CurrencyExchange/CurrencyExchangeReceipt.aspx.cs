using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class CurrencyExchangeReceipt : System.Web.UI.Page {

    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();
    private const string ViewFunctionId = "20230104";
    private const string ViewFunctionIdAgent = "20230104";
    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("id");
    }

    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
        PopulateDataById();
      }
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionId, ViewFunctionIdAgent));
    }
    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    private void PopulateDataById() {
      string sql = "EXEC [proc_currencyExchange] @flag = 'receipt', @id = " +obj.FilterString(GetId().ToString());
      DataRow dr = obj.ExecuteDataRow(sql);
      if(dr != null) {
        lastnameVal.Text = dr["ovog"].ToString();
        firstnameVal.Text = dr["ner"].ToString();
        mobileVal.Text = dr["phones"].ToString();
        controlNo.Text = dr["controlNo"].ToString();
        regVal.Text = dr["rd"].ToString();
        cCurVal.Text = dr["cCurr"].ToString();
        pCurVal.Text = dr["pCurr"].ToString().Trim();
        cTypeVal.Text = dr["paymentMode"].ToString();
        pTypeVal.Text = dr["paymentMode"].ToString();
        cAmountVal.Text = dr["cAmt"].ToString();
        pAmountVal.Text = dr["pAmt"].ToString();
        cRateVal.Text = dr["cRate"].ToString();
        pRateVal.Text = dr["pRate"].ToString();
        lastnameVal2.Text = lastnameVal.Text;
        firstnameVal2.Text = firstnameVal.Text;
        mobileVal2.Text = mobileVal.Text;
        controlNo2.Text = controlNo.Text;
        regVal2.Text = regVal.Text;
        cCurVal2.Text = cCurVal.Text;
        pCurVal2.Text = pCurVal.Text;
        cTypeVal2.Text = cTypeVal.Text;
        pTypeVal2.Text = pTypeVal.Text;
        cAmountVal2.Text = cAmountVal.Text;
        pAmountVal2.Text = pAmountVal.Text;
        cRateVal2.Text = cRateVal.Text;
        pRateVal2.Text = pRateVal.Text;
      }
    }

  }
}