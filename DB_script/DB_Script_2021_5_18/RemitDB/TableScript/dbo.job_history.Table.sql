USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[job_history]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[job_history](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[job_name] [varchar](50) NULL,
	[job_time] [datetime] NULL,
	[job_user] [varchar](50) NULL,
	[job_value] [varchar](50) NULL,
	[job_remarks] [varchar](50) NULL,
	[update_row] [varchar](50) NULL,
	[old_value] [varchar](50) NULL,
 CONSTRAINT [pk_idx_job_history_rowId] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
