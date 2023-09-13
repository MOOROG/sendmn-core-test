using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SyncModel.Town
{
	public class TownResponse
	{
		public string Id { get; set; }
		public int CityId { get; set; }
		public string StateId { get; set; }
		public string Name { get; set; }
		public string CountryIsoCode { get; set; }
		public string Status { get; set; }
	}
}
