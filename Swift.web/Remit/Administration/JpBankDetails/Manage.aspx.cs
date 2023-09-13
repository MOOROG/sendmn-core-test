﻿using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.JpBankDetails
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        private const string ViewFunctionId = "20306000";
        protected string AgentId = "";
        protected string BranchId = "";
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txnDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
        private void PopulateData()
        {
            AgentId = GetStatic.GetAgent();
            BranchId = GetStatic.GetBranch();
        }
        private void Authenticate()
        {
            _rl.CheckAuthentication(ViewFunctionId);
        }
    }
}