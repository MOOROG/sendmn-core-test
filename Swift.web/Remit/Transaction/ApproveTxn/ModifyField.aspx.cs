using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;


namespace Swift.web.Remit.Transaction.ApproveTxn
{
    public partial class ModifyField : System.Web.UI.Page
    {
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly StaticDataDdl sd = new StaticDataDdl();
        private readonly ModifyTransactionDao mtd = new ModifyTransactionDao();
        private const string ViewFunctionId = "20122800";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                DisplayLabel();
                lblOldValue.Text = getOldValue();

                if (getFieldName() == "rIdType" || getFieldName() == "relationship")
                {
                    rptShowOther.Visible = true;
                    PopulateDll(getFieldName());
                    ddlNewValue.Visible = true;
                    txtNewValue.Visible = false;
                    txtContactNo.Visible = false;
                }
                else if (getFieldName() == "rContactNo" || getFieldName() == "rTelNo")
                {
                    rptShowOther.Visible = true;
                    txtNewValue.Visible = false;
                    txtContactNo.Visible = true;
                    ddlNewValue.Visible = false;
                }
                else if (getFieldName() == "receiverName")
                {
                    rptName.Visible = true;
                    rptShowOther.Visible = false;
                }
                else
                {
                    rptShowOther.Visible = true;
                    txtNewValue.Visible = true;
                    ddlNewValue.Visible = false;
                    txtContactNo.Visible = false;
                }
            }
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
        private void DisplayLabel()
        {
            if (getFieldName() == "receiverName")            
                lblFieldName.Text = "Receiver Name";            
            else if (getFieldName() == "rIdType")
                lblFieldName.Text = "Receiver Id Type";
            else if (getFieldName() == "rAddress")
                lblFieldName.Text = "Receiver Address";
            else if (getFieldName() == "rContactNo")
                lblFieldName.Text = "Receiver Contact Number";
            else if (getFieldName() == "rTelNo")
                lblFieldName.Text = "Receiver Telephone Number";
            else if (getFieldName() == "rIdNo")
                lblFieldName.Text = "Receiver Id No";
            else if (getFieldName() == "relationship")
                lblFieldName.Text = "Receiver Relationship With Sender";
        }
        private string getFieldName()
        {
            return GetStatic.ReadQueryString("fieldName", "");
        }
        private string getOldValue()
        {
            return GetStatic.ReadQueryString("oldValue", "");
        }
        protected long GetTranId()
        {
            return GetStatic.ReadNumericDataFromQueryString("tranId");
        }
        private void PopulateDll(string fieldName)
        {
            if (fieldName == "rIdType")
                sd.SetStaticDdl(ref ddlNewValue, "1300", "", "Select");
                //sd.SetDDL2(ref ddlNewValue, "EXEC proc_countryIdType @flag = 'il', @countryId=" + sl.FilterString(GetStatic.GetCountryId()) + ", @spFlag = '5202'", "detailTitle", "", "Select");
            else if (fieldName == "relationship")
                sd.SetStaticDdl(ref ddlNewValue, "2100", "", "Select");
        }
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            OnUpdate();
        }
        private void OnUpdate()
        {
            var ddlVal = getFieldName() == "relationship" ? ddlNewValue.SelectedItem.Text : getFieldName() == "rIdType" ? ddlNewValue.SelectedItem.Text : ddlNewValue.Text;
            DbResult dbResult = mtd.UpdateHoldTransaction(GetStatic.GetUser()
                                               , GetTranId().ToString()
                                               , getFieldName()
                                               , getOldValue()
                                               , txtNewValue.Text
                                               , ddlVal
                                               , txtFirstName.Text
                                               , txtMiddleName.Text
                                               , txtLastName1.Text
                                               , txtLastName2.Text
                                               , txtContactNo.Text
                                               , GetStatic.GetIsApiFlag()
                                               );
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }
    }
}