USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[remitTranOfac]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[remitTranOfac](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TranId] [bigint] NULL,
	[blackListId] [varchar](max) NULL,
	[approvedRemarks] [varchar](500) NULL,
	[approvedBy] [varchar](100) NULL,
	[approvedDate] [datetime] NULL,
	[reason] [varchar](max) NULL,
	[flag] [char](1) NULL,
 CONSTRAINT [pk_idx_remitTranOfac_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
