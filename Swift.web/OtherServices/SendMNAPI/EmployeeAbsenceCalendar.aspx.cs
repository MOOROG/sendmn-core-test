﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class EmployeeAbsenceCalendar : System.Web.UI.Page {
    protected void Page_Load(object sender, EventArgs e) {
      calendarTxt.Text = DateTime.Now.ToString("yyyy-MM-dd");
    }
  }
}