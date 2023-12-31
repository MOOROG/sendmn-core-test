USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mgCountries]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mgCountries](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[countryCode] [varchar](5) NULL,
	[countryName] [varchar](150) NULL,
	[countryLegacyCode] [varchar](5) NULL,
	[sendActive] [varchar](10) NULL,
	[receiveActive] [varchar](10) NULL,
	[directedSendCountry] [char](10) NULL,
	[mgDirectedSendCountry] [varchar](10) NULL,
	[update_ts] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
