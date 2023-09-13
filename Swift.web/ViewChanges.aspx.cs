using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup;
using Swift.DAL.BL.System.Notification;

namespace Swift.web
{
    public partial class ViewChanges : System.Web.UI.Page
    {
        RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private ChangeApprovalDao obj = new ChangeApprovalDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            ShowChanges();
        }

        public static string GetFunctionId()
        {
            return GetStatic.ReadQueryString("functionId", "");
        }
        public static string GetFunctionId2()
        {
            return GetStatic.ReadQueryString("functionId2", ""); 
        }
        public static string GetId()
        {
            return GetStatic.ReadQueryString("id", "");
        }
        public static string GetModBy()
        {
            return GetStatic.ReadQueryString("modBy", "");
        }
        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(GetFunctionId2());
        }

        private void ShowChanges()
        {
            if (GetFunctionId() == "20832030")
            {
                string url = GetStatic.GetUrlRoot() + "/Remit/Administration/CustomerSetup/KYC/Manage.aspx?rowId=" +
                             GetId() + "&isApprove=true";
                Response.Redirect(url);
            }
            PrintChanges(GetFunctionId(), GetId());
            if (GetModBy() == GetStatic.GetUser())
            {
                btnApprove.Visible = false;
                btnReject.Visible = false;
                btnApproveUR.Visible = false;
                btnRejectUR.Visible = false;
                btnApproveUF.Visible = false;
                btnRejectUF.Visible = false;
            }
        }

        private void Approve()
        {
            var dbResult = obj.Approve(GetStatic.GetUser(), GetFunctionId(), GetId());
            ManageMessage(dbResult);
        }

        private void Reject()
        {
            var dbResult = obj.Reject(GetStatic.GetUser(), GetFunctionId(), GetId());
            ManageMessage(dbResult);
        }
        private void RejectUR()
        {
            var dbResult = obj.RejectUR(GetStatic.GetUser(), GetFunctionId(), GetId());
            ManageMessage(dbResult);
        }
        private void RejectUF()
        {
            var dbResult = obj.RejectUF(GetStatic.GetUser(), GetFunctionId(), GetId());
            ManageMessage(dbResult);
        }
        protected void btnApprove_Click(object sender, EventArgs e)
        {
            Approve();
        }
        protected void btnApproveUR_Click(object sender, EventArgs e)
        {
            Approve();
        }
        protected void btnApproveUF_Click(object sender, EventArgs e)
        {
            Approve();
        }
        protected void btnReject_Click(object sender, EventArgs e)
        {
            Reject();
        }
        protected void btnRejectUR_Click(object sender, EventArgs e)
        {
            RejectUR();
        }

        protected void btnRejectUF_Click(object sender, EventArgs e)
        {
            RejectUF();
        }
        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "')";
            GetStatic.CallBackJs1(Page, scriptName, functionName);

           // Page.ClientScript.RegisterStartupScript(this.GetType(), "Done", "<script language = \"javascript\">return CallBack('" + mes + "')</script>");
            
        }

        private void PrintChanges(string functionId, string id)
        {
            var dataList = obj.GetChangeList(functionId, id);   //Default
            var oldData = dataList[0];
            var newData = dataList[1];
            var pageName = dataList[2];
            var changeType = dataList[3];

            //User Role
            var oldDataUR = "";
            var newDataUR = "";
            var pageNameUR = "";
            var changeTypeUR = "";
            
            //User Function
            var oldDataUF = "";
            var newDataUF = "";
            var pageNameUF = "";
            var changeTypeUF = "";

            //Rule Criteria
            var oldData1 = "";
            var newData1 = "";
            var pageName1 = "";
            var changeType1 = "";
            
            if(functionId == "10101130" || functionId == "10101330")          //Application User Function Id
            {

                var dataListUR = obj.GetChangeListUR(functionId, id);
                oldDataUR = dataListUR[0];
                newDataUR = dataListUR[1];
                pageNameUR = dataListUR[2];
                changeTypeUR = dataListUR[3];

                var dataListUF = obj.GetChangeListUF(functionId, id);
                oldDataUF = dataListUF[0];
                newDataUF = dataListUF[1];
                pageNameUF = dataListUF[2];
                changeTypeUF = dataListUF[3];
            }

            if(functionId == "20601035" || functionId == "20601135")
            {
                var dataList1 = obj.GetChangeListRC(functionId, id);
                oldData1 = dataList1[0];
                newData1 = dataList1[1];
                pageName1 = dataList1[2];
                changeType1 = dataList1[3];
            }

            DataRow drHead = obj.SelectLogHeadById(functionId, id); //Default
            tableName.Text = pageName;
            logType.Text = changeType;
            dataId.Text = id;
            if (drHead == null)
            {
                logType.Text = "Insert";
            }
            else
            {
                createdDate.Text = drHead["createdDate"].ToString();
                createdBy.Text = drHead["createdBy"].ToString();
            }
            if (functionId == "10101130" || functionId == "10101330")       //Application User Function Id
            {
                DataRow drHeadUR = obj.SelectLogHeadByIdUR(functionId, id);
                tableNameUR.Text = "User Roles";
                dataIdUR.Text = id;
                if (drHeadUR != null)
                {
                    createdDateUR.Text = drHeadUR["createdDate"].ToString();
                    createdByUR.Text = drHeadUR["createdBy"].ToString();
                    logTypeUR.Text = "Update";
                }

                DataRow drHeadUF = obj.SelectLogHeadByIdUF(functionId, id);
                tableNameUF.Text = "User Functions";
                dataIdUF.Text = id;
                if (drHeadUF != null)
                {
                    createdDateUF.Text = drHeadUF["createdDate"].ToString();
                    createdByUF.Text = drHeadUF["createdBy"].ToString();
                    logTypeUF.Text = "Update";
                }
            }
            var dt = new DataTable();
            var dtUR = new DataTable();
            var dtUF = new DataTable();
            var dtRC = new DataTable();

            if (functionId == "10101030")       //Application Role Function Function Id
            {
                dt = GetStatic.GetHistoryChangedListForFunction(oldData, newData);
            }
            else if (functionId == "10101130" || functionId == "10101330")  //Application User Function Id
            {
                dt = GetStatic.GetHistoryChangedList(changeType, oldData, newData);
                dtUR = GetStatic.GetHistoryChangedListForRole(oldDataUR, newDataUR);
                dtUF = GetStatic.GetHistoryChangedListForFunction(oldDataUF, newDataUF);
            }
            else if(functionId == "20101330")   //Agent Group Function Id
            {
                dt = GetStatic.GetHistoryChangedListForAgent(oldData, newData);
            }
            else if(functionId == "20601035")   //Compliance Rule Id
            {
                dt = GetStatic.GetHistoryChangedList(changeType, oldData, newData);
                dtRC = GetStatic.GetHistoryChangedListForRuleCriteria(oldData1, newData1);
            }
            else if(functionId == "20601135")   //Compliance ID Id
            {
                dt = GetStatic.GetHistoryChangedList(changeType, oldData, newData);
                dtRC = GetStatic.GetHistoryChangedListForIdCriteria(oldData1, newData1, id);
            }
            else if(functionId == "20131430")
            {
                dt = GetStatic.GetHistoryChangedListForCommissionPackage(oldData, newData);
            }
            else
            {
                dt = GetStatic.GetHistoryChangedList(changeType, oldData, newData);
            }


            if (dt.Rows.Count == 0 || (oldData == "" && newData == ""))
            {
                rpt_grid.InnerHtml = "<center><b> No changes made.</b><center>";
                tableUD.Visible = false;
                btnApprove.Visible = false;
                btnReject.Visible = false;
            }
            else
            {
                btnApprove.Visible = true;
                var str = new StringBuilder("<div class='table-responsive'><table width=\"100%\" border=\"0\" class=\"table table-striped table-bordered\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
                str.Append("<tr>");
                str.Append("<th  width = \"200px\" align=\"left\">" + dt.Columns[0].ColumnName + "</th>");
                str.Append("<th align=\"left\">" + dt.Columns[1].ColumnName + "</th>");
                str.Append("<th  width = \"200px\" align=\"left\">" + dt.Columns[2].ColumnName + "</th>");
                str.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    string clash = "";
                    if(dr[3].ToString() == "Y")
                    {
                        clash = "class='show-yellow'";
                    }
                    str.Append("<tr>");
                    str.Append("<td " + clash + " align=\"left\">" + dr[0] + "</td>");
                    if (dr[3].ToString() == "Y")
                    {
                        if (changeType.ToLower() == "insert")
                        {
                            str.Append("<td " + clash + "align=\"left\">" + dr[1] + "</td>");
                        }
                        else
                        {
                            str.Append("<td " + clash + " align=\"left\"><div class=\"oldValue\">" + dr[1] + "</div></td>");
                        }

                        if (changeType.ToLower() == "delete")
                        {
                            str.Append("<td  " + clash + "align=\"left\">" + dr[2] + "</td>");
                        }
                        else
                        {
                            str.Append("<td " + clash + " align=\"left\"><div class=\"newValue\">" + dr[2] + "</div></td>");
                        }
                    }
                    else
                    {
                        str.Append("<td align=\"left\">" + dr[1] + "</td>");
                        str.Append("<td align=\"left\">" + dr[2] + "</td>");
                    }
                    str.Append("</tr>");
                }
                str.Append("</table>");
                rpt_grid.InnerHtml = str.ToString();
            }

            #region Check Application User and Load View Changes for User Roles and User Functions Changes
            if (functionId == "10101130" || functionId == "10101330")       //Application User Function Id
            {
                tabPanel1.Visible = true;
                if (dtUR.Rows.Count == 0)
                {
                    rpt_gridUR.InnerHtml = "<center><b> No changes made.</b><center>";
                    tableUR.Visible = false;
                    btnApproveUR.Visible = false;
                    btnRejectUR.Visible = false;
                }
                else
                {
                    btnApprove.Text = "Approve All";
                    btnApproveUR.Visible = true;
                    var str =
                        new StringBuilder(
                            "<table width=\"100%\" border=\"0\" class=\"table table-striped table-bordered\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
                    str.Append("<tr>");
                    str.Append("<th  width = \"200px\" align=\"left\">" + dtUR.Columns[0].ColumnName + "</th>");
                    str.Append("<th align=\"left\">" + dtUR.Columns[1].ColumnName + "</th>");
                    str.Append("<th  width = \"200px\" align=\"left\">" + dtUR.Columns[2].ColumnName + "</th>");
                    str.Append("</tr>");

                    foreach (DataRow dr in dtUR.Rows)
                    {
                        str.Append("<tr>");
                        str.Append("<td align=\"left\">" + dr[0] + "</td>");
                        if (dr[3].ToString() == "Y")
                        {
                            if (changeType.ToLower() == "insert")
                            {
                                str.Append("<td align=\"left\">" + dr[1] + "</td>");
                            }
                            else
                            {
                                str.Append("<td align=\"left\"><div class=\"oldValue\">" + dr[1] + "</div></td>");
                            }

                            if (changeType.ToLower() == "delete")
                            {
                                str.Append("<td align=\"left\">" + dr[2] + "</td>");
                            }
                            else
                            {
                                str.Append("<td align=\"left\"><div class=\"newValue\">" + dr[2] + "</div></td>");
                            }
                        }
                        else
                        {
                            str.Append("<td align=\"left\">" + dr[1] + "</td>");
                            str.Append("<td align=\"left\">" + dr[2] + "</td>");
                        }
                        str.Append("</tr>");
                    }
                    str.Append("</table>");
                    rpt_gridUR.InnerHtml = str.ToString();
                }
                if (dtUF.Rows.Count == 0)
                {
                    rpt_gridUF.InnerHtml = "<center><b> No changes made.</b><center>";
                    tableUF.Visible = false;
                    btnApproveUF.Visible = false;
                    btnRejectUF.Visible = false;
                    return;
                }
                btnApprove.Text = "Approve All";
                btnApproveUF.Visible = true;
                var str1 =
                    new StringBuilder(
                        "<table width=\"100%\" border=\"0\" class=\"table table-striped table-bordered\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
                str1.Append("<tr>");
                str1.Append("<th  width = \"200px\" align=\"left\">" + dtUF.Columns[0].ColumnName + "</th>");
                str1.Append("<th align=\"left\">" + dtUR.Columns[1].ColumnName + "</th>");
                str1.Append("<th  width = \"200px\" align=\"left\">" + dtUF.Columns[2].ColumnName + "</th>");
                str1.Append("</tr>");

                foreach (DataRow dr in dtUF.Rows)
                {
                    str1.Append("<tr>");
                    str1.Append("<td align=\"left\">" + dr[0] + "</td>");
                    if (dr[3].ToString() == "Y")
                    {
                        if (changeType.ToLower() == "insert")
                        {
                            str1.Append("<td align=\"left\">" + dr[1] + "</td>");
                        }
                        else
                        {
                            str1.Append("<td align=\"left\"><div class=\"oldValue\">" + dr[1] + "</div></td>");
                        }

                        if (changeType.ToLower() == "delete")
                        {
                            str1.Append("<td align=\"left\">" + dr[2] + "</td>");
                        }
                        else
                        {
                            str1.Append("<td align=\"left\"><div class=\"newValue\">" + dr[2] + "</div></td>");
                        }
                    }
                    else
                    {
                        str1.Append("<td align=\"left\">" + dr[1] + "</td>");
                        str1.Append("<td align=\"left\">" + dr[2] + "</td>");
                    }
                    str1.Append("</tr>");
                }
                str1.Append("</table></div>");
                rpt_gridUF.InnerHtml = str1.ToString();
            }
            #endregion

            #region Load Master/Detail View Changes
            if ( 
                functionId == "20131030" || 
                functionId == "20131130" || 
                functionId == "20131230" || 
                functionId == "20131330" || 
                functionId == "20601030" || 
                functionId == "20601130")
            {
                dscPanel.Visible = true;
                btnApprove.Text = "Approve All";
                btnReject.Text = "Reject All";
                SwiftGrid grid = new SwiftGrid();
                var sql = "";
                var GridName = "";
                var ApproveFunctionId = "";

                #region Service Charge Detail Changes
                if (functionId == "20131030")
                {
                    GridName = "grd_sscDetail";
                    ApproveFunctionId = "20131035";        // approve Function Id of Ssc Detail (child of Ssc Master)
                    grid.RowIdField = "sscDetailId";

                    sql = "EXEC proc_sscDetail @flag = 's', @sscMasterId = " + GetId();

                    grid.ColumnList = new List<GridColumn>
                              {
                                  new GridColumn("fromAmt",         "Amount From", "",    "T"),
                                  new GridColumn("toAmt",         "Amount To", "",  "T"),
                                  new GridColumn("pcnt",         "Percent", "",       "T"),
                                  new GridColumn("minAmt",         "Min Amount", "",       "T"),
                                  new GridColumn("maxAmt",         "Max Amount", "",       "T")
                                  
                              };
                }
                #endregion

                #region International Send Commission Detail Changes
                if(functionId == "20131130")
                {
                    GridName = "grd_scSendDetail";
                    ApproveFunctionId = "20131135";
                    grid.RowIdField = "scSendDetailId";

                    sql = "EXEC proc_scSendDetail @flag = 's', @scSendMasterId = " + GetId();

                    grid.ColumnList = new List<GridColumn>
                              {
                                  new GridColumn("fromAmt",         "Amount From", "",    "T"),
                                  new GridColumn("toAmt",         "Amount To", "",  "T"),
                                  new GridColumn("pcnt",         "Percent", "",       "T"),
                                  new GridColumn("minAmt",         "Min Amount", "",       "T"),
                                  new GridColumn("maxAmt",         "Max Amount", "",       "T")
                                  
                              };
                }
                #endregion

                #region International Pay Commission Detail Changes
                if(functionId == "20131230")
                {
                    GridName = "grd_scPayDetail";
                    ApproveFunctionId = "20131235";
                    grid.RowIdField = "scPayDetailId";

                    sql = "EXEC proc_scPayDetail @flag = 's', @scPayMasterId = " + GetId();

                    grid.ColumnList = new List<GridColumn>
                              {
                                  new GridColumn("fromAmt",         "Amount From", "",    "T"),
                                  new GridColumn("toAmt",         "Amount To", "",  "T"),
                                  new GridColumn("pcnt",         "Percent", "",       "T"),
                                  new GridColumn("minAmt",         "Min Amount", "",       "T"),
                                  new GridColumn("maxAmt",         "Max Amount", "",       "T")
                                  
                              };
                }
                #endregion

                #region Compliance Rule Detail Changes
                if (functionId == "20601030")
                {
                    GridName = "grd_csDetail";
                    ApproveFunctionId = "20601035";
                    grid.RowIdField = "csDetailId";

                    sql = "EXEC proc_csDetail @flag = 's', @csMasterId = " + GetId();

                    grid.ColumnList = new List<GridColumn>
                              {
                                  new GridColumn("condition1",              "Condition",                    "",         "T"),
                                  new GridColumn("collMode1",               "Collection Mode",              "",         "T"),
                                  new GridColumn("paymentMode1",            "Payment Mode",                 "",         "T"),
                                  new GridColumn("tranCount",               "#Txn",                         "",         "T"),
                                  new GridColumn("Amount",                  "Amount",                       "",         "M"),
                                  new GridColumn("nextAction1",             "Action",                       "",         "T")
                                  
                              };
                }
                #endregion

                #region Compliance ID Detail Changes
                if (functionId == "20601130")
                {
                    GridName = "grd_cisDetail";
                    ApproveFunctionId = "20601135";
                    grid.RowIdField = "cisDetailId";

                    sql = "EXEC proc_cisDetail @flag = 's', @cisMasterId = " + GetId();

                    grid.ColumnList = new List<GridColumn>
                              {
                                  new GridColumn("condition1",              "Condition",                    "",         "T"),
                                  new GridColumn("collMode1",               "Collection Mode",              "",         "T"),
                                  new GridColumn("paymentMode1",            "Payment Mode",                 "",         "T"),
                                  new GridColumn("tranCount",               "#Txn",                         "",         "T"),
                                  new GridColumn("Amount",                  "Amount",                       "",         "M"),
                                  new GridColumn("isEnable",                "isEnable",                     "",         "T")
                                  
                              };
                }
                #endregion

                #region Domestic Commission Detail Changes
                if (functionId == "20131330")
                {
                    GridName = "grd_scDetail";
                    ApproveFunctionId = "20131335";
                    var allowApprove = swiftLibrary.HasRight(ApproveFunctionId);
                    var popUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
                    ScDetailDao sc = new ScDetailDao();
                    var ds = sc.PopulateCommissionDetail(GetStatic.GetUser(), GetId());
                    var dt1 = ds.Tables[1];
                    var html = new StringBuilder();
                    html.Append("<table class=\"table table-striped table-bordered\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                    html.Append("<tr class=\"hdtitle\">");
                    html.Append("<th colspan=\"2\" class=\"hdtitle\">Amount</th>");
                    html.Append("<th colspan=\"3\" class=\"hdtitle\">Service Charge</th>");
                    html.Append("<th colspan=\"3\" class=\"hdtitle\">Sending Agent Comm.</th>");
                    html.Append("<th colspan=\"3\" class=\"hdtitle\">Sending Sup Agent Comm.</th>");
                    html.Append("<th colspan=\"3\" class=\"hdtitle\">Paying Agent Comm.</th>");
                    html.Append("<th colspan=\"3\" class=\"hdtitle\">Paying Sup Agent Comm.</th>");
                    html.Append("<th colspan=\"3\" class=\"hdtitle\">Bank Comm.</th>");
                    html.Append("<th rowspan=\"2\" class=\"hdtitle\"></th>");
                    html.Append("</tr><tr class=\"hdtitle\">");
                    html.Append("<th class=\"hdtitle\">From</th>");
                    html.Append("<th class=\"hdtitle\">To</th>");
                    html.Append("<th class=\"hdtitle\">Percent</th>");
                    html.Append("<th class=\"hdtitle\">Min Amt</th>");
                    html.Append("<th class=\"hdtitle\">Max Amt</th>");
                    html.Append("<th class=\"hdtitle\">Percent</th>");
                    html.Append("<th class=\"hdtitle\">Min Amt</th>");
                    html.Append("<th class=\"hdtitle\">Max Amt</th>");
                    html.Append("<th class=\"hdtitle\">Percent</th>");
                    html.Append("<th class=\"hdtitle\">Min Amt</th>");
                    html.Append("<th class=\"hdtitle\">Max Amt</th>");
                    html.Append("<th class=\"hdtitle\">Percent</th>");
                    html.Append("<th class=\"hdtitle\">Min Amt</th>");
                    html.Append("<th class=\"hdtitle\">Max Amt</th>");
                    html.Append("<th class=\"hdtitle\">Percent</th>");
                    html.Append("<th class=\"hdtitle\">Min Amt</th>");
                    html.Append("<th class=\"hdtitle\">Max Amt</th>");
                    html.Append("<th class=\"hdtitle\">Percent</th>");
                    html.Append("<th class=\"hdtitle\">Min Amt</th>");
                    html.Append("<th class=\"hdtitle\">Max Amt</th>");
                    html.Append("</tr>");
                    var i = 0;
                    foreach (DataRow dr in dt1.Rows)
                    {
                        html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">" : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                        html.Append("<td>" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["serviceChargePcnt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["serviceChargeMinAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["serviceChargeMaxAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["sAgentCommPcnt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["sAgentCommMinAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["sAgentCommMaxAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["ssAgentCommPcnt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["ssAgentCommMinAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["ssAgentCommMaxAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["pAgentCommPcnt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["pAgentCommMinAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["pAgentCommMaxAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["psAgentCommPcnt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["psAgentCommMinAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["psAgentCommMaxAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["bankCommPcnt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["bankCommMinAmt"].ToString(), "M") + "</td>");
                        html.Append("<td>" + GetStatic.FormatData(dr["bankCommMaxAmt"].ToString(), "M") + "</td>");
                        html.Append("<td nowrap=\"nowrap\">");

                        if (allowApprove)
                        {
                            if (dr["haschanged"].ToString().ToUpper().Equals("Y"))
                            {
                                if (dr["modifiedby"].ToString() == GetStatic.GetUser())
                                {
                                    var approveLink = "id=" + dr["scDetailId"] + "&functionId=" + (ApproveFunctionId) +
                                                  "&functionId2=" + ApproveFunctionId + "&modBy=" + dr["modifiedby"];
                                    var approvePage = GetStatic.GetUrlRoot() + "/ViewChanges.aspx?" + approveLink;
                                    var jsText = "onclick = \"PopUp('" + GridName + "','" + approvePage + "','" + popUpParam + "');\"";
                                    html.AppendLine("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\" " + jsText + "\"><img alt = \"Waiting for Approval\" border = \"0\" title = \"Waiting for Approval\" src=\"" + GetStatic.GetUrlRoot() + "/images/wait-icon.png\" /></a>");
                                }
                                else
                                {
                                    var approveLink = "id=" + dr["scDetailId"] + "&functionId=" + (ApproveFunctionId) +
                                                  "&functionId2=" + ApproveFunctionId;
                                    var approvePage = GetStatic.GetUrlRoot() + "/ViewChanges.aspx?" + approveLink;
                                    var jsText = "onclick = \"PopUp('" + GridName + "','" + approvePage + "','" + popUpParam + "');";
                                    html.AppendLine("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\" " + jsText + "\"><img alt = \"View Changes\" border = \"0\" title = \"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" /></a>");
                                }
                            }
                        }
                        html.Append("</td>");
                        html.Append("</tr>");
                    }
                    html.Append("</table>");
                    rpt_gridDetail.InnerHtml = html.ToString();
                    return;
                }
                #endregion

                grid.GridName = GridName;
                grid.GridType = 1;

                grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
                grid.ShowAddButton = false;
                grid.ShowFilterForm = false;
                grid.ShowPagingBar = false;
                grid.ShowPopUpWindowOnAddButtonClick = true;
                grid.AlwaysShowFilterForm = false;
                grid.AllowEdit = false;
                grid.ApproveFunctionId = functionId;
                grid.ApproveFunctionId2 = ApproveFunctionId;
                grid.AllowApprove = swiftLibrary.HasRight(functionId);
                grid.SetComma();

                rpt_gridDetail.InnerHtml = grid.CreateGrid(sql);


            }
            #endregion

            #region Load Criteria Changes
            if(functionId == "20601035" || functionId == "20601135")
            {
                if (dtRC.Rows.Count == 0)
                {
                    rpt_gridDetail.InnerHtml = "<center><b> No changes made.</b><center>";
                }
                else
                {
                    dscPanel.Visible = true;
                    btnApprove.Text = "Approve All";
                    btnReject.Text = "Reject All";
                    var str =
                        new StringBuilder(
                            "<table width=\"100%\" border=\"0\" class=\"table table-striped table-bordered\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
                    str.Append("<tr>");
                    str.Append("<th  width = \"200px\" align=\"left\">" + dtRC.Columns[0].ColumnName + "</th>");
                    str.Append("<th align=\"left\">" + dtRC.Columns[1].ColumnName + "</th>");
                    str.Append("<th  width = \"200px\" align=\"left\">" + dtRC.Columns[2].ColumnName + "</th>");
                    str.Append("</tr>");

                    foreach (DataRow dr in dtRC.Rows)
                    {
                        str.Append("<tr>");
                        str.Append("<td align=\"left\">" + dr[0] + "</td>");
                        if (dr[3].ToString() == "Y")
                        {
                            if (changeType.ToLower() == "insert")
                            {
                                str.Append("<td align=\"left\">" + dr[1] + "</td>");
                            }
                            else
                            {
                                str.Append("<td align=\"left\"><div class=\"oldValue\">" + dr[1] + "</div></td>");
                            }

                            if (changeType.ToLower() == "delete")
                            {
                                str.Append("<td align=\"left\">" + dr[2] + "</td>");
                            }
                            else
                            {
                                str.Append("<td align=\"left\"><div class=\"newValue\">" + dr[2] + "</div></td>");
                            }
                        }
                        else
                        {
                            str.Append("<td align=\"left\">" + dr[1] + "</td>");
                            str.Append("<td align=\"left\">" + dr[2] + "</td>");
                        }
                        str.Append("</tr>");
                    }
                    str.Append("</table>");
                    rpt_gridDetail.InnerHtml = str.ToString();
                }
            }
            #endregion
        }
    }
}
