USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[remitTranCompliance]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[remitTranCompliance](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TranId] [bigint] NULL,
	[csDetailTranId] [int] NULL,
	[matchTranId] [varchar](max) NULL,
	[approvedRemarks] [varchar](500) NULL,
	[approvedBy] [varchar](100) NULL,
	[approvedDate] [datetime] NULL,
	[reason] [varchar](max) NULL,
 CONSTRAINT [pk_idx_remitTranCompliance_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
