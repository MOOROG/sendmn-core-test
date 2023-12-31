USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tran_print]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tran_print](
	[rowid] [int] NOT NULL,
	[ref_num] [varchar](50) NULL,
	[tran_type] [varchar](3) NULL,
	[print_date] [date] NULL,
	[print_user] [varchar](200) NULL,
 CONSTRAINT [pk_idx_tran_print_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
