using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.SyncDao
{
	public class StateCityTownDao : RemittanceDao
	{
		public DbResult EnableDisableState(string rowId, string user, string isActive)
		{
			var sql = "EXEC PROC_API_STATE_SETUP @flag = 'enable-disable-state'";

			sql += ", @user = " + FilterString(user);
			sql += ", @rowId = " + FilterString(rowId);
			sql += ", @IsActive = " + FilterString(isActive);

			return ParseDbResult(sql);
		}
		public DbResult EnableDisableCity(string rowId, string user, string isActive)
		{
			var sql = "EXEC PROC_API_STATE_SETUP @flag = 'enable-disable-city'";

			sql += ", @user = " + FilterString(user);
			sql += ", @rowId = " + FilterString(rowId);
			sql += ", @IsActive = " + FilterString(isActive);

			return ParseDbResult(sql);
		}
		public DbResult EnableDisableTown(string rowId, string user, string isActive)
		{
			var sql = "EXEC PROC_API_STATE_SETUP @flag = 'enable-disable-town'";

			sql += ", @user = " + FilterString(user);
			sql += ", @rowId = " + FilterString(rowId);
			sql += ", @IsActive = " + FilterString(isActive);

			return ParseDbResult(sql);
		}
		public DataRow GetDetailsOfState(string rowId, string user)
		{
			var sql = "EXEC PROC_API_STATE_SETUP @flag = 'getDetailsOfState'";

			sql += ", @user = " + FilterString(user);
			sql += ", @rowId = " + FilterString(rowId);

			return ExecuteDataRow(sql);
		}
		public DataRow GetDetailsOfCity(string rowId, string user)
		{
			var sql = "EXEC PROC_API_STATE_SETUP @flag = 'getDetailsOfCity'";
			sql += ", @user = " + FilterString(user);
			sql += ", @rowId = " + FilterString(rowId);

			return ExecuteDataRow(sql);
		}
	}
}
