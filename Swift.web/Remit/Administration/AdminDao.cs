using Swift.DAL.SwiftDAL;
using System;
using System.Data;
using System.Runtime.InteropServices.ComTypes;

namespace Swift.DAL.BL.Remit.Administration {
  public class AdminDao : SwiftDao {
    public DbResult Update(string user, string adminId, string userName, string userPassword, string userCode,
                           string userPost, string userPhone1, string userPhone2, string userFax1, string userFax2,
                           string userMobile1, string userMobile2, string userEmail1, string userEmail2,
                           string userAddress, string userCity, string userCountry, string userType, string isActive) {
      string sql = "EXEC proc_adminMaster";
      sql += " @flag = " + (adminId == "0" || adminId == "" ? "'i'" : "'u'");
      sql += ", @user = " + FilterString(user);
      sql += ", @adminId = " + FilterString(adminId);

      sql += ", @userName = " + FilterString(userName);
      sql += ", @userPassword = " + FilterString(userPassword);
      sql += ", @userCode = " + FilterString(userCode);
      sql += ", @userPost = " + FilterString(userPost);
      sql += ", @userPhone1 = " + FilterString(userPhone1);
      sql += ", @userPhone2 = " + FilterString(userPhone2);
      sql += ", @userFax1 = " + FilterString(userFax1);
      sql += ", @userFax2 = " + FilterString(userFax2);
      sql += ", @userMobile1 = " + FilterString(userMobile1);
      sql += ", @userMobile2 = " + FilterString(userMobile2);
      sql += ", @userEmail1 = " + FilterString(userEmail1);
      sql += ", @userEmail2 = " + FilterString(userEmail2);
      sql += ", @userAddress = " + FilterString(userAddress);
      sql += ", @userCity = " + FilterString(userCity);
      sql += ", @userCountry = " + FilterString(userCountry);
      sql += ", @isActive = " + FilterString(isActive);
      sql += ", @userType = " + FilterString(userType);
      /*sql += ", @session = " + FilterString(session);
      sql += ", @loginTime = " + FilterString(loginTime);
      sql += ", @logoutTime = " + FilterString(logoutTime);
      sql += ", @createdDate = " + FilterString(createdDate);
      sql += ", @lastPwdChanged = " + FilterString(lastPwdChanged);*/
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult Delete(string user, string adminId) {
      string sql = "EXEC proc_adminMaster";
      sql += " @flag = 'd'";
      sql += ", @user = " + FilterString(user);
      sql += ", @adminId = " + FilterString(adminId);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataRow SelectById(string user, string adminId) {
      string sql = "EXEC proc_adminMaster";
      sql += " @flag = 'a'";
      sql += ", @user = " + FilterString(user);
      sql += ", @adminId = " + FilterString(adminId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DbResult Approve(string user, string adminId) {
      string sql = "EXEC proc_adminMaster";
      sql += " @flag = 'approve'";
      sql += ", @user = " + FilterString(user);
      sql += ", @adminId = " + FilterString(adminId);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult Reject(string user, string adminId) {
      string sql = "EXEC proc_adminMaster";
      sql += " @flag = 'reject'";
      sql += ", @user = " + FilterString(user);
      sql += ", @adminId = " + FilterString(adminId);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
    public DbResult CouponUpdate(string id, string user, string parentId, string name, string description, decimal couponPrice,
                                 string couponImage, string discountType, decimal discountAmount, string discountCurrency,
                                 DateTime startDate, DateTime endDate, decimal couponQuantity) {
      string sql = "EXEC [SendMnPro_Remit].[dbo].proc_addCoupons";
      DateTimeOffset date1 = (DateTimeOffset)DateTime.Now;
      sql += " @flag = " + (id == "" || id == "0" ? "'add'" : "'edit'");
      sql += ", @id = " + FilterString(id);
      sql += ", @parentId = " + FilterString(parentId);
      sql += ", @name = " + FilterString(name);
      sql += ", @description = " + FilterString(description);
      sql += ", @couponPrice = " + couponPrice;
      sql += ", @couponImage = " + FilterString(couponImage);
      sql += ", @discountType = " + FilterString(discountType);
      sql += ", @discountAmount = " + discountAmount;
      sql += ", @discountCurrency = " + FilterString(discountCurrency);
      sql += ", @startDate = " + FilterString(startDate.ToString("yyyy-MM-dd HH:mm"));
      sql += ", @endDate = " + FilterString(endDate.ToString("yyyy-MM-dd HH:mm"));
      sql += ", @couponQuantity = " + couponQuantity;
      sql += ", @user = " + FilterString(user);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
    public DbResult CouponDelete(string id) {
      string sql = "EXEC [SendMnPro_Remit].[dbo].proc_addCoupons @flag='delete'";
      sql += ", @id=" + FilterString(id);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
  }
}