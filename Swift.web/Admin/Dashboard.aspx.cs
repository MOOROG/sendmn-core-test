using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web.UI;

namespace Swift.web.Admin {
  public partial class Dashboard : Page {
    private SwiftLibrary sl = new SwiftLibrary();
    private RemittanceLibrary _remit = new RemittanceLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      sl.CheckSession();
      if (!IsPostBack) {
        PopulateMenu();

        GetStatic.PrintMessage(Page);
        PopulateNotification();
      }
    }

    protected string getUser1() {
      return GetStatic.GetUser();
    }

    protected void PopulateNotification() {
      string sql = "EXEC proc_notification @user = '" + getUser1() + "'";
      DataTable dt = _remit.ExecuteDataTable(sql);
      if (null == dt) {
        return;
      }
      if (dt.Rows.Count == 0) {
        return;
      }
      StringBuilder sb = new StringBuilder();
      int counter = 0;

      foreach (DataRow item in dt.Rows) {
        counter += Convert.ToInt16(item["count"].ToString());
        sb.AppendLine("<li class=\"clearfix\">");
        sb.AppendLine("<a href=\"" + item["link"].ToString() + "\" target=\"mainFrame\">");
        sb.AppendLine("<span class=\"pull-left\">");
        sb.AppendLine("<i class=\"fa fa-bell\" style='color:#0e96ec'></i>");
        sb.AppendLine("</span>");
        sb.AppendLine("<span class=\"media-body\">");
        sb.AppendLine(item["msg"].ToString());
        sb.AppendLine("<em>" + item["msg1"].ToString() + "</em>");
        sb.AppendLine("</span>");
        sb.AppendLine("</a></li>");
      }
      count.Text = counter.ToString();
      notification.InnerHtml = "<li class=\"notify-title\">" + counter.ToString() + " New Notifications</li>" + sb.ToString();
    }

    protected void PopulateMenu() {
      StringBuilder sb = new StringBuilder();
      sb = (StringBuilder)Session[getUser1() + "Menu"];
      if (string.IsNullOrEmpty(sb.ToString()) || string.IsNullOrWhiteSpace(sb.ToString())) {
        sb = new StringBuilder();
        string sql = "exec menu_proc @flag = 'admin', @user = '" + getUser1() + "'";
        DataSet ds = _remit.ExecuteDataset(sql);
        DataTable menuGroup = ds.Tables[0];

        sb.AppendLine("<div id=\"navbar-main\" class=\"navbar-collapse collapse\">");
        sb.AppendLine("<ul class=\"nav navbar-nav\">");
        sb.AppendLine("<li class=\"active\"><a href=\"../Admin/Dashboard.aspx\">Dashboard</a></li>");
        if (ds.Tables[0].Rows.Count == 0 || ds.Tables[1].Rows.Count == 0) {
          sb.AppendLine("</li></ul>");
          sb.AppendLine("</div>");
          menu.InnerHtml = sb.ToString();
          return;
        }

        for (int i = 0; i <= menuGroup.Rows.Count; i++) {
          if (menuGroup.Rows.Count != 0) {
            string menuGroupName = menuGroup.Rows[0]["menuGroup"].ToString();
            DataRow[] rows = ds.Tables[1].Select("menuGroup IN (" + GetMenuGroup(GetMainMenuGroup(menuGroupName)) + ")");

            sb.AppendLine(GetMenuContents(menuGroupName, rows));
            DataRow[] rowsToRemove = menuGroup.Select("menuGroup IN (" + GetMenuGroup(GetMainMenuGroup(menuGroupName)) + ")");
            foreach (DataRow row in rowsToRemove) {
              menuGroup.Rows.Remove(row);
            }
          }
          i = 0;
        }
        sb.AppendLine("</li></ul>");
        sb.AppendLine("</div>");
        Session[getUser1() + "Menu"] = sb;
      }
      menu.InnerHtml = sb.ToString();
    }

    private string GetMenuContents(string menuGroup, DataRow[] dr) {
      StringBuilder sb = new StringBuilder("");
      DataTable dt = CreateDataTable();

      foreach (DataRow row in dr) {
        dt.ImportRow(row);
      }
      sb.AppendLine("<li class=\"dropdown\">");
      sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">" + GetMainMenuGroup(menuGroup) + "<span class=\"caret\"></span></a>");
      sb.AppendLine("<ul class=\"dropdown-menu\">");
      for (int i = 0; i <= dt.Rows.Count; i++) {
        if (dt.Rows.Count != 0) {
          DataRow[] menuList = dt.Select("menuGroup = ('" + dt.Rows[0]["menuGroup"].ToString() + "')");
          string subMainMenu = menuList[0]["menuGroup"].ToString();

          if (menuGroup == "Notifications" || subMainMenu == "User Management" || subMainMenu == "Other Services" || subMainMenu == "Transaction") {
            foreach (DataRow row in menuList) {
              sb.AppendLine("<li><a tabindex=\"-1\" href=\"" + row["linkPage"].ToString() + "\" target=\"mainFrame\">" + row["menuName"].ToString() + "</a></li>");
            }
            //sb.AppendLine("<li><a tabindex=\"-1\" href=\"/Remit/TPSetup/BankAndBranchSetup/BankList.aspx\" target=\"mainFrame\">BankSync</a></li>");
            //sb.AppendLine("<li><a tabindex=\"-1\" href=\"/OtherServices/SendMNAPI/EmployeeAbsenceList.aspx\" target=\"mainFrame\">Employee Absence</a></li>");
            //sb.AppendLine("<li><a tabindex=\"-1\" href=\"/OtherServices/SendMNAPI/BlacklistedAccounts.aspx\" target=\"mainFrame\">Blacklist Users</a></li>");
            if (GetStatic.GetUserType() == "HO") {
              //sb.AppendLine("<li><a tabindex=\"-1\" href=\"/OtherServices/SendMNAPI/BranchTransaction.aspx\" target=\"mainFrame\">Branch Transaction</a></li>");
              //sb.AppendLine("<li><a tabindex=\"-1\" href=\"/OtherServices/SendMNAPI/MonpepSearch.aspx\" target=\"mainFrame\">MonPep Search</a></li>");
              //sb.AppendLine("<li><a tabindex=\"-1\" href=\"/OtherServices/SendMNAPI/KhaanbankStatement.aspx\" target=\"mainFrame\">BankStatement</a></li>");
            }
            //sb.AppendLine("<li><a tabindex=\"-1\" href=\"/AgentNew/Administration/AgentCharging/AgentMoneyCharge.aspx\" target=\"mainFrame\">Agent Fund</a></li>");
            //sb.AppendLine("</ul></li>");
          } else {
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">" + subMainMenu + "</a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            foreach (DataRow row in menuList) {
              sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"" + row["linkPage"].ToString() + "\" target=\"mainFrame\">" + row["menuName"].ToString() + "</a></li>");
            }
            sb.AppendLine("</ul></li>");
          }
          DataRow[] rows = dt.Select("menuGroup = ('" + dt.Rows[0]["menuGroup"].ToString() + "')");
          foreach (DataRow row in rows) {
            dt.Rows.Remove(row);
          }
        }
        i = 0;
      }
      sb.AppendLine("</ul></li>");
      return sb.ToString();
    }

    private DataTable CreateDataTable() {
      DataTable dt = new DataTable();
      DataColumn linkPage = new DataColumn("linkPage", Type.GetType("System.String"));
      DataColumn menuName = new DataColumn("menuName", Type.GetType("System.String"));
      DataColumn menuGroup = new DataColumn("menuGroup", Type.GetType("System.String"));
      dt.Columns.Add(linkPage);
      dt.Columns.Add(menuName);
      dt.Columns.Add(menuGroup);

      return dt;
    }

    private string GetMenuGroup(string mainMenuGroup) {
      string menuGroups = "";
      if (mainMenuGroup == "Administration") {
        menuGroups = "'User Management', 'Application Settings', 'Application Log', 'Administration', 'Customer Management' ,'Online Customer','Deposit API','Registration' ";
      } else if (mainMenuGroup == "System Security") {
        menuGroups = "'Notifications'";
      } else if (mainMenuGroup == "Transaction") {
        menuGroups = "'Transaction','Bank Deposit Transaction'";
      } else if (mainMenuGroup == "Remittance") {
        menuGroups = "'Credit Risk Management', 'Reports-Master','Reports','Service Charge & Commission', 'Customer Reports' ,'Utilities', 'Remittance', 'Compliance','OFAC Management' , 'Risk Based Assessement'";
      } else if (mainMenuGroup == "Account") {
        menuGroups = "'BILL & VOUCHER', 'Remittance Reports', 'ACCOUNT SETTING', 'ACCOUNT REPORT', 'Accounts', 'Cash Report'";
      } else if (mainMenuGroup == "EXCHANGE SETUP") {
        menuGroups = "'Credit Risk', 'Service Charge/Commission','EXCHANGE SETUP','Exchange Rate', 'Cash And Vault','ThirdParty Setups','Currency Exchange'";
      } else {
        menuGroups = "'" + mainMenuGroup + "'";
      }
      return menuGroups;
    }

    protected string GetMainMenuGroup(string menuGroupName) {
      string mainMenuGroupName = "";
      if (menuGroupName == "User Management" || menuGroupName == "Application Settings" || menuGroupName == "Application Log" || menuGroupName == "Administration" || menuGroupName == "Customer Management" || menuGroupName == " Online Customer" || menuGroupName == "Registration") {
        mainMenuGroupName = "Administration";
      } else if (menuGroupName == "Notifications") {
        mainMenuGroupName = "System Security";
      } else if (menuGroupName == "Credit Risk Management" || menuGroupName == "Compliance" || menuGroupName == "Customer Reports" || menuGroupName == "Reports-Master" || menuGroupName == "Reports" || menuGroupName == "Service Charge & Commission" || menuGroupName == "Utilities" || menuGroupName == "Remittance" || menuGroupName == "Risk Based Assessement") {
        mainMenuGroupName = "Remittance";
      } else if (menuGroupName == "BILL & VOUCHER" || menuGroupName == "Remittance Reports" || menuGroupName == "ACCOUNT SETTING" || menuGroupName == "ACCOUNT REPORT" || menuGroupName == "Accounts" || menuGroupName == "OFAC Management" || menuGroupName == "Cash Report") {
        mainMenuGroupName = "Account";
      } else if (menuGroupName == "Credit Risk" || menuGroupName == "Service Charge/Commission" || menuGroupName == "Exchange Rate" || menuGroupName == "Cash And Vault" || menuGroupName == "ThirdParty Setups" || menuGroupName == "Currency Exchange") {
        mainMenuGroupName = "EXCHANGE SETUP";
      }
        //else if (menuGroupName == "ThirdParty Setups")
        //{
        //    mainMenuGroupName = "Exchange Rate";
        //}
        else if (menuGroupName == "Transaction" || menuGroupName == "Bank Deposit Transaction") {
        mainMenuGroupName = "Transaction";
      } else {
        mainMenuGroupName = menuGroupName;
      }
      return mainMenuGroupName;
    }
  }
}