USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TRAN_MASTERDETAIL_BAK]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TRAN_MASTERDETAIL_BAK](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[ref_num] [varchar](50) NULL,
	[tran_particular] [varchar](500) NULL,
	[tran_rate] [money] NULL,
	[tran_rmks] [varchar](500) NULL,
	[billdate] [datetime] NULL,
	[party] [int] NULL,
	[otherinfo] [varchar](52) NULL,
	[tran_type] [varchar](20) NULL,
	[company_id] [int] NULL,
	[tranDate] [datetime] NULL,
	[voucher_image] [varchar](200) NULL,
	[NEW_REF_NUM] [varchar](30) NULL
) ON [PRIMARY]
GO
