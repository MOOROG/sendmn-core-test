USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[Fiscal_Month]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fiscal_Month](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[nplYear] [varchar](50) NULL,
	[engDateBaisakh] [date] NULL,
	[baisakh] [int] NULL,
	[jestha] [int] NULL,
	[ashadh] [int] NULL,
	[shrawan] [int] NULL,
	[bhadra] [int] NULL,
	[ashwin] [int] NULL,
	[kartik] [int] NULL,
	[mangshir] [int] NULL,
	[poush] [int] NULL,
	[magh] [int] NULL,
	[falgun] [int] NULL,
	[chaitra] [int] NULL,
	[DefaultYr] [varchar](4) NULL,
 CONSTRAINT [pk_idx_Fiscal_Month_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
