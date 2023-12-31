USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[SambaImport]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SambaImport](
	[REFNO] [varchar](50) NULL,
	[REMITTER] [varchar](100) NULL,
	[BENEFICIARY] [varchar](100) NULL,
	[AMOUNT] [money] NULL,
	[DATE] [datetime] NULL,
	[STATUS] [varchar](50) NULL,
	[DOWNLOAD_BY] [varchar](30) NULL,
	[SESSION_ID] [varchar](50) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [pk_idx_SambaImport_REFNO] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[REFNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
