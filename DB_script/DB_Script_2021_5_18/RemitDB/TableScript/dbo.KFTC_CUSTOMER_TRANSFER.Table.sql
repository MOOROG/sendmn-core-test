USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[KFTC_CUSTOMER_TRANSFER]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KFTC_CUSTOMER_TRANSFER](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[tranId] [bigint] NULL,
	[customerId] [bigint] NOT NULL,
	[fintechUseNo] [varchar](30) NOT NULL,
	[apiTranId] [varchar](20) NOT NULL,
	[apiTranDtm] [varchar](17) NULL,
	[rspCode] [varchar](5) NULL,
	[dpsBankCodeStd] [varchar](3) NULL,
	[dpsAccountNumMasked] [varchar](20) NULL,
	[dpsPrintContent] [nvarchar](20) NULL,
	[bankTranId] [varchar](20) NULL,
	[bankTranDate] [varchar](8) NULL,
	[bankCodeTran] [varchar](3) NULL,
	[bankRspCode] [varchar](3) NULL,
	[bankCodeStd] [varchar](3) NULL,
	[accountNumMasked] [varchar](20) NULL,
	[printContent] [nvarchar](20) NULL,
	[accountName] [nvarchar](20) NULL,
	[tranAmt] [varchar](15) NULL,
	[errorCode] [varchar](10) NULL,
	[errorMsg] [varchar](500) NULL,
	[remittance_check] [char](1) NULL,
 CONSTRAINT [PK_KFTC_CUSTOMER_TRANSFER] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC,
	[customerId] ASC,
	[fintechUseNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
