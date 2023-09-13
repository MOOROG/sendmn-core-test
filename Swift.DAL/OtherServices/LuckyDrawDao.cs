using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.OtherServices
{
    public class LuckyDrawDao : RemittanceDao
    {
       
        public DataTable GetLuckyNumber(string flag, string user)
        {
            string sql = "EXEC proc_GetNumber_LuckyDraw";
            sql += " @flag=" + FilterString(flag);
            sql += " ,@user=" + FilterString(user);
            return ExecuteDataTable(sql);
        }
        public DataRow GetLuckyDrawType(string flag)
        {
            var sql = "EXEC proc_luckyDrawSetup @flag = 'getImage'";
            sql += ", @type=" + FilterString(flag);
            return ExecuteDataRow(sql);
        }

    public DbResult DeleteCashCode(string id, string user) {
      string sql = "Exec [proc_cashCode]";
      sql += " @flag ='d'";
      sql += ", @user=" + FilterString(user);
      sql += ", @id=" + FilterString(id);
      return ParseDbResult(sql);
    }
  }
}
