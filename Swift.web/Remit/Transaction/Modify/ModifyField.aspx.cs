using Newtonsoft.Json;
using Swift.API.Common.BankDeposit;
using Swift.API.ThirdPartyApiServices.DAL_BankDeposit;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.System.Utility;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Transaction.Modify {
  public partial class ModifyField : Page {
    private readonly StaticDataDdl sd = new StaticDataDdl();
    private RemittanceLibrary sl = new RemittanceLibrary();
    private readonly ModifyTransactionDao mtd = new ModifyTransactionDao();
    protected IBankDepositService _serviceAPI;

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        sl.CheckSession();
        DisplayLabel();
        lblOldValue.Text = getOldValue();

        if (getFieldName() == "rIdType" || getFieldName() == "sIdType") {
          rptShowOther.Visible = true;
          PopulateDll(getFieldName());
          ddlNewValue.Visible = true;
          txtNewValue.Visible = false;
          rptName.Visible = false;
          txtContactNo.Visible = false;
        } else if (getFieldName() == "sContactNo" || getFieldName() == "rContactNo") {
          rptShowOther.Visible = true;
          txtNewValue.Visible = false;
          txtContactNo.Visible = true;
          rptName.Visible = false;
          ddlNewValue.Visible = false;
        } else if (getFieldName() == "receiverName" || getFieldName() == "senderName") {
          rptName.Visible = true;
          rptShowOther.Visible = false;
        } else {
          rptShowOther.Visible = true;
          txtNewValue.Visible = true;
          ddlNewValue.Visible = false;
          rptName.Visible = false;
          txtContactNo.Visible = false;
        }
      }
    }

    private void DisplayLabel() {
      if (getFieldName() == "rIdType")
        lblFieldName.Text = "Receiver Id Type";
      else if (getFieldName() == "sIdType")
        lblFieldName.Text = "Sender Id Type";
      else if (getFieldName() == "receiverName")
        lblFieldName.Text = "Receiver Name";
      else if (getFieldName() == "senderName")
        lblFieldName.Text = "Sender Name";
      else if (getFieldName() == "sAddress")
        lblFieldName.Text = "Sender Address";
      else if (getFieldName() == "rAddress")
        lblFieldName.Text = "Receiver Address";
      else if (getFieldName() == "rContactNo")
        lblFieldName.Text = "Receiver Contact Number";
      else if (getFieldName() == "sContactNo")
        lblFieldName.Text = "Sender Contact Number";
      else if (getFieldName() == "rIdNo")
        lblFieldName.Text = "Receiver Id No";
      else if (getFieldName() == "sIdNo")
        lblFieldName.Text = "Sender Id No";
    }

    private string GetLabel() {
      return GetStatic.ReadQueryString("label", "");
    }

    private string getFieldName() {
      return GetStatic.ReadQueryString("fieldName", "");
    }

    private string getOldValue() {
      return GetStatic.ReadQueryString("oldValue", "");
    }

    protected long GetTranId() {
      return GetStatic.ReadNumericDataFromQueryString("tranId");
    }

    private void PopulateDll(string fieldName) {
      if (fieldName == "rIdType")
        sd.SetDDL(ref ddlNewValue, "EXEC proc_online_dropDownList @flag = 'idType', @user = '" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
      else if (fieldName == "sIdType")
        sd.SetDDL2(ref ddlNewValue, "EXEC proc_countryIdType @flag = 'il', @countryId='151', @spFlag = '5201'", "detailTitle", "", "Select");
    }

    protected void btnUpdate_Click(object sender, EventArgs e) {
      OnUpdate();
    }

    private void OnUpdate() {
      DbResult dbResult = mtd.UpdateTransaction(GetStatic.GetUser()
                                         , GetTranId().ToString()
                                         , getFieldName()
                                         , getOldValue()
                                         , txtNewValue.Text
                                         , ddlNewValue.Text
                                         , txtFirstName.Text
                                         , txtMiddleName.Text
                                         , txtLastName1.Text
                                         , txtLastName2.Text
                                         , txtContactNo.Text
                                         , GetStatic.GetIsApiFlag()
                                         , GetStatic.GetSessionId()
                                         );

      ManageMessage(dbResult);
    }

    private void ManageMessage(DbResult dbResult) {
      var res = JsonConvert.SerializeObject(dbResult);
      //var mes = GetStatic.ParseResultJsPrint(dbResult);
      //mes = mes.Replace("<center>", "");
      //mes = mes.Replace("</center>", "");

      var scriptName = "CallBack";
      var functionName = "CallBack('" + res + "');";
      GetStatic.CallBackJs1(Page, scriptName, functionName);
    }
  }
}