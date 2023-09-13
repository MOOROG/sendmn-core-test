using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Utilities.ModifyRequest
{
    public partial class TransactionDetail : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40112800";
        protected const string GridName = "grdPenAgntTxnModify";
        private readonly ModifyTransactionDao dao = new ModifyTransactionDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateData();

            }
            GetStatic.ResizeFrame(Page);
        }

        private void PopulateData()
        {
            emailAdd.Text = sl.GetBranchEmail(GetStatic.GetBranch(), GetStatic.GetUser());
            sdd.SetStaticDdl(ref txnmodifyField, "8100", "", "");
            PopulateTransactionDetail();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        protected bool ShowCommentFlag()
        {
            return GetStatic.ReadQueryString("commentFlag", "Y") != "N";
        }

        protected bool ShowBankDetail()
        {
            return (GetStatic.ReadQueryString("showBankDetail", "N") == "Y");
        }

        private void PopulateTransactionDetail()
        {
            string txnId = GetStatic.ReadQueryString("tranId", "");
            string cntNo = GetControlNo();
            if (txnId != "" || cntNo != "")
            {
                ucTran.ShowCommentBlock = ShowCommentFlag();
                ucTran.ShowBankDetail = ShowBankDetail();
                ucTran.SearchData(txnId, cntNo, "", "", "SEARCH", "ADM: VIEW TXN (SEARCH TRANSACTION)");

                if (!ucTran.TranFound)
                {
                    GetStatic.ShowErrorMessage("Transaction Not Found");
                    return;
                }

                if (ucTran.TranStatus != "Payment")
                {
                    GetStatic.ShowErrorMessage("Transaction not authorised for modification; Status:" + ucTran.TranStatus + "!");
                    return;
                }
                divTranDetails.Visible = ucTran.TranFound;
                modtable.Visible = ucTran.TranFound;
                divControlno.Visible = ucTran.TranFound;
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            var modifyField = txnmodifyField.SelectedItem.Text;
            var newValue = "";
            var fieldName = "";
            var fieldValue = "";

            if (modifyField == "Receiver Id Type")
                fieldName = "rIdType";
            else if (modifyField == "Sender Id Type")
                fieldName = "sIdType";
            else if (modifyField == "Receiver Name")
                fieldName = "receiverName";
            else if (modifyField == "Sender Name")
                fieldName = "senderName";
            else if (modifyField == "Sender Address")
                fieldName = "sAddress";
            else if (modifyField == "Receiver Address")
                fieldName = "rAddress";
            else if (modifyField == "Receiver Contact No")
                fieldName = "rContactNo";
            else if (modifyField == "Sender Contact No")
                fieldName = "sContactNo";
            else if (modifyField == "Receiver Id No")
                fieldName = "rIdNo";
            else if (modifyField == "Sender Id No")
                fieldName = "sIdNo";
            else if (modifyField == "Payout Location")
                fieldName = "pAgentLocation";
            else if (modifyField == "Receiver Bank Ac No")
                fieldName = "accountNo";

            if (modifyField == "Sender Name" || modifyField == "Receiver Name")
            {
                newValue = txtFirstName.Text + " " + txtMiddleName.Text + " " + txtFirstLastName.Text + " " + txtSecondLastName.Text;
                fieldValue = "'<root><row firstName = \"" + txtFirstName.Text + "\" middleName = \"" + txtMiddleName.Text + "\" firstLastName = \"" + txtFirstLastName.Text + "\"  secondLastName = \"" + txtSecondLastName.Text + "\"/></root>'";

            }
            else if (modifyField == "Sender Id Type" || modifyField == "Receiver Id Type")
            {
                newValue = idType.SelectedItem.Value;
                fieldValue = newValue;
            }

            else if (modifyField == "Payout Location")
            {
                newValue = idType.SelectedItem.Text;
                fieldValue = idType.SelectedValue;
            }
            else
            {
                newValue = txtValue.Text;
                fieldValue = newValue;
            }
            DataTable dt = dao.TXNReqUpdate(GetStatic.GetUser(), ucTran.CtrlNo, modifyField, newValue, fieldName, fieldValue);
            if (dt.Rows[0][0].ToString() == "0")
            {
                var res = new DbResult();
                res.Msg = dt.Rows[0][1].ToString();
                GetStatic.PrintMessage(Page, res);
            }
            else
                TXNRequestDeatil(dt);
        }

        private void TXNRequestDeatil(DataTable dt)
        {
            if (dt != null && dt.Rows.Count != 0)
            {
                dispRequest.Visible = true;
                StringBuilder sb = new StringBuilder("");
                sb.AppendLine("<table class='table' border='0' cellspacing='0' cellpadding='3'>");
                sb.AppendLine("<tr><th class='frmTitle'>S.N</th><th class='frmTitle'>Comments</th><th class='frmTitle'>Delete</th></tr>");

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    sb.AppendLine("<tr><td>" + (i + 1) + "</td>");
                    sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["message"] + "</td>");
                    sb.AppendLine("<td><img alt='Delete' src='../../../Images/delete.gif' onClick='Delete(" + dt.Rows[i]["rowId"] + ")' />  </td></tr>");
                }
                sb.AppendLine("</table>");
                dispRequest.InnerHtml = sb.ToString();
                return;
            }
            dispRequest.Visible = false;
        }

        protected void btnRequest_Click(object sender, EventArgs e)
        {
            var dbResult = dao.TXNSCchange(GetStatic.GetUser(), ucTran.CtrlNo);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.SetMessage(dbResult);
                GetStatic.AlertMessage(Page);
                return;
            }
            Response.Redirect("Summary.aspx?controlNo=" + ucTran.CtrlNo + "&email=" + emailAdd.Text + "");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DataTable dt = dao.TXNDelete(GetStatic.GetUser(), rowid.Value, ucTran.CtrlNo);
            TXNRequestDeatil(dt);
        }

        protected void txnmodifyField_SelectedIndexChanged(object sender, EventArgs e)
        {
            ChangeTxnModifyField();
        }

        protected void ChangeTxnModifyField()
        {
            var modifyField = txnmodifyField.SelectedItem.Text;
            if (modifyField == "Sender Name" || modifyField == "Receiver Name")
            {
                newValueLabel.Visible = false;
                labelValue.Visible = false;
                nameTable.Visible = true;
            }
            else if (modifyField == "Sender Id Type")
            {
                newValueLabel.Visible = true;
                nameTable.Visible = false;
                labelValue.Visible = false;
                idType.Visible = true;
                sl.SetDDL(ref idType, "EXEC proc_countryIdType @flag = 'il', @countryId='151', @spFlag = '5201'", "valueId", "detailTitle", "", "Select");
            }

            else if (modifyField == "Receiver Id Type")
            {
                newValueLabel.Visible = true;
                nameTable.Visible = false;
                labelValue.Visible = false;
                idType.Visible = true;
                sl.SetDDL(ref idType, "EXEC proc_online_dropDownList @flag='idType',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");

            }
            else if (modifyField == "Payout Location")
            {
                newValueLabel.Visible = true;
                nameTable.Visible = false;
                labelValue.Visible = false;
                idType.Visible = true;
                sl.SetDDL(ref idType, "EXEC proc_apiLocation @flag='l'", "districtCode", "districtName", "", "Select");
            }
            else
            {
                newValueLabel.Visible = false;
                nameTable.Visible = false;
                labelValue.Visible = true;
            }
            txtValue.Text = "";
        }
    }
}