USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[FundTransferHistory_old]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundTransferHistory_old](
	[RowId] [int] IDENTITY(1,1) NOT NULL,
	[TransferDate] [date] NOT NULL,
	[BankId] [int] NOT NULL,
	[UsdAmt] [money] NOT NULL,
	[Rate] [money] NULL,
	[LcyAmt] [money] NOT NULL,
	[ContractNo] [varchar](30) NULL,
	[DealBookingId] [int] NOT NULL,
	[PartnerId] [int] NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[RemainingAmt] [money] NOT NULL,
	[RefNum] [bigint] NULL
) ON [PRIMARY]
GO
