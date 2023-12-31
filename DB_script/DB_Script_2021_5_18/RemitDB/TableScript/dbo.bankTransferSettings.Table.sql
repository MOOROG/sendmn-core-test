USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankTransferSettings]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankTransferSettings](
	[rCountryId] [int] NOT NULL,
	[rCurrencyCode] [varchar](5) NOT NULL,
	[rRate] [money] NOT NULL,
	[cRate] [money] NOT NULL,
	[serviceCharge] [money] NOT NULL,
	[customerRate] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rCountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
