USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankCollectionVoucherDetail]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankCollectionVoucherDetail](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[tempTranId] [bigint] NOT NULL,
	[mainTranId] [bigint] NULL,
	[voucherNo] [varchar](25) NOT NULL,
	[voucherDate] [datetime] NOT NULL,
	[voucherAmt] [money] NOT NULL,
	[bankId] [int] NOT NULL,
	[fileName] [varchar](50) NULL,
	[accountNo] [varchar](25) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
