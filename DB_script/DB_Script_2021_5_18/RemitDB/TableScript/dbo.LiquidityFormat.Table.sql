USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[LiquidityFormat]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LiquidityFormat](
	[rowid] [int] NOT NULL,
	[acct_name] [varchar](200) NULL,
	[ac_code] [int] NULL,
	[flag] [varchar](20) NULL,
	[type] [varchar](20) NULL,
 CONSTRAINT [pk_idx_LiquidityFormat_rowId] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
