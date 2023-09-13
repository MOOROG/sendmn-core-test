using Newtonsoft.Json;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web.Services;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class NewCashPaymentCode : System.Web.UI.Page {

    private readonly RemittanceDao obj = new RemittanceDao();

    public List<string> photoPreview = new List<string> { "", ""};
    protected void Page_Load(object sender, EventArgs e) {

      string sql = "SELECT * FROM commonCode";
      DataSet ds = obj.ExecuteDataset(sql);
      if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
        foreach (DataRow row in ds.Tables[0].Rows) {
          ListItem listItem = new ListItem();
          listItem.Value = row["code"].ToString();
          listItem.Text = row["message"].ToString();
        }
      }

    }

    protected void btnRegister_Click(object sender, EventArgs e) {
      //string custRegNum = regNum.Text;
      string custRegNum = String.Concat(regNum.Text.Where(c => !Char.IsWhiteSpace(c)));
      string custBank = bank.SelectedValue;
      string custAccountNo = accountNo.Text;
      string amount = money.Text;
      string controlNo = controlNumber.Text;
      string sql;

      

      var sql1 = "Select rd from branchCustomer where rd = N'" + custRegNum + "'";
      string retVal = obj.GetSingleResult(sql1);
      if (string.IsNullOrEmpty(retVal)) {
        string custFirstName = firstname.Text;
        string custLastName = lastname.Text;
        string custMobileNum = mobileNum.Text;
        string custAddress = address.Text;

        string custPhoto1 = photo1.FileName != "" ? UploadImage(photo1, custRegNum, "1") : "";
        string custPhoto2 = photo2.FileName != "" ? UploadImage(photo2, custRegNum, "2") : "";

        sql = "INSERT INTO branchCustomer (rd, ovog, ner, hayag, phones,photo1, photo2) VALUES ("
        + (custRegNum != "" ? "N" : "") + obj.FilterString(custRegNum) + ","
        + (custLastName != "" ? "N" : "") + obj.FilterString(custLastName) + ","
        + (custFirstName != "" ? "N" : "") + obj.FilterString(custFirstName) + ","
        + (custAddress != "" ? "N" : "") + obj.FilterString(custAddress) + ","
        + (custMobileNum != "" ? "N" : "") + obj.FilterString(custMobileNum) + ","
        + (custPhoto1 != "" ? "N" : "") + obj.FilterString(custPhoto1) + ","
        + (custPhoto2 != "" ? "N" : "") + obj.FilterString(custPhoto2) + ")";

        obj.ExecuteDataset(sql);
      }

      sql = "INSERT INTO cashPaymentCode (controlNo, register, accountNo, bank, createdDate,amount) VALUES ("
        + (controlNo != "" ? "N" : "") + obj.FilterString(controlNo) + ","
        + (custRegNum != "" ? "N" : "") + obj.FilterString(custRegNum) + ","
        + (custAccountNo != "" ? "N" : "") + obj.FilterString(custAccountNo) + ","
        + (custBank != "" ? "N" : "") + obj.FilterString(custBank) + ","
        + " getDate(),"
        + (amount != "" ? "N" : "") + obj.FilterString(amount) + ")";

      obj.ExecuteDataset(sql);

      DbResult result = new DbResult();
      result.Msg = "Таны хүсэлтийг хүлээн авлаа. Баярлалаа.";
//      ManageMessage(result);
      Response.Redirect("CashPaymentCodeComplete.aspx");
    }

    private void ManageMessage(DbResult dbResult) {
      string mes = GetStatic.ParseResultJsPrint(dbResult);
      mes = mes.Replace("<center>", "");
      mes = mes.Replace("</center>", "");

      string scriptName = "CallBack";
      string functionName = "CallBack('" + mes + "');";
      GetStatic.CallBackJs1(Page, scriptName, functionName);

      // Page.ClientScript.RegisterStartupScript(this.GetType(), "Done", "<script language = \"javascript\">return CallBack('" + mes + "')</script>");
    }

    public string UploadImage(FileUpload doc, string regNum, string photoId) {
      try {
        string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
        string folderPath = GetStatic.ReadWebConfig("customerIdsDocPath", "E:\\customerIds");
        if (!Directory.Exists(folderPath))
          Directory.CreateDirectory(folderPath);
        string fileName = regNum + "-" + photoId + fileExtension;
        string filePath = Path.Combine(folderPath, fileName);
        if (File.Exists(filePath)) {
          File.Delete(filePath);
        }
        doc.SaveAs(filePath);
        return fileName;
      } catch (Exception) {
        return "";
      }
    }


  }
}