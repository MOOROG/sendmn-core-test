using Swift.DAL.ExchangeSystem.LedgerSetup;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;

namespace Swift.web.AccountSetting.MoveLedger
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150400";
        private SwiftLibrary _sl = new SwiftLibrary();
        private LedgerDao _obj = new LedgerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                PopulateData();
            }
        }

        private void PopulateData()
        {
            string sql = "EXEC PROC_DROPDOWNLIST @FLAG='ledgerMove'";
            _sl.SetDDL(ref ledgerInfo1, sql, "gl_code", "gl_name", "", "Select");
            _sl.SetDDL(ref ledgerInfo2, sql, "gl_code", "gl_name", "", "Select");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void ledgerInfo1_SelectedIndexChanged(object sender, EventArgs e)
        {
            string id = ledgerInfo1.SelectedValue;
            DataTable dt = _obj.GetLedgerDetails(id);
            if (dt == null || dt.Rows.Count == 0)
            {
                ledgerInfoDetail1.Items.Clear();
                return;
            }
            BindData(dt);
        }

        protected void ledgerInfo2_SelectedIndexChanged(object sender, EventArgs e)
        {
            string id = ledgerInfo2.SelectedValue;
            DataTable dt = _obj.GetLedgerDetails(id);
            if (dt == null || dt.Rows.Count == 0)
            {
                ledgerInfoDetail2.Items.Clear();
                return;
            }
            BindData1(dt);
        }

        private void BindData1(DataTable dt)
        {
            List<ListItem> ledger = new List<ListItem>();
            foreach (DataRow dr in dt.Rows)
            {
                ledger.Add(new ListItem(dr["acct_name"].ToString(), dr["acct_num"].ToString()));
            }
            ledgerInfoDetail2.DataTextField = "Text";
            ledgerInfoDetail2.DataValueField = "Value";
            ledgerInfoDetail2.DataSource = ledger;
            ledgerInfoDetail2.DataBind();
            hdn2.Value = ledgerInfoDetail2.Items.Count.ToString();
        }

        private void BindData(DataTable dt)
        {
            List<ListItem> ledger = new List<ListItem>();
            foreach (DataRow dr in dt.Rows)
            {
                ledger.Add(new ListItem(dr["acct_name"].ToString(), dr["acct_num"].ToString()));
            }
            ledgerInfoDetail1.DataTextField = "Text";
            ledgerInfoDetail1.DataValueField = "Value";
            ledgerInfoDetail1.DataSource = ledger;
            ledgerInfoDetail1.DataBind();
            hdn1.Value = ledgerInfoDetail1.Items.Count.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string fromId = "";
            string toId = "";

            string rightSelectedItems = Request.Form[ledgerInfoDetail2.UniqueID];
            ledgerInfoDetail2.Items.Clear();
            if (!string.IsNullOrEmpty(rightSelectedItems))
            {
                foreach (string item in rightSelectedItems.Split(','))
                {
                    ledgerInfoDetail2.Items.Add(item);
                }
            }
            toId = ledgerInfo2.SelectedValue;
            fromId = ledgerInfo1.SelectedValue;
            if (string.IsNullOrEmpty(toId))
            {
                ledgerInfoDetail2.Items.Clear();
                GetStatic.AlertMessage(this, "Sorry Operation Terminates!!! \n You have not selected any ledgers to move.");
                return;
            }
            else if (string.IsNullOrEmpty(rightSelectedItems))
            {
                GetStatic.AlertMessage(this, "Sorry Operation Terminates!!! \n You have not moved any accounts.");
                return;
            }
            var dr = _obj.DoLedgerMovement(fromId, toId, rightSelectedItems);
            ledgerInfo1_SelectedIndexChanged(this, EventArgs.Empty);
            ledgerInfoDetail2.Items.Clear();
            GetStatic.AlertMessage(this, dr.Msg);
            return;
        }
    }
}