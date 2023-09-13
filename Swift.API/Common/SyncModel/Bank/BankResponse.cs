using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SyncModel.Bank
{
	public class BankResponse
	{
		public string Id { get; set; }
		public string Name { get; set; }
	}
	public class BankBranchResponse
	{
		public string BankBranchID { get; set; }
		public string BankID { get; set; }
		public string BankBranchName { get; set; }
	}
}
