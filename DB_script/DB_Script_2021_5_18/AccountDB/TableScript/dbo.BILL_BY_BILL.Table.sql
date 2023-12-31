USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[BILL_BY_BILL]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BILL_BY_BILL](
	[ROWID] [int] IDENTITY(1,1) NOT NULL,
	[TRN_DATE] [date] NULL,
	[TRN_REFNO] [varchar](20) NULL,
	[ACC_NUM] [varchar](50) NULL,
	[PART_TRN_TYPE] [varchar](5) NULL,
	[VOUCHER_TYPE] [varchar](1) NULL,
	[TRAN_AMT] [money] NULL,
	[REMAIN_AMT] [money] NULL,
	[BILL_REF] [varchar](200) NULL,
	[OPENING_BAL] [money] NULL
) ON [PRIMARY]
GO
