using Swift.web.Library;
using System;

namespace Swift.web.Remit.BonusManagement.BonusPointReport
{
	public partial class Manage : System.Web.UI.Page
	{
		private readonly SwiftLibrary _sl = new SwiftLibrary();
		private const string ViewFunctionId = "20822300";
		protected void Page_Load(object sender, EventArgs e)
		{
			_sl.CheckSession();
			if (!IsPostBack)
			{
				Authenticate();
			}
		}

		private void Authenticate()
		{
			_sl.CheckAuthentication(ViewFunctionId);
		}
		
	}
}