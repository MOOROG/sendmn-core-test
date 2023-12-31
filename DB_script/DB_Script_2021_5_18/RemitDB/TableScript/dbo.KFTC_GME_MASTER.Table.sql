USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[KFTC_GME_MASTER]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KFTC_GME_MASTER](
	[clientUseCode] [varchar](10) NOT NULL,
	[clientId] [varchar](50) NOT NULL,
	[clientSecret] [varchar](50) NOT NULL,
	[accessToken] [varchar](50) NOT NULL,
	[tokenType] [varchar](10) NOT NULL,
	[scope] [varchar](10) NOT NULL,
	[expiresIn] [int] NULL,
	[accessTokenRegTime] [datetime] NULL,
	[accessTokenExpTime] [datetime] NULL,
	[accountAlias] [nvarchar](50) NULL,
	[bankCodeStd] [varchar](3) NOT NULL,
	[bankCodeSub] [varchar](7) NULL,
	[bankName] [nvarchar](20) NULL,
	[accountNum] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[clientUseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
