﻿using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.Reports.CancelReport
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40121900";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
            PopulateDdl();
        }

        private void Authenticate()
        {
            RemittanceLibrary sl = new RemittanceLibrary();
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            StaticDataDdl sdd = new StaticDataDdl();
            sdd.SetDDL3(ref pCountry, "EXEC proc_sendPageLoadData @flag='pCountry',@countryId=" + sdd.FilterString(GetStatic.GetCountryId()) + ",@agentid=" + sdd.FilterString(GetStatic.GetAgentId()), "countryName", "countryName", "", "");
            if (GetStatic.GetUserType() == "AB")
                sdd.SetDDL3(ref sBranch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "");
            else
                sdd.SetDDL3(ref sBranch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "All");
        }
    }
}