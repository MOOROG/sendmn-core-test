using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.CashAndVault
{
	public class CashHoldLimitTopUpDao : RemittanceDao
	{
		public DbResult UpdateTopUP(string user, string agentId, string amount)
		{
			string sql = "EXEC Proc_CashHoldLimitTopUp";
			sql += " @flag = 'i' ";
			sql += ", @user = " + FilterString(user);
			sql += ", @agentId = " + FilterString(agentId);
			sql += ", @amount = " + FilterString(amount);
			return ParseDbResult(ExecuteDataset(sql).Tables[0]);
		}

		public DbResult Approve(string user, string btId)
		{
			var sql = "EXEC Proc_CashHoldLimitTopUp";
			sql += " @flag = 'approve'";
			sql += ", @btId = " + FilterString(btId);
			sql += ", @user = " + FilterString(user);

			return ParseDbResult(ExecuteDataset(sql).Tables[0]);
		}

		public DbResult Reject(string user, string btId)
		{
			var sql = "EXEC Proc_CashHoldLimitTopUp";
			sql += " @flag = 'reject'";
			sql += ", @btId = " + FilterString(btId);
			sql += ", @user = " + FilterString(user);

			return ParseDbResult(ExecuteDataset(sql).Tables[0]);
		}

	}
}
