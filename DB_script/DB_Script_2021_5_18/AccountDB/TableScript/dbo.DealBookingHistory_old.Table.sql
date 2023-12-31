USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[DealBookingHistory_old]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DealBookingHistory_old](
	[RowId] [int] IDENTITY(1,1) NOT NULL,
	[DealDate] [date] NOT NULL,
	[BankId] [int] NOT NULL,
	[UsdAmt] [money] NULL,
	[Rate] [money] NULL,
	[LcyAmt] [money] NOT NULL,
	[Dealer] [varchar](100) NULL,
	[ContractNo] [varchar](30) NULL,
	[MaturityDate] [date] NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[RemainingAmt] [money] NULL,
	[refNum] [int] NULL,
	[LcyCurr] [varchar](5) NULL
) ON [PRIMARY]
GO
