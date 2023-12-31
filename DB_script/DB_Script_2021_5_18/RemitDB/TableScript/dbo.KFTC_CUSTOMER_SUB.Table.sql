USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[KFTC_CUSTOMER_SUB]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KFTC_CUSTOMER_SUB](
	[customerId] [bigint] NOT NULL,
	[userSeqNo] [varchar](10) NOT NULL,
	[fintechUseNo] [varchar](30) NOT NULL,
	[accountAlias] [nvarchar](50) NULL,
	[bankCodeStd] [varchar](3) NULL,
	[bankName] [nvarchar](20) NULL,
	[accountNum] [varchar](20) NULL,
	[accountNumMasked] [varchar](20) NULL,
	[accountName] [nvarchar](100) NULL,
	[accountType] [char](1) NULL,
	[inquiryAgreeYn] [char](1) NULL,
	[transferAgreeYn] [char](1) NULL,
	[accountState] [char](2) NULL,
	[inquiryAgreeDtime] [varchar](14) NULL,
	[transferAgreeDtime] [varchar](14) NULL,
 CONSTRAINT [PK_KFTC_CUSTOMER_SUB] PRIMARY KEY CLUSTERED 
(
	[customerId] ASC,
	[userSeqNo] ASC,
	[fintechUseNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
