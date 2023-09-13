using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.BL.Remit.Administration;
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

namespace Swift.web.Coupon {
  public partial class Edit : System.Web.UI.Page {
    private const string ViewFunctionId = "10233000";

    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();
    private readonly AdminDao _dao = new AdminDao();
    public string docPath;
    public string photoPreview = "";

    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("id");
    }

    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
        string sql = "exec proc_online_dropDownList @Flag = 'menuModule'";
        DataSet ds = obj.ExecuteDataset(sql);
        if(ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach(DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["Value"].ToString();
            listItem.Text = row["text"].ToString();
            partner.Items.Add(listItem);
          }
        }
      }

      if(GetId() > 0)
        PopulateDataById();
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    private void PopulateDataById() {
      string sql = "SELECT TOP(1) * FROM couponMaster WHERE id = " + obj.FilterString(GetId().ToString());
      DataRow dr = obj.ExecuteDataRow(sql);
      if(dr != null) {
        couponCode.Text = dr["code"].ToString();
        couponName.Text = dr["name"].ToString();
        couponPrice.Text = dr["couponPrice"].ToString();
        couponQuant.Text = dr["couponQuantity"].ToString();
        partner.SelectedValue = dr["partnerId"].ToString();
        startDate.Text = dr["startDate"].ToString();
        endDate.Text = dr["endDate"].ToString();
        discountType.SelectedValue = dr["discountType"].ToString();
        discountAmount.Text = dr["discountAmount"].ToString();
        discountCurrency.Text = dr["discountCurrency"].ToString();
        description.Text = dr["description"].ToString();
        photoPreview = "<p>" + (dr["couponImage"].ToString() != "" ? "<img class='img-responsive' src='" + docPath + "/couponImages/" + dr["couponImage"].ToString() + "'/>" + dr["couponImage"].ToString() : "") + "</p>";
        photoHide.Text = dr["couponImage"].ToString();
        btnRegister.Text = "Save Coupon";
      }
    }

    protected void btnRegister_Click(object sender, EventArgs e) {
      string name = couponName.Text;
      decimal price = Convert.ToDecimal(couponPrice.Text);
      decimal quantity = Convert.ToDecimal(couponQuant.Text);
      string partnerId = partner.SelectedValue;
      DateTime sDate = Convert.ToDateTime(startDate.Text);
      DateTime eDate = Convert.ToDateTime(endDate.Text);
      string discType = discountType.Text;
      decimal amount = Convert.ToDecimal(discountAmount.Text);
      string currency = discountCurrency.Text;
      string desc = description.Text;
      string imgName = photoHide.Text;
      if(photo1.FileName != "") {
        DateTimeOffset date1 = (DateTimeOffset)DateTime.Now;
        imgName = date1.ToUnixTimeMilliseconds().ToString();
        imgName = UploadImage(photo1, imgName);
      }
      DbResult dr = _dao.CouponUpdate(GetId().ToString(),GetStatic.GetUser(), partnerId, name, desc, price, imgName, discType, amount, currency, sDate, eDate, quantity);
      GetStatic.AlertMessage(this, dr.Msg);
      Response.Redirect("List.aspx");
      return;
    }
    public string UploadImage(FileUpload doc, string id) {
      try {
        string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
        string folderPath = GetStatic.ReadWebConfig("couponImagesDocPath", "E:\\couponImages");
        if(!Directory.Exists(folderPath))
          Directory.CreateDirectory(folderPath);
        string fileName = id + "-" + fileExtension;
        string filePath = Path.Combine(folderPath, fileName);
        if(File.Exists(filePath)) {
          File.Delete(filePath);
        }
        doc.SaveAs(filePath);
        return fileName;
      } catch(Exception) {
        return "";
      }
    }
  }
}