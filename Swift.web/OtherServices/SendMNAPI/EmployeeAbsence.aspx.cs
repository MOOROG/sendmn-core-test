using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class EmployeeAbsence : System.Web.UI.Page {

    private const string ViewFunctionId = "10101300";
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
      }
      string uid = GetStatic.GetUser();
      if (uid.Equals("admin")) {
        rbtnWithoutSal.Visible = true;
        rbtnWithSalary.Visible = true;
      }
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    protected void btnAnnouncement_Click(object sender, EventArgs e) {
        string sql = "INSERT INTO employeeAbsence (uid, reason, fromDt, toDt) VALUES ("
             + obj.FilterString(GetStatic.GetUser()) + ","
             + "N" + obj.FilterString(announcementContent.Text) + ","
             + obj.FilterString(Convert.ToDateTime(announcementDateFrom.Text).ToString("yyyy-MM-dd HH:mm:ss")) + ","
             + obj.FilterString(Convert.ToDateTime(announcementDateTo.Text).ToString("yyyy-MM-dd HH:mm:ss")) + ")";
        obj.ExecuteDataset(sql);
      }
  }
}