using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class SendmnB2B : System.Web.UI.Page {
    public List<string> photoPreview = new List<string> { "", "" };
    protected void Page_Load(object sender, EventArgs e) {
      if (Request.Form[hdnCurrentTab.UniqueID] != null) {
        hdnCurrentTab.Value = Request.Form[hdnCurrentTab.UniqueID];
      } else {
        hdnCurrentTab.Value = "menu";
      }
    }
  }
}