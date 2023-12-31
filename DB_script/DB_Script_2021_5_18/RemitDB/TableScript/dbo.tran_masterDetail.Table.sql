USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tran_masterDetail]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tran_masterDetail](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
 CONSTRAINT [pk_idx_tran_masterDetail_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
