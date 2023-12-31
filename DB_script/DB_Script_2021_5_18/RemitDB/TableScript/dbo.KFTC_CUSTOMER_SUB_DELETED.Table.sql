USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[KFTC_CUSTOMER_SUB_DELETED]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KFTC_CUSTOMER_SUB_DELETED](
	[masterId] [bigint] NULL,
	[customerId] [bigint] NULL,
	[userSeqNo] [varchar](10) NULL,
	[fintechUseNo] [varchar](30) NULL,
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
	[RejectedBy] [varchar](50) NULL,
	[RejectedDate] [datetime] NULL,
	[RejectNote] [varchar](200) NULL
) ON [PRIMARY]
GO
