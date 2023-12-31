USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[report_format]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_format](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[lable] [varchar](50) NULL,
	[reportid] [int] NOT NULL,
	[type] [varchar](1) NULL,
	[grp] [varchar](100) NULL,
	[grp_main] [varchar](50) NULL,
 CONSTRAINT [pk_idx_report_format_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
